module

import PWFA.TorusOscillator
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Candidate spatial weights for the learned mean during retrieval

The [bounded review](../../docs/research/recall-pilot-checks.md#internal-review-of-spatial-weighting-during-retrieval)
compares weighting all learned pairs by cell area with multiplying by the structural kernel.
[ADR-114](../../docs/decisions/ADR-114.md) distinguishes raw and normalized structural
weights. [ADR-123](../../docs/decisions/ADR-123.md) selects a signed pair statistic.
This check operates on one stored row and a snapshot of the phase field.
-/

namespace LearnedSpatialWeights
noncomputable section

open PWFA.TorusOscillator

-- Both candidate rows include cell area exactly once in w. A raw structural
-- row can have mass different from one; the estimate keeps its actual mass.
private def learnedMean {n : Nat} (w memory : Fin n → ℝ) (z : Fin n → ℂ) : ℂ :=
  ∑ j, ((w j * memory j : ℝ) : ℂ) * z j

private theorem bounded_by_row_mass {n : Nat} (w memory : Fin n → ℝ) (z : Fin n → ℂ)
    (hw : ∀ j, 0 ≤ w j) (hm : ∀ j, |memory j| ≤ 1) (hz : ∀ j, ‖z j‖ ≤ 1) :
    ‖learnedMean w memory z‖ ≤ ∑ j, w j := by
  apply (norm_sum_le _ _).trans
  apply Finset.sum_le_sum
  intro j _
  rw [norm_mul, Complex.norm_real, Real.norm_eq_abs, abs_mul, abs_of_nonneg (hw j)]
  calc
    w j * |memory j| * ‖z j‖ ≤ w j * |memory j| * 1 :=
      mul_le_mul_of_nonneg_left (hz j) (mul_nonneg (hw j) (abs_nonneg _))
    _ ≤ w j := by simpa using mul_le_mul_of_nonneg_left (hm j) (hw j)

private theorem uniform_cell_mass {n : Nat} (hn : 0 < n) :
    (∑ _j : Fin n, (1 : ℝ) / n) = 1 := by
  simp [nsmul_eq_mul, Nat.ne_of_gt hn]

-- Two equal-area sites, local recall phase 1 and remote phase i. The two
-- trained rows are compatible with equal or opposite primary training symbols.
private def stored (remote : ℝ) (j : Fin 2) : ℝ := if j = 0 then 1 else remote
private def phases (j : Fin 2) : ℂ := if j = 0 then 1 else Complex.I
private def cellWeight (_ : Fin 2) : ℝ := 1/2
private def structuralWeight (j : Fin 2) : ℝ := if j = 0 then 1 else 0

private theorem dense_mean (m : ℝ) :
    learnedMean cellWeight (stored m) phases = 1/2 + (m : ℂ) * Complex.I / 2 := by
  simp [learnedMean, Fin.sum_univ_two, cellWeight, stored, phases]
  ring

private theorem local_mean (m : ℝ) : learnedMean structuralWeight (stored m) phases = 1 := by
  simp [learnedMean, Fin.sum_univ_two, structuralWeight, stored, phases]

-- A signed row can sum to zero under uniform cell weights while the actual
-- learned complex mean is nonzero. Its cell-area normalization remains defined.
private theorem zero_signed_mass :
    (∑ j, cellWeight j * stored (-1) j) = 0 ∧
    (learnedMean cellWeight (stored (-1)) phases).re = 1/2 := by
  constructor
  · norm_num [Fin.sum_univ_two, cellWeight, stored]
  · rw [dense_mean]
    norm_num [Complex.add_re, Complex.div_ofNat_re, Complex.mul_re]

-- Check the difference at a single snapshot, conditional on adding the learned
-- field to a common structural mean with coefficient g before the existing lag.
-- Neither the value nor the model source of g is an assumption of the example.
private theorem speed_difference (p : Parameters) (base : ℂ) (g : ℝ) :
    angularVelocity p 1 (base + (g : ℂ) * learnedMean cellWeight (stored 1) phases) -
      angularVelocity p 1 (base + (g : ℂ) * learnedMean cellWeight (stored (-1)) phases) =
        p.coupling * g * Real.cos p.phaseLag := by
  rw [dense_mean, dense_mean]
  simp [angularVelocity, Complex.mul_im, Complex.mul_re, Complex.add_im, Complex.add_re,
    Complex.div_ofNat_im, Complex.div_ofNat_re]
  ring

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``bounded_by_row_mass, ``uniform_cell_mass, ``dense_mean, ``local_mean,
      ``zero_signed_mass, ``speed_difference] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end LearnedSpatialWeights
