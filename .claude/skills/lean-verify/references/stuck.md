# When a proof is not going through

Read this the moment a stuck trigger fires (below), not after an hour of variants. The patterns
here were compiled on Lean 4.36.0; `assets/examples/Backtrack.lean` contains them as running code.

## Contents
1. Stuck triggers: when to stop and come here
2. Step 1: is the goal even true? (falsify first)
3. Step 2: classify the failure
4. Step 3: the backtrack ladder (change level, not variant)
5. Step 4: find resources for the failure class
6. The proof journal
7. Escalating: the stuck report
8. Choosing a strategy up front

## 1. Stuck triggers

Stop proving and start diagnosing when any of these happens:

- Three attempts at the same goal that differ only in tactic choice or lemma list.
- The goal is getting bigger or more numerous instead of smaller.
- The same error message twice in a row after an edit meant to fix it.
- A deterministic timeout or `maxHeartbeats` error. Raising the limit is almost never the fix;
  it means the approach makes Lean search too much.
- You are about to add a hypothesis, weaken a postcondition, add `sorry`, declare an `axiom`,
  reach for `native_decide`, or change a definition "to make the proof easier".
- You have been on one verification condition for more than about ten build or probe cycles.

The last-but-one trigger matters most. Those moves change what is being claimed, so they belong to
the user, and the urge to make them is usually a sign that the goal as stated is false.

## 2. Step 1: is the goal even true?

A large share of stuck proofs are attempts to prove something false: a bug in the code, a wrong
specification, or a loop invariant that does not hold. Spend two minutes trying to refute the
goal before spending more effort proving it.

- Evaluate the claim on small and boundary inputs (empty, zero, one, equal bounds, maximum):
  ```lean
  #eval (List.range 6).all fun n => sumTo (List.range n) 0 == n * (n - 1) / 2   -- true
  #eval (List.range 6).all fun n => sumTo (List.range n) 0 == n * (n + 1) / 2   -- false: claim is wrong
  ```
- Check a bounded instance exhaustively: `example : ∀ n : Fin 6, P n := by decide`.
- Read the automation's own countermodel. `grind +verbose` prints the facts it holds and, for
  arithmetic, an assignment satisfying them:
  ```
  [cutsat] Assignment satisfying linear constraints
    [assign] f 0 := 1
    [assign] f 1 := 2
  ```
  If that assignment is a real counterexample, the goal is false. If it is impossible for a
  reason Lean was not told, that reason is the missing fact (go to class C below).
- Read the open verification condition literally. `⊢ lo ≤ 0` with `lo` arbitrary is false, and it
  tells you which path of the program breaks the contract.
- If the project already depends on a property-testing library such as Plausible, use it. Do not
  add a dependency just for this.

If the goal is false, stop. Work out whether the code, the specification or the invariant is
wrong, and report it. Finding that is a result, often the most valuable one verification gives.

## 3. Step 2: classify the failure

| Class | Symptom | Go to |
|---|---|---|
| A. Statement is false | counterexample found in step 1 | report; fix code or spec with the user |
| B. Invariant or induction hypothesis too weak | the "preserved by the loop body" VC or the inductive step fails, and the hypothesis says too little about the accumulator, the state, or the already-processed part | ladder L3 |
| C. Missing fact | goal is true and small, but no lemma connects the terms; `+verbose` shows the needed fact is absent | ladder L2, then `search.md` |
| D. Fact present, automation does not use it | the lemma exists, `grind` does not instantiate it, `simp` does not rewrite with it | ladder L1; `automation.md` on annotations and `grind [lemma]` |
| E. Wrong proof architecture | case explosion, induction on the wrong variable, proof mirrors the program text line by line | ladder L4 |
| F. Elaboration problem, not a logic problem | "motive is not type correct", stuck typeclass, universe errors, `rw` cannot find the pattern, coercion mismatch | ladder L1 with `pp.explicit`; official `lean-proof` skill for dependent rewriting |
| G. Toolchain drift | unknown tactic or syntax, deprecation warning, documented example fails | `freshness.md`; `scripts/whats_new.py` |
| H. Definition is proof-hostile | `partial def`, `xs[i]!`, well-founded recursion with an opaque measure, a big `match` on tuples, state threaded by hand | ladder L5 |

Say the class out loud in the journal before acting. Misclassification is the usual reason for
going in circles: treating B as C produces an endless hunt for a lemma that does not exist.

## 4. Step 3: the backtrack ladder

The rule is **change level, not variant**. Allow at most three attempts on one rung. Then climb
one rung, and say so. Lower rungs are cheap and local. Higher rungs change more, and from L5 up
they change the artifact, so they need the user's agreement.

**L0. Another closing tactic.** Follow the order in `automation.md`: `grind`, then `lia`/`omega`
for linear arithmetic, `simp`, `bv_decide` for bit vectors, `decide`/`cbv` for closed goals. Ask
`try?` and `exact?`; both print working alternatives.

**L1. Look at the goal instead of at the tactic.** Print it (`done` shows what is left). Run
`grind +verbose`. Use `set_option pp.explicit true in` when two terms look equal and are not.
Split it by hand (`constructor`, `cases`, `split`, `intro`) until each piece is either trivial or
clearly the hard one. Then isolate the hard piece as its own statement:

```lean
have h2 : (xs ++ ys).sum = xs.sum + ys.sum := by sorry   -- isolated, named, searchable
```

An isolated statement can be evaluated, searched for, and proved by a different method without
disturbing the rest. A temporary `sorry` is fine while diagnosing and must be gone before the
work is reported as done.

**L2. Supply the missing fact.** Search before proving (order in `search.md`): `exact?` on the
isolated goal, grep the shipped sources and `.lake/packages`, then the web engines. If the fact
does not exist, state it as a helper lemma about the library operations involved, prove it
separately, and annotate it (`@[grind =]`, `@[simp]`, `@[spec]`) only if it should fire every time.

**L3. Strengthen what you carry.** For a loop, the invariant must be inductive: it has to imply
itself after one more iteration and it has to imply the postcondition at exit. Which VC fails
tells you which half is wrong. For recursion with an accumulator, generalise it:

```lean
-- stuck:   theorem sumTo_eq (xs) : sumTo xs 0 = xs.sum            (IH fixes acc = 0)
theorem sumTo_acc (xs : List Nat) (acc : Nat) : sumTo xs acc = acc + xs.sum := by
  induction xs generalizing acc with
  | nil => simp [sumTo]
  | cons x rest ih => simp [sumTo, ih]; omega
theorem sumTo_eq (xs : List Nat) : sumTo xs 0 = xs.sum := by simpa using sumTo_acc xs 0
```

Typical strengthenings: relate the state to the consumed prefix, not just to "so far so good";
carry bounds on indices; carry the facts the exit condition will need.

**L4. Change the architecture of the proof.**
- Induct along the function's own recursion with `fun_induction f args` instead of along the data.
- Switch between `vcgen` and a direct proof (`unfold`, `induction`, `grind`); small pure loops
  are sometimes shorter directly, and anything with early return or effects is not.
- Introduce a model: prove the imperative code equals a simple pure function, then prove the
  property of the pure function. Two easy proofs often replace one impossible one.
- Give callee functions their own `@[spec]` so callers are verified against the specification
  and never unfold the body.
- Rebuild the proof top down as a skeleton whose steps are `have … := by sorry`, check that the
  skeleton compiles, and fill the hardest step first. Backtracking then replaces one node of the
  skeleton instead of restarting.

**L5. Change the definition (needs the user's agreement).** Make the code easier to reason about
without changing behaviour: structural recursion or a `for` loop in place of `partial`, a
subtype or `Fin` index in place of `xs[i]!`, an explicit state structure in place of a tuple.
State what changed and why. If the old definition must stay, prove the two equal.

**L6. Change the specification (the user decides).** Present the evidence that the specification
is too strong, ambiguous or wrong, and offer concrete alternatives with what each one gives up.
Never weaken it silently. A proof of a weaker statement reported under the old name is the
worst outcome this skill can produce.

**L7. Escalate.** Write the stuck report (section 7) and stop.

## 5. Step 4: find resources for the failure class

| Need | Where, in order |
|---|---|
| A lemma about a library operation (C) | `exact?` / `try?` on the isolated goal; `grep -rn "theorem .*<op>" "$(lean --print-prefix)/src/lean"`; `.lake/packages`; Loogle and the semantic engines (`search.md`, mostly Mathlib) |
| A proof of something similar to copy the shape of (B, E) | proofs of neighbouring lemmas in the shipped sources (`src/lean/Init/Data/List`, `Array`, `Std/Data/…`); the vcgen tutorial source (`Tutorial/VCGen.lean` in `leanprover/reference-manual`); `leanprover/human-eval-lean` for small verified programs; the project's own earlier proofs |
| How a tactic behaves on this version (D, G) | its docstring and syntax in the shipped sources; the reference manual for the project's version; `whats_new.py`; a three-line probe file |
| How `vcgen` treats a construct (B, D) | `Std/WP/` in the shipped sources; `verification.md`; the reference manual's vcgen chapter |
| Whether this is a known bug or regression (F, G) | the release notes' fixes list; GitHub issues of `leanprover/lean4`; the official `lean-mwe` and `lean-bisect` skills |
| Whether anyone has hit this before (any) | the Lean Zulip (search the public archive); state it as a lead, since chat advice ages fast |

Two habits make the search productive. Search for the isolated goal, not the original theorem.
And search by the shape of the statement (the operations and relation involved), since guessing
lemma names from memory is the least reliable method available.

## 6. The proof journal

Keep a short journal file for any proof that passes a stuck trigger (suggested path:
`.lean-verify/journal.md` in the project; template in `assets/proof-journal.md`). One entry per
attempt: goal, failure class, rung, what was tried, what the result showed. It serves three
purposes: it stops you repeating a failed approach after context has moved on, it lets a later
session resume, and it is the raw material for the stuck report. Commit or stash before any L4
or higher change so that backing out is one command.

## 7. Escalating: the stuck report

When L7 is reached, or the user's time budget is, report in this shape and stop:

```
STUCK: <theorem or VC name>
Toolchain: <version>            Class: <A–H>            Highest rung tried: <L0–L6>
Goal (minimal, self-contained, compiles with `sorry`):
  <lean code>
Evidence it is true: <evaluations, bounded checks> | Evidence it may be false: <countermodel>
Tried: <one line per approach, with why it failed>
Best current hypothesis: <what is missing>
Options: 1) <next thing to try and its cost>  2) <definition or spec change, and what it gives up>
         3) <leave an explicit, named `sorry` and continue elsewhere: user's call>
```

A clear stuck report is a legitimate deliverable. An unexplained `sorry`, or a quietly weakened
theorem, is not.

## 8. Choosing a strategy up front

Most of the cost of a hard proof is decided before the first tactic. Before proving:

1. Write the informal argument in three to six sentences. If you cannot, you are not ready.
2. Match the goal shape to a first strategy:

| Goal shape | First strategy |
|---|---|
| Linear arithmetic over `Nat`/`Int` | `lia` or `omega` |
| Bit vectors, fixed-width integers, Boolean structure | `bv_decide`; `grind` for mixed goals |
| Equalities and inequalities needing library lemmas | `grind`, then `grind?` to minimise |
| Property of a recursive function | `fun_induction` along its recursion, then `grind` |
| `do` block with loops, state, exceptions | contract or `vcgen` with invariants |
| Closed, finite, computable | `decide` or `cbv` |
| Program calls other verified programs | `@[spec]` lemmas, modular `vcgen` |

3. Write the skeleton (L4) when the argument has more than two steps.
4. Decide where the difficulty is and attack that first; leave easy cases as temporary `sorry`.
