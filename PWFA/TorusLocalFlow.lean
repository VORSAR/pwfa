module

public import PWFA.TorusVelocityBound
public import Mathlib.Analysis.InnerProductSpace.Calculus
public import Mathlib.Analysis.ODE.ExistUnique

/-!
# Local trajectories in the space of continuous fields

Picard iteration produces a common time window for initial fields with a given norm bound.
Evaluating the resulting trajectory at a torus point turns tangency into zero derivative of
the squared modulus. Unit initial fields therefore remain unit on that interval.

[Specification](../docs/decisions/ADR-110.md) · [Scope and evidence](../docs/verification/slices/torus-oscillator-baseline.md#internal-review-of-local-solutions)
-/

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus Filter MeasureTheory Set
open scoped ComplexConjugate NNReal Topology

noncomputable section

private theorem rhs_zero (p : Parameters) (kernel : Point → Point → ℝ)
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) :
    continuousRhs p kernel h hrow 0 = 0 := by
  ext x
  simp [continuousRhs, baselineRhs, pointVelocity]

/-- A common local existence interval for all initial fields in a bounded ball. -/
theorem exists_uniform_local_solution (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) (A : ℝ≥0) :
    ∃ ε > (0 : ℝ), ∀ initial : Field, ‖initial‖ ≤ A →
      ∃ solution : ℝ → Field, solution 0 = initial ∧ ∀ t ∈ Ioo (-ε) ε,
        HasDerivAt solution (continuousRhs p kernel h hrow (solution t)) t := by
  let rhs := continuousRhs p kernel h hrow
  let M : ℝ≥0 := A + 1
  obtain ⟨K, hK⟩ := lipschitzOnWith_continuousRhs p h hrow (M : ℝ)
  change LipschitzOnWith K rhs (Metric.closedBall 0 (M : ℝ)) at hK
  let B : ℝ≥0 := K * M
  -- Adding one gives a positive time even for a zero velocity bound and keeps displacement ≤ 1.
  let ε : ℝ := (1 + (B : ℝ))⁻¹
  have hε : 0 < ε := by dsimp [ε]; positivity
  have htime : (B : ℝ) * ε ≤ 1 := by
    dsimp [ε]
    rw [← div_eq_mul_inv, div_le_one (by positivity)]
    linarith
  refine ⟨ε, hε, ?_⟩
  intro initial hA
  have hsub : Metric.closedBall initial 1 ⊆ Metric.closedBall 0 (M : ℝ) := by
    intro x hx
    apply Metric.mem_closedBall.mpr
    calc
      dist x 0 ≤ dist x initial + dist initial 0 := dist_triangle _ _ _
      _ ≤ (M : ℝ) := by
        simpa [M, dist_zero_right, add_comm] using
          add_le_add (Metric.mem_closedBall.mp hx) hA
  have hbound : ∀ x ∈ Metric.closedBall initial 1, ‖rhs x‖ ≤ (B : ℝ) := by
    intro x hx
    have hzero : rhs 0 = 0 := rhs_zero p kernel h hrow
    have hzeroMem : (0 : Field) ∈ Metric.closedBall 0 (M : ℝ) :=
      Metric.mem_closedBall_self M.2
    have hdist := hK.dist_le_mul x (hsub hx) 0 hzeroMem
    simp only [hzero, dist_zero_right] at hdist
    have hxnorm : ‖x‖ ≤ (M : ℝ) := by simpa using Metric.mem_closedBall.mp (hsub hx)
    exact hdist.trans (mul_le_mul_of_nonneg_left hxnorm K.2)
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
  refine ⟨solution, hinit, fun t ht => ?_⟩
  exact (hsol t ⟨ht.1.le, ht.2.le⟩).hasDerivAt (Icc_mem_nhds ht.1 ht.2)

/-- The torus oscillator admits a differentiable solution near the initial time. -/
theorem exists_local_solution (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) (initial : Field) :
    ∃ ε > (0 : ℝ), ∃ solution : ℝ → Field, solution 0 = initial ∧
      ∀ t ∈ Ioo (-ε) ε,
        HasDerivAt solution (continuousRhs p kernel h hrow (solution t)) t := by
  obtain ⟨ε, hε, H⟩ := exists_uniform_local_solution p h hrow ‖initial‖₊
  exact ⟨ε, hε, H initial le_rfl⟩

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

/-- At each torus point, a local solution keeps its initial modulus. -/
theorem norm_local_solution_eq_initial (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area)
    {solution : ℝ → Field} {ε : ℝ} (hε : 0 < ε)
    (hsol : ∀ t ∈ Ioo (-ε) ε,
      HasDerivAt solution (continuousRhs p kernel h hrow (solution t)) t)
    (x : Point) {t : ℝ} (ht : t ∈ Ioo (-ε) ε) :
    ‖solution t x‖ = ‖solution 0 x‖ := by
  let evaluate : Field →L[ℝ] ℂ := ContinuousMap.evalCLM ℝ x
  have hflat (s : ℝ) (hs : s ∈ Ioo (-ε) ε) :
      HasDerivAt (fun u => ‖solution u x‖ ^ 2) 0 s := by
    have hz := evaluate.hasFDerivAt.comp_hasDerivAt s (hsol s hs)
    have hradial : (evaluate (continuousRhs p kernel h hrow (solution s)) *
        conj (evaluate (solution s))).re = 0 := by
      change (baselineRhs p kernel (solution s) x * conj (solution s x)).re = 0
      rw [mul_comm]
      exact baselineRhs_tangent p kernel (solution s) x
    change HasDerivAt (fun u => ‖evaluate (solution u)‖ ^ 2) 0 s
    simpa only [Complex.inner, Function.comp_apply, hradial, mul_zero] using hz.norm_sq
  have hmem : (0 : ℝ) ∈ Ioo (-ε) ε := ⟨by linarith, hε⟩
  have hsq := isOpen_Ioo.is_const_of_deriv_eq_zero isPreconnected_Ioo
    (fun s hs => (hflat s hs).differentiableAt.differentiableWithinAt)
    (fun s hs => (hflat s hs).deriv) ht hmem
  exact (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp hsq

/-- A continuous unit phase field evolves locally through continuous unit phase fields. -/
theorem exists_local_phase_solution (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area)
    (initial : Field) (hunit : ∀ x, ‖initial x‖ = 1) :
    ∃ ε > (0 : ℝ), ∃ solution : ℝ → Field, solution 0 = initial ∧
      ∀ t ∈ Ioo (-ε) ε,
        HasDerivAt solution (continuousRhs p kernel h hrow (solution t)) t ∧
          ∀ x, ‖solution t x‖ = 1 := by
  obtain ⟨ε, hε, solution, hinitial, hsol⟩ := exists_local_solution p h hrow initial
  refine ⟨ε, hε, solution, hinitial, fun t ht => ⟨hsol t ht, fun x => ?_⟩⟩
  rw [norm_local_solution_eq_initial p h hrow hε hsol x ht, hinitial, hunit x]

end

end PWFA.TorusOscillator
