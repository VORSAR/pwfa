/-
Backtracking patterns from references/stuck.md, as running code.
Compiled against Lean 4.36.0 (2026-11).  Check with:  lean Backtrack.lean
Expect: `true`, `false`, one deliberate `sorry` warning (the skeleton), and search suggestions.
-/

def sumTo (xs : List Nat) (acc : Nat) : Nat :=
  match xs with
  | [] => acc
  | x :: rest => sumTo rest (acc + x)

-- 1. Falsify before proving: run the claim on small inputs.
#eval (List.range 6).all fun n => sumTo (List.range n) 0 == n * (n - 1) / 2
-- a FALSE claim, caught by evaluation instead of an hour of proof search:
#eval (List.range 6).all fun n => sumTo (List.range n) 0 == n * (n + 1) / 2
-- bounded exhaustive check as a theorem-shaped probe
example : ∀ n : Fin 6, sumTo (List.range n) 0 = n * (n - 1) / 2 := by decide

-- 2. The stuck shape: induction hypothesis too weak because the accumulator is fixed at 0.
--    theorem sumTo_eq (xs : List Nat) : sumTo xs 0 = xs.sum   -- induction on xs gets stuck
--    Backtrack one level: generalise the accumulator, then specialise.
theorem sumTo_acc (xs : List Nat) (acc : Nat) : sumTo xs acc = acc + xs.sum := by
  induction xs generalizing acc with
  | nil => simp [sumTo]
  | cons x rest ih => simp [sumTo, ih]; omega
theorem sumTo_eq (xs : List Nat) : sumTo xs 0 = xs.sum := by
  simpa using sumTo_acc xs 0

-- 3. Skeleton first: the architecture type-checks before any hard step is attempted.
theorem skeleton (xs ys : List Nat) : sumTo (xs ++ ys) 0 = sumTo xs 0 + sumTo ys 0 := by
  have h1 : sumTo (xs ++ ys) 0 = (xs ++ ys).sum := sumTo_eq _
  have h2 : (xs ++ ys).sum = xs.sum + ys.sum := by sorry   -- isolated, named, searchable
  rw [h1, h2, sumTo_eq, sumTo_eq]

-- 4. Ask the search tactics about the isolated step.
example (xs ys : List Nat) : (xs ++ ys).sum = xs.sum + ys.sum := by exact?
example (xs ys : List Nat) : (xs ++ ys).sum = xs.sum + ys.sum := by try?
