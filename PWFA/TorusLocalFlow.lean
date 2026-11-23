module

public import PWFA.TorusVelocityBound
public import Mathlib.Analysis.ODE.ExistUnique

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus Filter MeasureTheory Set
open scoped NNReal Topology

noncomputable section

private theorem rhs_zero (p : Parameters) (kernel : Point → Point → ℝ)
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) :
    continuousRhs p kernel h hrow 0 = 0 := by
  ext x
  simp [continuousRhs, baselineRhs, pointVelocity]

/-- The torus oscillator admits a differentiable solution near the initial time. -/
theorem exists_local_solution (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) (initial : Field) :
    ∃ ε > (0 : ℝ), ∃ solution : ℝ → Field, solution 0 = initial ∧
      ∀ t ∈ Ioo (-ε) ε,
        HasDerivAt solution (continuousRhs p kernel h hrow (solution t)) t := by
  let rhs := continuousRhs p kernel h hrow
  let M : ℝ≥0 := ‖initial‖₊ + 1
  obtain ⟨K, hK⟩ := lipschitzOnWith_continuousRhs p h hrow (M : ℝ)
  change LipschitzOnWith K rhs (Metric.closedBall 0 (M : ℝ)) at hK
  have hsub : Metric.closedBall initial 1 ⊆ Metric.closedBall 0 (M : ℝ) := by
    intro x hx
    apply Metric.mem_closedBall.mpr
    calc
      dist x 0 ≤ dist x initial + dist initial 0 := dist_triangle _ _ _
      _ ≤ (M : ℝ) := by
        simpa [M, dist_zero_right, add_comm] using
          add_le_add_right (Metric.mem_closedBall.mp hx) (‖initial‖ : ℝ)
  let B : ℝ≥0 := K * M
  have hbound : ∀ x ∈ Metric.closedBall initial 1, ‖rhs x‖ ≤ (B : ℝ) := by
    intro x hx
    have hzero : rhs 0 = 0 := rhs_zero p kernel h hrow
    have hzeroMem : (0 : Field) ∈ Metric.closedBall 0 (M : ℝ) :=
      Metric.mem_closedBall_self M.2
    have hdist := hK.dist_le_mul x (hsub hx) 0 hzeroMem
    simp only [hzero, dist_zero_right] at hdist
    have hxnorm : ‖x‖ ≤ (M : ℝ) := by simpa using Metric.mem_closedBall.mp (hsub hx)
    exact hdist.trans (mul_le_mul_of_nonneg_left hxnorm K.2)
  let ε : ℝ := (1 + (B : ℝ))⁻¹
  have hε : 0 < ε := by dsimp [ε]; positivity
  have htime : (B : ℝ) * ε ≤ 1 := by
    dsimp [ε]
    rw [← div_eq_mul_inv, div_le_one (by positivity)]
    linarith
  let time0 : Icc (-ε) ε := ⟨0, ⟨by linarith, hε.le⟩⟩
  have hPicard : IsPicardLindelof (fun _ => rhs) time0 initial 1 0 B K := by
    constructor
    · intro _ _
      exact hK.mono hsub
    · intro _ _
      exact continuousOn_const
    · intro _ _ x hx
      exact hbound x hx
    · simpa [time0] using htime
  obtain ⟨solution, hinit, hsol⟩ := hPicard.exists_eq_forall_mem_Icc_hasDerivWithinAt₀
  refine ⟨ε, hε, solution, hinit, fun t ht => ?_⟩
  exact (hsol t ⟨ht.1.le, ht.2.le⟩).hasDerivAt (Icc_mem_nhds ht.1 ht.2)

/-- Solutions with the same initial field agree near the initial time. -/
theorem local_solution_unique (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area)
    {z w : ℝ → Field} (hinitial : z 0 = w 0)
    (hz : ∀ᶠ t in 𝓝 0, HasDerivAt z (continuousRhs p kernel h hrow (z t)) t)
    (hw : ∀ᶠ t in 𝓝 0, HasDerivAt w (continuousRhs p kernel h hrow (w t)) t) :
    z =ᶠ[𝓝 0] w := by
  let M := ‖z 0‖ + 1
  obtain ⟨K, hK⟩ := lipschitzOnWith_continuousRhs p h hrow M
  have hball : Metric.closedBall (0 : Field) M ∈ 𝓝 (z 0) := by
    apply mem_of_superset (Metric.isOpen_ball.mem_nhds ?_) Metric.ball_subset_closedBall
    rw [Metric.mem_ball, dist_zero_right]
    dsimp [M]
    linarith
  have zmem : ∀ᶠ t in 𝓝 0, z t ∈ Metric.closedBall (0 : Field) M :=
    hz.self_of_nhds.continuousAt.eventually hball
  have wmem : ∀ᶠ t in 𝓝 0, w t ∈ Metric.closedBall (0 : Field) M :=
    hw.self_of_nhds.continuousAt.eventually (hinitial ▸ hball)
  exact ODE_solution_unique_of_eventually
    (v := fun _ => continuousRhs p kernel h hrow)
    (s := fun _ => Metric.closedBall 0 M)
    (Eventually.of_forall fun _ => hK) (hz.and zmem) (hw.and wmem) hinitial

end

end PWFA.TorusOscillator
