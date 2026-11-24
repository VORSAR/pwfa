/-
Intrinsic verification: the contract is part of the definition.
Compiled against Lean 4.36.0 (2026-11). Contracts and `vcgen` are EXPERIMENTAL there:
syntax moved between 4.34, 4.35 and 4.36 and may move again. If this file fails on your
toolchain, that is information — read the error, then `scripts/whats_new.py`.

Check with:  lean Intrinsic.lean        (expect: no errors, three standard axioms only)
-/
import Std.WP

set_option experimental.intrinsic true   -- acknowledge experimental contract syntax
set_option experimental.vcgen true       -- acknowledge experimental vcgen

namespace LeanVerify.Intrinsic

/-- Pure-looking function in `Id`: `requires` states what callers owe, `ensures` what they get.
The last conjunct pins the result down; without it `return lo` would also satisfy the contract. -/
def clamp (lo hi x : Nat) : Id Nat
    requires lo ≤ hi
    ensures r => lo ≤ r ∧ r ≤ hi ∧ (lo ≤ x ∧ x ≤ hi → r = x)
  := do
  if x < lo then return lo
  if x > hi then return hi
  return x

/-- State monad: clause binders name the state. A `for` loop carries its invariant inline;
the invariant ALWAYS binds the consumed prefix and the remaining suffix first, then the state. -/
def sumIntoState (xs : List Nat) : StateM Nat Unit
    requires s => s = 0
    ensures _ s => s = xs.sum
  := do
  for x in xs invariant pref _suff s => s = pref.sum do
    modify (· + x)

/-- Verification conditions that automation leaves open are discharged in `where finally | spec`.
Address them by the case names Lean prints (`vc1`, `vc2`, …); only INACCESSIBLE hypotheses get
names after the case label (here `h`; `acc` is already in scope). -/
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

/-- `while` loops: the invariant is a predicate over the `exit` flag; `decreasing` gives the
termination measure. -/
def countDown (n : Nat) : Id Nat
    ensures r => r = 0 := do
  let mut i := n
  while i > 0
      invariant exit => if exit then i = 0 else True
      decreasing i
    do
    i := i - 1
  return i

/-- `given` binds logical variables shared by the clauses. `throws` binds the exception and, in a
state monad, the state at the throw. Omitting `throws` PROMISES the function never throws. -/
def push (x : Nat) : ExceptT String (StateM (List Nat)) Unit
    given (xs : List Nat)
    requires s => s = xs
    ensures _ s => s = x :: xs
    throws e s => e = "full" ∧ s = xs
  := do
  let s ← get
  if s.length ≥ 3 then throw "full"
  set (x :: s)

-- Each contract generates a `.spec` theorem: a Hoare triple ⦃pre⦄ prog ⦃post; epost⦄.
#check @clamp.spec
#check @push.spec

-- The acceptance test for any of these: only the three standard axioms.
#print axioms clamp.spec
#print axioms sumIntoState.spec
#print axioms sumEvens.spec
#print axioms countDown.spec
#print axioms push.spec

end LeanVerify.Intrinsic
