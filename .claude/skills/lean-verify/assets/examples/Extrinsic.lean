/-
Extrinsic verification: ordinary definitions, separate theorems.
Compiled against Lean 4.36.0 (2026-11).

Check with:  lean Extrinsic.lean        (expect: no errors, three standard axioms only)
-/
import Std.WP

set_option experimental.vcgen true

namespace LeanVerify.Extrinsic
open Std.WP Lean.Order

/-! ## 1. Pure recursive function: no monad, no vcgen. `fun_induction` + `grind`. -/

def fib : Nat → Nat
  | 0 => 0
  | 1 => 1
  | n + 2 => fib n + fib (n + 1)

theorem fib_pos : ∀ n, 0 < n → 0 < fib n := by
  intro n
  fun_induction fib n <;> grind

/-! ## 2. `Id.run do` with a loop: the statement mentions no monad.
Bridge to a weakest-precondition goal with `Id.of_run_eq_wp`, then `vcgen`. -/

def mySum (l : Array Nat) : Nat := Id.run do
  let mut out := 0
  for i in l do
    out := out + i
  return out

theorem mySum_correct (l : Array Nat) : mySum l = l.sum := by
  generalize h : mySum l = x
  apply Id.of_run_eq_wp h
  vcgen invariants
  · fun pref _suff out => pref.sum = out      -- one bullet per loop, in program order
  with finish                                  -- `finish` = grind on every remaining VC

/-! ## 3. Monadic interface: state the behaviour once as a Hoare triple, register it with
`@[spec]`, and callers are verified against the spec instead of the code (modular proofs). -/

structure Supply where
  counter : Nat

def mkFresh : StateM Supply Nat := do
  let n ← (·.counter) <$> get
  modify fun s => { s with counter := s.counter + 1 }
  pure n

@[spec]
theorem mkFresh_spec (c : Nat) :
    ⦃fun state => state.counter = c⦄
    mkFresh
    ⦃fun r state => r = c ∧ c < state.counter⦄ := by
  vcgen [mkFresh] with finish                  -- `[mkFresh]` unfolds the definition

def mkFreshN (n : Nat) : StateM Supply (List Nat) := do
  let mut acc := #[]
  for _ in [:n] do
    acc := acc.push (← mkFresh)
  pure acc.toList

@[spec]
theorem mkFreshN_spec (n : Nat) :
    ⦃fun _ => True⦄ mkFreshN n ⦃fun r _ => r.Nodup⦄ := by
  vcgen [mkFreshN] invariants                  -- uses mkFresh_spec, never mkFresh's body
  · fun _pref _suff acc state =>
      (∀ x ∈ acc, x < state.counter) ∧ acc.toList.Nodup
  with finish

/-- The run-level statement follows from the spec alone. -/
theorem mkFreshN_correct (n : Nat) (s : Supply) : ((mkFreshN n).run' s).Nodup := by
  generalize h : (mkFreshN n).run' s = x
  apply StateM.of_run'_eq_wp h
  vcgen

#print axioms fib_pos
#print axioms mySum_correct
#print axioms mkFreshN_correct

end LeanVerify.Extrinsic
