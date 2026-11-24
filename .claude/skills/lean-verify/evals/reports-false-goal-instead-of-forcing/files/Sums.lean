/-- Sum of a list with an accumulator. -/
def sumTo (xs : List Nat) (acc : Nat) : Nat :=
  match xs with
  | [] => acc
  | x :: rest => sumTo rest (acc + x)

/-- Gauss: the sum of the first n naturals. -/
theorem sumTo_range (n : Nat) : sumTo (List.range n) 0 = n * (n + 1) / 2 := by
  sorry
