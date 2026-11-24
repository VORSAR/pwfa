import Std.Tactic.Do
open Std.Do

/-- Adds `x` to the counter held in the state. -/
def addTo (x : Nat) : StateM Nat Unit := modify (· + x)

/-- Adds every element of `xs` to the counter. -/
def addAll (xs : List Nat) : StateM Nat Unit := do
  for x in xs do
    addTo x

theorem addTo_spec (x n : Nat) :
    ⦃fun s => ⌜s = n⌝⦄ addTo x ⦃⇓ _ s => ⌜s = n + x⌝⦄ := by
  mvcgen [addTo]
  grind

theorem addAll_spec (xs : List Nat) (n : Nat) :
    ⦃fun s => ⌜s = n⌝⦄ addAll xs ⦃⇓ _ s => ⌜s = n + xs.sum⌝⦄ := by
  mvcgen [addAll, addTo_spec]
  case inv1 => exact ⇓⟨cur, _⟩ s => ⌜s = n + cur.prefix.sum⌝
  all_goals grind
