# Reviewing Lean code and proofs (snapshot: 4.36.0)

A review answers two separate questions, and Lean only helps with the first.

1. **Is it proved?** Mechanical. Section 1.
2. **Does the statement say what it is supposed to say?** Judgment. Sections 2 to 5.

Lean's own documentation classes un-reviewed AI-generated proofs with potentially *malicious*
ones: code that may, without intent, exploit a loophole to make the checker agree. Review them
that way, including proofs you wrote earlier in the same session.

## Contents
1. Is it proved? The trust ladder
2. What axiom checks cannot see
3. The specification audit
4. Probing a specification
5. Lean semantics that mislead
6. Report format

## 1. Is it proved? The trust ladder

Run the rungs in order and stop at the level the stakes call for. Commands tested on 4.36.0.

| Rung | Command | Establishes | Misses |
|---|---|---|---|
| 0 | `lake build` | every file elaborates; kernel accepted each proof | `sorry` is only a *warning*; says nothing of dependencies' gaps |
| 1 | `lake build --wfail` | no warnings at all: no `sorry`, no deprecated syntax | custom axioms, native evaluation |
| 2 | `lake env lean --run <skill>/scripts/AxiomAudit.lean Mod…` (or `#print axioms thm`) | per declaration: which axioms it rests on, classified as sorry / native-eval / custom | anything that needs no axiom (section 2) |
| 3 | `lake check` | rebuilds in a sandbox, exports, replays through the kernel, fails on any non-standard axiom. Exit 0 accepted, 1 rejected, 2 could not run. `--json` for a report | same as rung 2, plus bugs shared by all of Lean's own machinery |
| 4 | `lake check --paranoid` | additionally requires every bundled independent kernel to accept (`con-leche`, `con-ron`, `lean4lean`, `nanoda`) | statement meaning |
| 5 | `lake comparator --paranoid` | the solution's theorems have **exactly the same statements** as a trusted challenge file, use only permitted axioms, and pass all kernels | errors in the trusted challenge itself |

Notes:

- The standard axioms are `propext`, `Classical.choice`, `Quot.sound`. Anything else needs a
  reason. `sorryAx` is an unfinished proof. A name containing `_native` is native evaluation
  (`native_decide`, `decide +native`); `bv_decide` produces these too, and that use is generally
  accepted, but external kernels cannot replay it.
- Rungs 3 to 5 sandbox the build with `bubblewrap`, which exists on **Linux only**. Elsewhere,
  run them in a Linux container or VM, or in CI. `--inadvisably-no-sandbox` removes the
  protection; use it only on code you already trust not to be hostile, and say so in the report.
- Rung 5 needs a `comparator.json` and a challenge module in which each theorem to be judged is
  stated with `sorry` as its proof:

  ```json
  { "challenge_module": "Challenge", "solution_module": "Solution",
    "theorem_names": ["clampTo_bounds"],
    "permitted_axioms": ["propext", "Quot.sound", "Classical.choice"] }
  ```

  Tested: a solution with identical theorem *text* but a redefined `≤` instance is rejected
  with `Challenge and solution theorem statement do not match`. This is the only mechanical
  defence against meaning-shifting. It requires a clean tree (no `.lake`) and a manifest.
- Lean Beam and editor check marks are development aids. Beam states that a ready checkpoint
  may still contain `sorry`. Neither is proof acceptance.
- `scripts/spec_smells.py PATH` is a fast static pre-pass for all of the above plus section 2.

## 2. What axiom checks cannot see

Results from `assets/examples/Defects.lean`, which compiles on 4.36.0:

| Defect | `#print axioms` | Caught by |
|---|---|---|
| D2 custom axiom | shows it | rung 2 |
| D3 `sorry` in a dependency | `sorryAx` | rung 2 |
| D4 `native_decide` | `…_native…` axiom | rung 2 |
| D1 hypothesis nobody can satisfy (`n < 0` on `Nat`) | clean | reading; refuting the hypotheses |
| D5 `instance : LE Money := ⟨fun _ _ => True⟩`, then "balance ≤ limit" | **no axioms at all** | reading instances; rung 5 |
| D6 postcondition satisfied by `return 0` | clean | mutation probe |
| D7 `requires x < 0` | clean | ask for one valid input |
| D8 `throws _ => True` on a function that always throws | clean | reading `throws` |
| D9 `bal - amt ≤ bal` on `Nat` | clean | knowing truncating subtraction |
| D10 `@[implemented_by]`: theorem proves `2 * n`, `#eval` prints `n + 1` | **no axioms at all** | static scan; running the code |

Seven of ten are invisible to every axiom-based check. A green `lake check --paranoid` on a file
like this is entirely consistent with the file being worthless.

## 3. The specification audit

For each theorem or contract that matters, answer in writing:

1. **Restate it in plain language**, from the Lean text only, without reading names or comments.
   A theorem called `balance_never_negative` proves whatever its statement says.
2. **Which definitions does the statement depend on?** Open each one. Then open every
   `instance`, `notation`, `macro`, `syntax`, `open … in`, `local`/`scoped` declaration and
   `set_option` in scope. To see through notation:
   ```lean
   set_option pp.explicit true in #check @thm      -- shows @LE.le Money instLEMoney bal limit
   #print instLEMoney                              -- shows { le := fun x x_1 => True }
   ```
3. **Can the hypotheses be satisfied?** Produce one concrete instance, or prove the negation of
   their conjunction. If the negation is provable, the theorem is vacuous.
4. **Does the conclusion pin the result down?** List the behaviours it permits. Would a constant
   function satisfy it? Returning the input unchanged? An empty result? Always failing?
5. **Is the conclusion about the right thing?** The deployed function, or a model of it? All
   inputs, or the ones a guard happened to cover? Partial correctness (if it returns) or total?
6. **Does the specification restate the implementation?** `ensures r => r = impl x` proves the
   code equals itself. A specification should be written in terms the implementation does not use.
7. **What is missing?** Properties the informal requirement implies and the formal one omits:
   ordering, uniqueness, bounds, preservation of unrelated state, behaviour on error paths.
8. **Is the proved code the code that runs?** `@[implemented_by]`, `@[extern]`, `@[csimp]`,
   `unsafe`, `partial`, FFI.

## 4. Probing a specification

- **Mutation probe** (tested): copy the definition, break the body in an obvious way, keep the
  contract. If it still verifies, the contract is too weak.
  ```lean
  def clampMutant (lo hi x : Nat) : Id Nat
      requires lo ≤ hi
      ensures r => lo ≤ r ∧ r ≤ hi ∧ (lo ≤ x ∧ x ≤ hi → r = x)
    := do return 0
  -- error: unproved verification conditions … ⊢ lo ≤ 0 … ⊢ 0 = x      (good: mutant rejected)
  ```
  Useful mutants: constant result, identity, off-by-one, swapped branches, dropped update,
  always-throw. Delete the mutants afterwards.
- **Negative tests**: for a decidable postcondition, evaluate it on outputs that should be
  rejected. If a wrong output passes, the specification is unsound.
- **Positive tests**: `#eval` the function on known cases and check the postcondition accepts
  them. If a right output fails, the specification is over-constrained (or the code is wrong).
- **Two-sided statement**: the strongest form is usually an `↔` or an equality with a simple
  reference function. One-directional implications are where weak specifications hide.

## 5. Lean semantics that mislead

| Looks like | Actually |
|---|---|
| `a - b` on `Nat` | truncates at zero: `3 - 5 = 0` |
| `a / 0`, `a % 0` | total: `a / 0 = 0`, `a % 0 = a` |
| `xs[i]!`, `.get!`, `.head!` | return the type's default value in the logic; they panic only at run time |
| `xs[i]?` | fine, but check the `none` branch is specified |
| `Fin n`, `UInt8`…`UInt64`, `BitVec w` arithmetic | wraps modulo the size |
| `Float` | IEEE semantics, not real numbers; mostly opaque to automation |
| `=` on functions or structures containing proofs | extensional; `==` (`BEq`) is whatever the instance says, lawful only with `LawfulBEq` |
| `String` length and indexing | counted in code points or bytes depending on the function; check which |
| `partial def f` | an opaque constant; `f x = …` cannot be proved |
| `Id.run do … return …` with early return | the early `return` leaves the whole block, not just the loop |
| `theorem` about `f` where `f` is `@[implemented_by g]` | proof is about `f`; execution is `g` |

## 6. Report format

Lead with the verdict and the evidence behind it. Use this structure:

```
VERDICT: <accept | accept with conditions | reject>   Toolchain: <version>
Proved?   rung reached: <0–5>, command(s) run, result. Axioms beyond the standard three: <list or none>
Meaning?  for each key theorem: one-sentence plain-language reading, and whether that matches intent

FINDINGS (most severe first)
  [severity] file:line  what is wrong, the evidence (command output, counterexample, mutant),
             and the smallest change that would fix it

NOT CHECKED: <what this review did not cover and why: e.g. sandboxed rungs unavailable on this OS>
```

Severity: **blocking** (false, unproved, or meaning differs from the claim), **major** (true
but much weaker than the claim), **minor** (style, fragility, stale idioms). State plainly when
something could not be checked. An honest "not checked" is worth more than an implied pass.
