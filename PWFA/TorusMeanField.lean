module

public import PWFA.TorusOscillator
public import Mathlib.MeasureTheory.Group.Integral
public import Mathlib.Topology.ContinuousMap.Compact

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus MeasureTheory MeasureTheory.Measure
open scoped ComplexConjugate Topology

noncomputable section

instance : IsProbabilityMeasure area := ⟨area_univ⟩

instance : IsAddLeftInvariant area := by
  unfold area
  infer_instance

/-- Kernel weights are invariant when both points undergo the same translation. -/
def TranslationInvariant (kernel : Point → Point → ℝ) : Prop :=
  ∀ x y shift, kernel (x + shift) (y + shift) = kernel x y

theorem smoothKernel_translationInvariant (radius : Radius) :
    TranslationInvariant (smoothKernel radius) := by
  intro x y shift
  simp only [smoothKernel, euclideanDist_add_right]

theorem diskKernel_translationInvariant (radius : Radius) :
    TranslationInvariant (diskKernel radius) := by
  intro x y shift
  simp only [diskKernel, euclideanDist_add_right]

theorem uniformKernel_translationInvariant : TranslationInvariant uniformKernel := by
  intro x y shift
  rfl

theorem continuous_smoothKernel_row (radius : Radius) (x : Point) :
    Continuous (smoothKernel radius x) := by
  have hd := continuous_euclideanDist (continuous_const (y := x)) continuous_id
  have hs : Continuous smoothBump :=
    (expNegInvGlue.contDiff (n := 0)).continuous.comp (continuous_const.sub continuous_id)
  unfold smoothKernel
  exact (hs.comp ((hd.pow 2).div_const _)).div_const _

theorem integrable_smoothKernel_row (radius : Radius) (x : Point) :
    Integrable (smoothKernel radius x) area :=
  (continuous_smoothKernel_row radius x).integrable_of_hasCompactSupport (HasCompactSupport.of_compactSpace _)

theorem measurableSet_disk (radius : Radius) (x : Point) :
    MeasurableSet {y | euclideanDist x y < (radius : ℝ)} :=
  measurableSet_lt (continuous_euclideanDist (continuous_const (y := x)) continuous_id).measurable
    measurable_const

theorem integrable_diskKernel_row (radius : Radius) (x : Point) :
    Integrable (diskKernel radius x) area := by
  have hform : diskKernel radius x =
      Set.indicator {y | euclideanDist x y < (radius : ℝ)} (fun _ => (Real.pi * (radius : ℝ) ^ 2)⁻¹) := rfl
  rw [hform]
  exact (integrable_const _).indicator (measurableSet_disk radius x)

theorem integrable_uniformKernel_row (x : Point) : Integrable (uniformKernel x) area :=
  integrable_const 1

theorem integral_kernel_row_eq_origin {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (x : Point) :
    (∫ y, kernel x y ∂area) = ∫ u, kernel 0 u ∂area := by
  rw [← integral_add_left_eq_self (μ := area) (kernel x) x]
  apply integral_congr_ae
  exact ae_of_all _ fun u => by simpa only [zero_add, add_comm u x] using h 0 u x

theorem meanField_eq_translate {kernel : Point → Point → ℝ} (h : TranslationInvariant kernel)
    (z : Field) (x : Point) :
    meanField kernel z x = ∫ u, (kernel 0 u : ℂ) * z (x + u) ∂area := by
  unfold meanField
  rw [← integral_add_left_eq_self (μ := area) (fun y => (kernel x y : ℂ) * z y) x]
  apply integral_congr_ae
  refine ae_of_all _ fun u => ?_
  have heq : kernel x (x + u) = kernel 0 u := by
    simpa only [zero_add, add_comm u x] using h 0 u x
  simp only [heq]

private theorem translated_measurable {w : Point → ℝ} (hw : Integrable w area) (z : Field)
    (x : Point) :
    AEStronglyMeasurable (fun u => (w u : ℂ) * z (x + u)) area :=
  (Complex.continuous_ofReal.comp_aestronglyMeasurable hw.aestronglyMeasurable).mul
    (z.continuous.comp (continuous_const.add continuous_id)).aestronglyMeasurable

private theorem translated_norm_le (w : Point → ℝ) (z : Field) (x u : Point) :
    ‖(w u : ℂ) * z (x + u)‖ ≤ ‖w u‖ * ‖z‖ := by
  rw [norm_mul, Complex.norm_real]
  exact mul_le_mul_of_nonneg_left (z.norm_coe_le_norm (x + u)) (norm_nonneg _)

private theorem translated_integrable {w : Point → ℝ} (hw : Integrable w area) (z : Field)
    (x : Point) : Integrable (fun u => (w u : ℂ) * z (x + u)) area :=
  (hw.norm.mul_const ‖z‖).mono' (translated_measurable hw z x)
    (ae_of_all _ (translated_norm_le w z x))

theorem continuous_meanField {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) (z : Field) :
    Continuous (meanField kernel z) := by
  have heq : meanField kernel z = fun x => ∫ u, (kernel 0 u : ℂ) * z (x + u) ∂area :=
    funext (meanField_eq_translate h z)
  rw [heq]
  exact continuous_of_dominated (translated_measurable hrow z)
    (fun x => ae_of_all _ (translated_norm_le (kernel 0) z x)) (hrow.norm.mul_const ‖z‖)
    (ae_of_all _ fun u => continuous_const.mul (z.continuous.comp (continuous_id.add continuous_const)))

theorem norm_meanField_le {kernel : Point → Point → ℝ} (h : TranslationInvariant kernel)
    (hrow : Integrable (kernel 0) area) (z : Field) (x : Point) :
    ‖meanField kernel z x‖ ≤ (∫ u, ‖kernel 0 u‖ ∂area) * ‖z‖ := by
  rw [meanField_eq_translate h z]
  let bound : Point → ℝ := fun u => ‖kernel 0 u‖ * ‖z‖
  have hbound : Integrable bound area := hrow.norm.mul_const ‖z‖
  have hlim := ae_of_all area (translated_norm_le (kernel 0) z x)
  calc
    _ ≤ ∫ u, ‖(kernel 0 u : ℂ) * z (x + u)‖ ∂area :=
      norm_integral_le_integral_norm _
    _ ≤ ∫ u, bound u ∂area := integral_mono_ae (translated_integrable hrow z x).norm hbound hlim
    _ = _ := integral_mul_const _ _

theorem norm_meanField_le_of_unit_mass {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area)
    (hnonneg : ∀ u, 0 ≤ kernel 0 u) (hmass : (∫ u, kernel 0 u ∂area) = 1)
    (z : Field) (x : Point) : ‖meanField kernel z x‖ ≤ ‖z‖ := by
  simpa only [Real.norm_of_nonneg (hnonneg _), hmass, one_mul] using norm_meanField_le h hrow z x

theorem norm_meanField_uniform_le (z : Field) (x : Point) :
    ‖meanField uniformKernel z x‖ ≤ ‖z‖ :=
  norm_meanField_le_of_unit_mass uniformKernel_translationInvariant
    (integrable_uniformKernel_row 0) (fun _ => zero_le_one) (by simp [uniformKernel]) z x

/-- Mean field as a bounded complex-linear operator on continuous fields. -/
def meanOperator (kernel : Point → Point → ℝ) (h : TranslationInvariant kernel)
    (hrow : Integrable (kernel 0) area) : Field →L[ℂ] Field :=
  LinearMap.mkContinuous
    { toFun := fun z => ⟨meanField kernel z, continuous_meanField h hrow z⟩
      map_add' := by
        intro z w
        ext x
        change meanField kernel (z + w) x = meanField kernel z x + meanField kernel w x
        simp only [meanField_eq_translate h, ContinuousMap.add_apply, mul_add]
        exact integral_add (translated_integrable hrow z x) (translated_integrable hrow w x)
      map_smul' := by
        intro a z
        ext x
        change meanField kernel (a • z) x = a * meanField kernel z x
        simp only [meanField_eq_translate h, ContinuousMap.smul_apply, smul_eq_mul]
        rw [← integral_const_mul]
        apply integral_congr_ae
        exact ae_of_all _ fun _ => mul_left_comm _ _ _ }
    (∫ u, ‖kernel 0 u‖ ∂area)
    (fun z => (ContinuousMap.norm_le_of_nonempty _).2 (norm_meanField_le h hrow z))

theorem meanOperator_apply (kernel : Point → Point → ℝ) (h : TranslationInvariant kernel)
    (hrow : Integrable (kernel 0) area) (z : Field) (x : Point) :
    meanOperator kernel h hrow z x = meanField kernel z x :=
  rfl

theorem norm_meanOperator_le (kernel : Point → Point → ℝ) (h : TranslationInvariant kernel)
    (hrow : Integrable (kernel 0) area) (z : Field) :
    ‖meanOperator kernel h hrow z‖ ≤ (∫ u, ‖kernel 0 u‖ ∂area) * ‖z‖ :=
  (ContinuousMap.norm_le_of_nonempty _).2 (norm_meanField_le h hrow z)

theorem norm_meanOperator_sub_le (kernel : Point → Point → ℝ) (h : TranslationInvariant kernel)
    (hrow : Integrable (kernel 0) area) (z w : Field) :
    ‖meanOperator kernel h hrow z - meanOperator kernel h hrow w‖ ≤
      (∫ u, ‖kernel 0 u‖ ∂area) * ‖z - w‖ := by
  rw [← map_sub]
  exact norm_meanOperator_le kernel h hrow (z - w)

theorem continuous_baselineRhs (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) (z : Field) :
    Continuous (baselineRhs p kernel z) := by
  have hmean := continuous_meanField h hrow z
  unfold baselineRhs pointVelocity angularVelocity
  fun_prop (disch := exact z.continuous)

/-- The unforced right-hand side, viewed as a continuous field. -/
def continuousRhs (p : Parameters) (kernel : Point → Point → ℝ)
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) (z : Field) : Field :=
  ⟨baselineRhs p kernel z, continuous_baselineRhs p h hrow z⟩

end

end PWFA.TorusOscillator
