# Verifying programs in Lean (snapshot: 4.36.0)

Every code block here was compiled on Lean 4.36.0. The full files are in `assets/examples/`
(`Intrinsic.lean`, `Extrinsic.lean`); recompile them when the toolchain differs. Contracts and
`vcgen` are **experimental**: expect syntax to move, and trust the compiler over this page.

## Contents
1. Setup
2. Choosing a style
3. Intrinsic contracts
4. Extrinsic proofs with `vcgen`
5. Hoare triples and the assertion language
6. Invariants
7. Pure functions without a monad
8. Errors you will meet
9. What a verified contract does not cover

## 1. Setup

```lean
import Std.WP                             -- provides vcgen on its own since 4.36

set_option experimental.intrinsic true    -- acknowledges contract syntax; silences its warning
set_option experimental.vcgen true        -- acknowledges vcgen; silences its warning
open Std.WP Lean.Order                    -- needed for extrinsic proofs (triples, invariants)
```

Requires 4.35 or newer for `vcgen`, 4.34 for contracts, 4.36 for `throws`. No Mathlib needed.
On 4.35, and in the official tutorial, `import Std.Tactic.Do` appears as well; add it if a name
is missing.

## 2. Choosing a style

| Situation | Style |
|---|---|
| New effectful code (`do`, loops, state, exceptions) whose contract is part of its interface | **Intrinsic**: clauses on the `def` |
| Existing code you may not edit; several independent properties of one function; properties relating two functions | **Extrinsic**: separate theorems, `vcgen` |
| Pure structural or recursive function, no loops | **Plain theorem**: `fun_induction`, `grind` (section 7) |
| A callee used by many verified callers | Give it a specification once (contract or `@[spec]`); callers never unfold it |

Intrinsic keeps code and claim together and fails the build when they diverge. Extrinsic keeps
definitions clean and lets a statement mention no monad at all. Both produce ordinary theorems
checked by the kernel.

## 3. Intrinsic contracts

```lean
def clamp (lo hi x : Nat) : Id Nat
    requires lo ≤ hi
    ensures r => lo ≤ r ∧ r ≤ hi ∧ (lo ≤ x ∧ x ≤ hi → r = x)
  := do
  if x < lo then return lo
  if x > hi then return hi
  return x
```

- Clause order: `given`, `requires`, `ensures`, `throws`, then `:=`.
- Each clause elaborates like a `fun`: `ensures r => …` binds the result; in a state monad the
  state follows (`requires s => …`, `ensures r s => …`); tuple patterns work
  (`ensures (lo, hi) => lo ≤ hi`); binders may carry type ascriptions.
- A contract generates `f.spec`, a Hoare triple. `#check @clamp.spec` shows it.
- Verification conditions that automation cannot close are an **error** on the `def`. Discharge
  them after the body:

```lean
def sumEvens (xs : List Nat) : Id Nat
    ensures r => ∃ k, r = 2 * k
  := do
  let mut acc := 0
  for x in xs invariant _pref _suff => acc % 2 = 0 do
    acc := acc + 2 * x
  return acc
where finally
  | spec =>
    case vc1 h => exact ⟨acc / 2, by omega⟩
```

  The `spec` block is an ordinary tactic block run on whatever is left. Use the case names Lean
  prints. After the case name, supply names only for the *inaccessible* hypotheses (shown with
  `✝`); variables such as `acc` are already in scope.

- State, logical variables and exceptions:

```lean
def push (x : Nat) : ExceptT String (StateM (List Nat)) Unit
    given (xs : List Nat)                 -- logical variable shared by the clauses
    requires s => s = xs
    ensures _ s => s = x :: xs
    throws e s => e = "full" ∧ s = xs     -- exception, and the state at the throw
  := do
  let s ← get
  if s.length ≥ 3 then throw "full"
  set (x :: s)
```

  **Omitting `throws` promises the function never throws** (the exception postcondition is `⊥`),
  and Lean checks that promise. With several exception layers, ascribe the binder to select one:
  `throws (e : Nat) => …`.

- Inside the body: `assert P` (or `assert s => P s`) states a fact that becomes a VC and does
  nothing at run time. From 4.35, `erased x := e` declares verification-only variables.

## 4. Extrinsic proofs with `vcgen`

`vcgen` works on a weakest-precondition goal. For a statement about the *result* of running a
monadic program, bridge first:

```lean
theorem mySum_correct (l : Array Nat) : mySum l = l.sum := by
  generalize h : mySum l = x
  apply Id.of_run_eq_wp h                 -- StateM: `StateM.of_run'_eq_wp`
  vcgen invariants
  · fun pref _suff out => pref.sum = out  -- one bullet per loop, in program order
  with finish                             -- run grind's full automation on every remaining VC
```

Forms of the tactic:

| Form | Meaning |
|---|---|
| `vcgen` | generate VCs; then prove them by name (`case inv1 => exact …`, `case vc1 => …`) |
| `vcgen [f, g_spec]` | also unfold definition `f` and use specification `g_spec`; accepts terms like `simp [...]` does |
| `vcgen invariants · inv₁ · inv₂` | supply loop invariants up front |
| `vcgen … with finish` / `with <tactic>` | discharge every remaining VC with `grind` or the given tactic |

Modular verification: state a callee's behaviour once and register it.

```lean
@[spec]
theorem mkFresh_spec (c : Nat) :
    ⦃fun state => state.counter = c⦄ mkFresh ⦃fun r state => r = c ∧ c < state.counter⦄ := by
  vcgen [mkFresh] with finish
```

After this, any `vcgen` over a caller uses `mkFresh_spec` and never looks at `mkFresh`'s body.
A specification may deliberately say less than the code does (here: "the counter grew", not
"by exactly one"); that keeps callers' proofs stable when the implementation changes.

## 5. Hoare triples and the assertion language

- `⦃P⦄ prog ⦃Q⦄` means: if `P` holds before, `Q` holds of the result (and state) after, and
  `prog` does not throw. `⦃P⦄ prog ⦃Q; E⦄` adds an exception postcondition `E`.
- The shape of an assertion depends on the monad: a plain `Prop` for `Id`; a function of the
  state for `StateM σ` (`fun s => …`); one more argument per `StateT`/`ReaderT` layer.
- `⌜p⌝` embeds a pure proposition that ignores remaining state arguments. You need it when the
  monad has more layers than your binder list covers.
- `Triple` is defined as `pre ⊑ wp prog post epost`; `⊑` is the order of the assertion lattice
  (pointwise implication for state predicates). `⊤`/`⊥` are its top and bottom.
- Since 4.35 the same machinery covers any program type with a `WP` instance, including the
  syntax tree of a deeply embedded language. See the reference manual's vcgen chapter
  ("Enabling vcgen for monads") before attempting this; it was not exercised for this snapshot.

## 6. Invariants

- **`for` loops**: `fun pref suff <mutable vars…> <state…> => …`. `pref` is what the loop has
  consumed, `suff` what remains. Good invariants relate the mutable variables to `pref`.
- **Early `return`/`break` inside a loop** (extrinsic style):

```lean
vcgen invariants
· Invariant.withEarlyReturnNewDo
    (onReturn := fun ret seen => ret = false ∧ ¬l.Nodup)
    (onContinue := fun pref suff seen => (∀ x, x ∈ seen ↔ x ∈ pref) ∧ pref.Nodup)
with finish
```

- **`while`/`repeat`** (intrinsic): `invariant exit => …` over the exit flag, plus
  `decreasing <measure>` for termination.
- An invariant must hold on entry (one VC), be preserved by the body (one VC), and imply what
  follows the loop (one VC). When one fails, that tells you which way the invariant is wrong.
  See `stuck.md`, ladder L3.
- Loops over hash maps, tree maps, sets, ranges, slices and iterators are supported; a custom
  container needs a `PureForIn` instance or its own `@[spec]` loop lemma.

## 7. Pure functions without a monad

```lean
theorem fib_pos : ∀ n, 0 < n → 0 < fib n := by
  intro n
  fun_induction fib n <;> grind
```

`fun_induction f args` gives one case per branch of `f`'s definition with the right induction
hypotheses; `fun_cases` does the case split without induction. Neither sees inside a `forIn`
loop, which is where `vcgen` takes over.

## 8. Errors you will meet

All observed on 4.36.0.

| Message | Cause | Fix |
|---|---|---|
| `unproved verification conditions for the contract of 'f'; discharge them in a 'where finally \| spec => ...' section` | automation could not close a VC | Read the printed VC. Decide first whether it is *true* (`stuck.md` step 1). Then add the `spec` block |
| VC of the form `⊢ ⊥ "msg"` | the body can throw and the contract has no `throws` clause | add `throws`, or remove the throwing path |
| ``The `invariant` clause takes at least two binders`` | old one-binder invariant form | `invariant pref suff => …` |
| `too many variable names provided` at `case vcN a b =>` | named a variable that is already accessible | name only the `✝` hypotheses |
| `typeclass instance problem is stuck … Std.WP.EPostSlot` | exception binder's type not determined | `throws (e : String) => …` |
| ``syntax 'Lean.Parser.Tactic.mvcgen' has been deprecated: use `vcgen` instead`` | stale idiom | migrate; see `freshness.md` |
| `vcgen: could not determine the program type of the goal` | goal is not a `wp`/triple goal | apply the bridge lemma first (`Id.of_run_eq_wp`, `StateM.of_run'_eq_wp`) |
| warnings that the intrinsic syntax or `vcgen` is experimental | options not set | the two `set_option` lines in section 1 |

A contract whose proof failed still *defines* `f.spec`, resting on `sorryAx`. The build error is
the signal; a later `#check f.spec` succeeding proves nothing. Always finish with the axiom audit.

## 9. What a verified contract does not cover

- **Whether the contract is the right one.** See `review.md`: weak postconditions,
  unsatisfiable preconditions and `throws … => True` all verify happily.
- **Code replaced at run time**: `@[implemented_by]` and `@[extern]` swap the compiled
  implementation with no proof obligation.
- **`partial def`**: opaque to the logic; nothing about its result can be proved.
- **Panics**: `xs[i]!`, `.get!` and friends return a default value in the logic.
- **Resources**: time, memory, stack depth, and anything outside the Lean model (I/O, FFI).
