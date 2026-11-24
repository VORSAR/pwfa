# Proof automation (snapshot: 4.36.0)

Every tactic named here was run on 4.36.0. Behaviour of `grind` in particular changes release
to release (mostly it proves more); probe when in doubt.

## Which tactic

| Goal | First choice | Notes |
|---|---|---|
| Mixed: equalities, library lemmas, case splits, linear arithmetic | `grind` | the default workhorse; see below |
| Linear arithmetic over `Nat`/`Int` | `lia` or `omega` | fast and predictable; no lemma search |
| Bit vectors, fixed-width integers, pure Boolean structure | `bv_decide` | calls a SAT solver and checks the certificate; `+uf` (4.36) adds uninterpreted functions. Leaves a `_native` axiom |
| Rewriting to a normal form | `simp`, `simp [lemmas]` | `simp?` prints the `simp only […]` it used |
| Closed, computable proposition | `decide`; `cbv` for evaluation by rewriting | `decide +kernel` for larger instances |
| Property of a recursive function | `fun_induction f args <;> grind` | `fun_cases` for a split without induction |
| "Is there a lemma that closes this?" | `exact?` | prints `exact Lemma args` |
| "What works here at all?" | `try?` | prints several working alternatives, from `simp` to `grind only […]` |
| Verification conditions | `vcgen … with finish` | `finish` is `grind`'s full automation |

Avoid `native_decide` and `decide +native` in verified code: they extend the trusted base to the
compiler, and external kernels cannot replay them. If one is truly needed, it is a decision for
the user and belongs in the review report.

## `grind`

`grind` works like an SMT solver. It keeps a set of known facts, merges equal terms (congruence
closure), instantiates annotated library lemmas when their patterns appear (E-matching), splits
cases, and runs theory solvers for linear integer arithmetic and commutative rings. Every proof
is by contradiction, so hypotheses and goal are treated alike. The standard library is already
annotated, which is why goals about `List`, `Array`, `HashMap` and friends often close unaided.

Working habits:

- **Give it lemmas** it does not know: `grind [myLemma, myDef]`. Passing a definition lets it
  unfold that definition.
- **Minimise once it works** if speed or stability matters: `grind?` prints a `grind only […]`
  call (and an interactive script) listing exactly the lemmas used.
  ```
  Try these:
    [apply] grind only [= List.length_append]
    [apply] grind => instantiate only [= List.length_append]
  ```
- **Annotate your own lemmas** when they should always fire: `@[grind =]` rewrites left to
  right when the left side appears; `@[grind ←]` applies a lemma whose conclusion matches a
  goal; `@[grind →]` propagates forward from matching hypotheses; `@[grind _=_]` rewrites both
  ways. Annotate conservatively: too many annotations make every later call slower or exhaust
  its limits. Lemmas you would mark `@[simp]` are usually good `@[grind =]` candidates.
- **Read failures with `+verbose`.** The plain error says almost nothing. `grind +verbose`
  prints the unsolved subgoal, the facts asserted, the equivalence classes, and for arithmetic
  an assignment that satisfies everything it knows:
  ```
  [eqc] Equivalence classes
    [eqc] {f 0, 1}
  [cutsat] Assignment satisfying linear constraints
    [assign] f 0 := 1
    [assign] f 1 := 2
  ```
  That assignment is either a genuine counterexample (the goal is false) or it violates
  something `grind` was never told (the missing lemma). Either way it tells you what to do.
- **Threshold messages** such as ``reaching the threshold `(ematch := 5)` `` mean a lemma keeps
  instantiating itself. Fix the lemma or its pattern; raising the limit rarely helps.
- **Not for combinatorial search.** Pigeonhole-style goals and large Boolean encodings need
  `bv_decide` or a different formulation.
- `grind =>` opens an interactive mode with its own small tactic language (`instantiate`,
  `cases`, `finish`, …); `sym =>` is the symbolic-simulation variant `vcgen` builds on. Read
  the "Interactive" section of the reference manual's grind chapter for the project's version
  before using them. They were not exercised for this snapshot.

## Ordering when a goal resists

`grind` → `grind [relevant lemmas/defs]` → `grind +verbose` and read it → split the goal by
hand and retry on the pieces → `try?` / `exact?` on the hard piece. Three failures on one piece
means stop and open `stuck.md`.

## Style

- Prefer one robust automated step over a long fragile script; prefer a short script over an
  automated step that takes many seconds.
- Do not squeeze terminal `simp` calls into `simp only` unless there is a measured reason.
- Name hypotheses you refer to later; do not depend on auto-generated names like `h✝` or `a_1`.
- A proof that needs `set_option maxHeartbeats` raised is asking to be restructured.
