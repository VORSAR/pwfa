/-- Tail-recursive list reversal with an accumulator. -/
def revAcc : List α → List α → List α
  | [], acc => acc
  | x :: xs, acc => revAcc xs (x :: acc)

/-- The fast reversal agrees with the library's. -/
theorem revAcc_eq_reverse (xs : List α) : revAcc xs [] = xs.reverse := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    -- stuck here: ih is about `revAcc xs []` but the goal has `revAcc xs [x]`
    sorry
