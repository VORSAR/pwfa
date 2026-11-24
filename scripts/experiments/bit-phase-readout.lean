module

import PWFA.PhaseInverse
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Point-readout experiments for the candidate bit phases

The [origin-anchor decision](../../docs/decisions/ADR-116.md) fixes the complex score.
The [research note](../../docs/research/bit-to-phase-map.md) compares immediate readouts
of phase offsets and two interpretations of a masked cue. These checks have no time evolution.
-/

namespace BitPhaseExperiment

open PWFA.Phase
open scoped ComplexConjugate

noncomputable section

private def score (anchor observation : ℂ) : ℝ := (conj anchor * observation).im

private def offset (anchor : UnitPhase) (amplitude angle : ℝ) : ℂ :=
  (anchor : ℂ) * ((amplitude : ℂ) * Complex.exp ((angle : ℂ) * Complex.I))

private theorem cancel_unit (u : UnitPhase) : conj (u : ℂ) * (u : ℂ) = 1 :=
  congrArg (fun z : UnitPhase => (z : ℂ)) (phaseMul_conj_left u)

-- An error shared by the anchor and observation cancels even for a pooled observation.
private theorem shared_rotation (r : UnitPhase) (a u : ℂ) :
    score ((r : ℂ) * a) ((r : ℂ) * u) = score a u := by
  unfold score
  rw [map_mul, show conj (r : ℂ) * conj a * ((r : ℂ) * u) =
    (conj (r : ℂ) * (r : ℂ)) * (conj a * u) by ring, cancel_unit, one_mul]

private theorem offset_score (a : UnitPhase) (amplitude angle : ℝ) :
    score a (offset a amplitude angle) = amplitude * Real.sin angle := by
  rw [score, offset, ← mul_assoc, cancel_unit, one_mul, Complex.im_ofReal_mul,
    Complex.exp_ofReal_mul_I_im]

-- Both proposed alphabets at their centers, and the conventional 0/π tie.
private theorem ideal_scores (a : UnitPhase) :
    score a (offset a 1 (-(Real.pi / 2))) = -1 ∧
    score a (offset a 1 (Real.pi / 2)) = 1 ∧
    score a (offset a 1 (-(Real.pi / 4))) = -(Real.sqrt 2 / 2) ∧
    score a (offset a 1 (Real.pi / 4)) = Real.sqrt 2 / 2 ∧
    score a (offset a 1 0) = 0 ∧ score a (offset a 1 Real.pi) = 0 := by
  simp [offset_score, Real.sin_pi_div_four]

-- With positive amplitude and zero threshold, every error strictly smaller than θ
-- preserves both bit signs for 0 < θ ≤ π/2. Errors are relative to the moving anchor.
private theorem signs_inside_margin (a : UnitPhase) {ρ θ ε : ℝ}
    (hρ : 0 < ρ) (hθ : θ ≤ Real.pi / 2) (hε : |ε| < θ) :
    0 < score a (offset a ρ (θ + ε)) ∧ score a (offset a ρ (-θ + ε)) < 0 := by
  obtain ⟨hl, hr⟩ := abs_lt.mp hε
  simp only [offset_score]
  constructor
  · exact mul_pos hρ (Real.sin_pos_of_pos_of_lt_pi (by linarith) (by linarith))
  · rw [show -θ + ε = -(θ - ε) by ring, Real.sin_neg]
    exact mul_neg_of_pos_of_neg hρ (neg_lt_zero.mpr
      (Real.sin_pos_of_pos_of_lt_pi (by linarith) (by linarith)))

private theorem tie_at_margin (a : UnitPhase) (ρ θ : ℝ) :
    score a (offset a ρ (θ + -θ)) = 0 ∧ score a (offset a ρ (-θ + θ)) = 0 := by
  simp [offset_score]

-- Sampling a single phase has unit amplitude. The equal mean of two opposite
-- observations vanishes and carries no signed evidence, even with an exact anchor.
private theorem pooled_tie (a : UnitPhase) (u : ℂ) : score a ((u + -u) / 2) = 0 := by
  simp [score]

-- This model of *cue preparation* treats omission as retaining the current local
-- phase. An explicit anchor write can overwrite it. Both preparations are unit-valued.
private def prepare (background : UnitPhase) (write : Option UnitPhase) : UnitPhase :=
  write.getD background

private theorem mask_preparations_equal (a background : UnitPhase) :
    prepare background none = prepare background (some a) ↔ background = a := Iff.rfl

-- ADR-120 starts the primary condition at one common phase, including the origin.
-- Omission therefore gives zero signed point score regardless of the common angle.
private theorem uniform_omission_score (a : UnitPhase) :
    score a (prepare a none) = 0 := by
  change (conj (a : ℂ) * (a : ℂ)).im = 0
  rw [cancel_unit, Complex.one_im]

private theorem different_mask_scores :
    let a := phaseOne
    let background : UnitPhase := ⟨Complex.I, Complex.norm_I⟩
    score a (prepare background none) = 1 ∧ score a (prepare background (some a)) = 0 := by
  simp [score, prepare, phaseOne]

-- Match the project's existing phase audit allowlist for every reported conclusion.
run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``shared_rotation, ``offset_score, ``ideal_scores, ``signs_inside_margin,
      ``tie_at_margin, ``pooled_tie, ``mask_preparations_equal, ``uniform_omission_score, ``different_mask_scores] do
    let axioms ← Lean.collectAxioms name
    unless axioms.all (fun ax => allowed.contains ax) do
      throwError "{name} has unexpected dependencies: {axioms}"

end

end BitPhaseExperiment
