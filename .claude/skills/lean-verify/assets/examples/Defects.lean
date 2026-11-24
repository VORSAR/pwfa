/-
Review calibration: every declaration below is ACCEPTED by Lean 4.36.0, and every one is a defect.
The comment on each says which check exposes it. Use this file to confirm that your review
tooling still behaves as documented on the current toolchain:

  lean Defects.lean                                   -- compiles (one `sorry` warning)
  python3 ../../scripts/spec_smells.py Defects.lean   -- static leads
  -- in a Lake project:  lake env lean --run scripts/AxiomAudit.lean <Module>

Axiom-visible:   D2 D3 D4          (caught by `#print axioms` / AxiomAudit / `lake check`)
Axiom-INVISIBLE: D1 D5 D6 D7 D8 D9 D10 (clean axioms; only reading the statement catches them)
-/
import Std.WP
set_option experimental.intrinsic true
set_option experimental.vcgen true

namespace LeanVerify.Defects

/-- D1 vacuous hypothesis: no `n : Nat` satisfies `n < 0`, so anything follows.
Exposed by: trying to prove the negation of the hypotheses (`example : ¬ (n < 0) := by omega`). -/
theorem d1 (n : Nat) (h : n < 0) : n * n = 12345 := by omega

/-- D2 custom axiom. Exposed by: `#print axioms` (lists `d2_helper`). -/
axiom d2_helper : ∀ n : Nat, n = n ∧ (0 : Nat) = 0
theorem d2 : (0 : Nat) = 0 := (d2_helper 0).2

/-- D3 `sorry` in a dependency: `d3` itself has no warning on its own line.
Exposed by: `#print axioms d3` (lists `sorryAx`). -/
theorem d3_lemma (xs : List Nat) : xs.reverse.reverse = xs := by sorry
theorem d3 (xs : List Nat) : xs.reverse.reverse.length = xs.length := by rw [d3_lemma]

/-- D4 native evaluation: trusts the compiler; external kernels cannot replay it.
Exposed by: `#print axioms` (an axiom with `_native` in its name). -/
theorem d4 : (List.range 1000).foldl (· + ·) 0 = 499500 := by native_decide

/-- D5 the statement does not mean what it says: `≤` on `Money` was defined to be always true.
Exposed by: reading every `instance` the statement resolves through; `lake comparator`. -/
structure Money where
  cents : Nat
instance : LE Money := ⟨fun _ _ => True⟩
theorem d5_balance_never_exceeds_limit (bal limit : Money) : bal ≤ limit := trivial

/-- D6 weak postcondition: the contract holds for an implementation that ignores its input.
Exposed by: a mutation probe (would an obviously wrong body satisfy the same contract? yes). -/
def d6_clamp (lo hi _x : Nat) : Id Nat
    ensures r => r ≤ hi ∨ lo > hi
  := do
  return 0

/-- D7 unsatisfiable precondition: the contract constrains no real call.
Exposed by: asking for one concrete input that satisfies `requires`. -/
def d7 (x : Nat) : Id Nat
    requires x < 0
    ensures r => r = 42
  := do
  return x

/-- D8 exception postcondition `True`: "returns x + 1" is promised only when it returns at all.
Exposed by: reading `throws`; asking what the contract says about the failing path. -/
def d8 (x : Nat) : Except String Nat
    ensures r => r = x + 1
    throws (_e : String) => True
  := do
  throw "nope"

/-- D9 truncating subtraction: on `Nat`, `a - b = 0` whenever `a ≤ b`. The theorem is true and
says nothing like "the balance after withdrawal is correct".
Exposed by: knowing Lean's arithmetic; `#eval (3 - 5 : Nat)`. -/
theorem d9_withdraw_ok (bal amt : Nat) : bal - amt ≤ bal := by omega

/-- D10 the proved function is not the function that runs: `@[implemented_by]` swaps the
compiled code with no proof obligation.
Exposed by: static scan for `implemented_by` / `extern`; `#eval` against the model. -/
def d10_fastImpl (n : Nat) : Nat := n + 1
@[implemented_by d10_fastImpl] def d10_double (n : Nat) : Nat := 2 * n
theorem d10_double_correct (n : Nat) : d10_double n = 2 * n := rfl

#print axioms d1
#print axioms d2
#print axioms d3
#print axioms d4
#print axioms d5_balance_never_exceeds_limit
#print axioms d6_clamp.spec
#print axioms d7.spec
#print axioms d8.spec
#print axioms d9_withdraw_ok
#print axioms d10_double_correct
#eval d10_double 5     -- prints 6, although `d10_double_correct` proves it is 10

end LeanVerify.Defects
