module

public import PWFA.TorusMeanField

/-!
# Local Lipschitz bound for the oscillator

The norm estimate follows the computation of velocity. First compare means, then angular
speeds, then tangent velocities. Bounding both input fields on one ball gives a common
Lipschitz constant for the local existence theorem.

[Specification](../docs/decisions/ADR-110.md) · [Scope and evidence](../docs/verification/slices/torus-oscillator-baseline.md#internal-review-of-the-velocity-bound)
-/

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus MeasureTheory
open scoped ComplexConjugate NNReal Topology

noncomputable section

private theorem lag_norm (α : ℝ) :
    ‖Complex.mk (Real.cos α) (-Real.sin α)‖ = 1 := by
  rw [← sq_eq_sq₀ (norm_nonneg _) zero_le_one, Complex.sq_norm, Complex.normSq_apply]
  change Real.cos α * Real.cos α + (-Real.sin α) * (-Real.sin α) = 1 ^ 2
  nlinarith [Real.cos_sq_add_sin_sq α]

private theorem norm_mul_sub_mul_le (a b c d : ℂ) :
    ‖a * b - c * d‖ ≤ ‖a - c‖ * ‖b‖ + ‖c‖ * ‖b - d‖ := by
  rw [show a * b - c * d = (a - c) * b + c * (b - d) by ring]
  simpa only [norm_mul] using norm_add_le ((a - c) * b) (c * (b - d))

private theorem norm_angularVelocity_le (p : Parameters) (z m : ℂ) :
    ‖angularVelocity p z m‖ ≤ ‖p.frequency‖ + ‖p.coupling‖ * (‖z‖ * ‖m‖) := by
  let lag : ℂ := Complex.mk (Real.cos p.phaseLag) (-Real.sin p.phaseLag)
  change ‖p.frequency + p.coupling * (lag * conj z * m).im‖ ≤ _
  refine (norm_add_le _ _).trans ?_
  rw [norm_mul]
  apply add_le_add le_rfl
  refine mul_le_mul_of_nonneg_left ?_ (norm_nonneg _)
  calc
    ‖(lag * conj z * m).im‖ ≤ ‖lag * conj z * m‖ := by
      simpa only [Real.norm_eq_abs] using Complex.abs_im_le_norm _
    _ = ‖z‖ * ‖m‖ := by
      simp only [norm_mul, lag, lag_norm, Complex.norm_conj, one_mul]

private theorem norm_angularVelocity_sub_le (p : Parameters) (z m w n : ℂ) :
    ‖angularVelocity p z m - angularVelocity p w n‖ ≤
      ‖p.coupling‖ * (‖z - w‖ * ‖m‖ + ‖w‖ * ‖m - n‖) := by
  let lag : ℂ := Complex.mk (Real.cos p.phaseLag) (-Real.sin p.phaseLag)
  have heq : angularVelocity p z m - angularVelocity p w n =
      p.coupling * (lag * (conj z * m - conj w * n)).im := by
    unfold angularVelocity
    change (p.frequency + p.coupling * (lag * conj z * m).im) -
      (p.frequency + p.coupling * (lag * conj w * n).im) = _
    rw [mul_sub, Complex.sub_im, ← mul_assoc, ← mul_assoc]
    ring
  rw [heq, norm_mul]
  refine mul_le_mul_of_nonneg_left ?_ (norm_nonneg _)
  calc
    ‖(lag * (conj z * m - conj w * n)).im‖ ≤ ‖lag * (conj z * m - conj w * n)‖ := by
      simpa only [Real.norm_eq_abs] using Complex.abs_im_le_norm _
    _ = ‖conj z * m - conj w * n‖ := by simp only [norm_mul, lag, lag_norm, one_mul]
    _ ≤ ‖z - w‖ * ‖m‖ + ‖w‖ * ‖m - n‖ := by
      simpa only [← map_sub, Complex.norm_conj] using norm_mul_sub_mul_le (conj z) m (conj w) n

private theorem norm_pointVelocity_sub_le (p : Parameters) (z m w n : ℂ) :
    ‖pointVelocity p z m - pointVelocity p w n‖ ≤
      ‖z - w‖ * ‖angularVelocity p z m‖ + ‖w‖ * ‖angularVelocity p z m - angularVelocity p w n‖ := by
  unfold pointVelocity
  rw [mul_assoc, mul_assoc, ← mul_sub, norm_mul, Complex.norm_I, one_mul]
  simpa only [← Complex.ofReal_sub, Complex.norm_real] using
    norm_mul_sub_mul_le z (angularVelocity p z m) w (angularVelocity p w n)

theorem norm_continuousRhs_sub_le (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) {M : ℝ}
    {z w : Field} (hz : ‖z‖ ≤ M) (hw : ‖w‖ ≤ M) :
    ‖continuousRhs p kernel h hrow z - continuousRhs p kernel h hrow w‖ ≤
      (‖p.frequency‖ + 3 * ‖p.coupling‖ * M ^ 2 * (∫ u, ‖kernel 0 u‖ ∂area)) * ‖z - w‖ := by
  let L := ∫ u, ‖kernel 0 u‖ ∂area
  have hL : 0 ≤ L := integral_nonneg fun _ => norm_nonneg _
  have hM : 0 ≤ M := (norm_nonneg z).trans hz
  apply (ContinuousMap.norm_le_of_nonempty _).2
  intro x
  let m := meanField kernel z x
  let n := meanField kernel w x
  have hzx : ‖z x‖ ≤ M := (z.norm_coe_le_norm x).trans hz
  have hwx : ‖w x‖ ≤ M := (w.norm_coe_le_norm x).trans hw
  have hzwd : ‖z x - w x‖ ≤ ‖z - w‖ := (z - w).norm_coe_le_norm x
  have hm : ‖m‖ ≤ L * M :=
    (norm_meanField_le h hrow z x).trans (mul_le_mul_of_nonneg_left hz hL)
  -- Compare both mean fields with the same linear operator before bounding the speed difference.
  have hmn : ‖m - n‖ ≤ L * ‖z - w‖ := by
    simpa only [ContinuousMap.sub_apply, meanOperator_apply] using
      (((meanOperator kernel h hrow z) - (meanOperator kernel h hrow w)).norm_coe_le_norm x).trans
        (norm_meanOperator_sub_le kernel h hrow z w)
  have hs : ‖angularVelocity p (z x) m‖ ≤ ‖p.frequency‖ + ‖p.coupling‖ * (M * (L * M)) := by
    refine (norm_angularVelocity_le p (z x) m).trans ?_
    gcongr
  have hsd : ‖angularVelocity p (z x) m - angularVelocity p (w x) n‖ ≤
      ‖p.coupling‖ * (‖z - w‖ * (L * M) + M * (L * ‖z - w‖)) := by
    refine (norm_angularVelocity_sub_le p (z x) m (w x) n).trans ?_
    gcongr
  change ‖pointVelocity p (z x) m - pointVelocity p (w x) n‖ ≤
    (‖p.frequency‖ + 3 * ‖p.coupling‖ * M ^ 2 * L) * ‖z - w‖
  calc
    _ ≤ ‖z x - w x‖ * ‖angularVelocity p (z x) m‖ +
        ‖w x‖ * ‖angularVelocity p (z x) m - angularVelocity p (w x) n‖ :=
      norm_pointVelocity_sub_le p (z x) m (w x) n
    _ ≤ ‖z - w‖ * (‖p.frequency‖ + ‖p.coupling‖ * (M * (L * M))) +
        M * (‖p.coupling‖ * (‖z - w‖ * (L * M) + M * (L * ‖z - w‖))) := by
      gcongr
    _ = _ := by ring

theorem lipschitzOnWith_continuousRhs (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) (M : ℝ) :
    ∃ K : ℝ≥0, LipschitzOnWith K (continuousRhs p kernel h hrow) (Metric.closedBall 0 M) := by
  have hL : 0 ≤ ∫ u, ‖kernel 0 u‖ ∂area := integral_nonneg fun _ => norm_nonneg _
  refine ⟨⟨‖p.frequency‖ + 3 * ‖p.coupling‖ * M ^ 2 * (∫ u, ‖kernel 0 u‖ ∂area),
    by positivity⟩, LipschitzOnWith.of_dist_le_mul ?_⟩
  intro z hz w hw
  have hz' : ‖z‖ ≤ M := by simpa using Metric.mem_closedBall.mp hz
  have hw' : ‖w‖ ≤ M := by simpa using Metric.mem_closedBall.mp hw
  change dist (continuousRhs p kernel h hrow z) (continuousRhs p kernel h hrow w) ≤
    (‖p.frequency‖ + 3 * ‖p.coupling‖ * M ^ 2 * (∫ u, ‖kernel 0 u‖ ∂area)) * dist z w
  simpa only [dist_eq_norm] using norm_continuousRhs_sub_le p h hrow hz' hw'

end

end PWFA.TorusOscillator
