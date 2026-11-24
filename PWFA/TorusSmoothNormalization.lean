module

public import PWFA.TorusDiskNormalization

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus MeasureTheory Set
open scoped ENNReal

noncomputable section

private def radialVariable (r : Radius) (x y : Point) : ℝ :=
  euclideanDist x y ^ 2 / (r : ℝ) ^ 2

private theorem measurable_radialVariable (r : Radius) (x : Point) :
    Measurable (radialVariable r x) :=
  (((continuous_euclideanDist (continuous_const (y := x)) continuous_id).pow 2).div_const _).measurable

/-- Distribution of squared relative radius inside the open disk. -/
private theorem radial_distribution (r : Radius) (x : Point) :
    (area.restrict {y | euclideanDist x y < (r : ℝ)}).map (radialVariable r x) =
      ENNReal.ofReal (Real.pi * (r : ℝ) ^ 2) • volume.restrict (Ioo (0 : ℝ) 1) := by
  have hr := r.property.1
  have hm := measurable_radialVariable r x
  apply ext_of_generate_finite (range Iio) (borel_eq_generateFrom_Iio ℝ) isPiSystem_Iio
  · rintro _ ⟨t, rfl⟩
    rw [Measure.map_apply hm measurableSet_Iio, Measure.restrict_apply (hm measurableSet_Iio),
      Measure.smul_apply, Measure.restrict_apply measurableSet_Iio, Iio_inter_Ioo, Real.volume_Ioo,
      sub_zero, smul_eq_mul]
    by_cases ht : t ≤ 0
    · have hempty : radialVariable r x ⁻¹' Iio t = ∅ := by
        apply eq_empty_iff_forall_notMem.mpr
        intro y hy
        exact (not_lt_of_ge (ht.trans (div_nonneg (sq_nonneg _) (sq_nonneg _)))) hy
      simp [hempty, ENNReal.ofReal_of_nonpos ((min_le_left t 1).trans ht)]
    · have htpos := lt_of_not_ge ht
      let a := min t 1
      have ha : 0 < a := lt_min htpos zero_lt_one
      have hs := Real.sq_sqrt ha.le
      have hspos := Real.sqrt_pos.mpr ha
      have hsle : Real.sqrt a ≤ 1 := by nlinarith [min_le_right t (1 : ℝ)]
      let inner : Radius := ⟨(r : ℝ) * Real.sqrt a, mul_pos hr hspos,
        (mul_le_of_le_one_right hr.le hsle).trans_lt r.property.2⟩
      have hset : radialVariable r x ⁻¹' Iio t ∩ {y | euclideanDist x y < (r : ℝ)} =
          {y | euclideanDist x y < (inner : ℝ)} := by
        ext y
        let d := euclideanDist x y
        have hd : 0 ≤ d := euclideanDist_nonneg _ _
        change (d ^ 2 / (r : ℝ) ^ 2 < t ∧ d < (r : ℝ)) ↔ d < (r : ℝ) * Real.sqrt a
        have hone : d < (r : ℝ) ↔ d ^ 2 / (r : ℝ) ^ 2 < 1 := by
          rw [div_lt_one (sq_pos_of_pos hr), sq_lt_sq₀ hd hr.le]
        rw [hone, ← lt_min_iff, div_lt_iff₀ (sq_pos_of_pos hr)]
        rw [← sq_lt_sq₀ hd (mul_nonneg hr.le hspos.le), mul_pow, hs]
        rw [mul_comm (min t 1) ((r : ℝ) ^ 2)]
      rw [hset, area_disk, ← ENNReal.ofReal_mul (mul_nonneg Real.pi_pos.le (sq_nonneg _))]
      congr 1
      change Real.pi * ((r : ℝ) * Real.sqrt a) ^ 2 = Real.pi * (r : ℝ) ^ 2 * a
      rw [mul_pow, hs, mul_assoc]
  · simp [Measure.map_apply hm, area_disk, Real.volume_Ioo]

theorem integral_smoothBump_radial (r : Radius) (x : Point) :
    (∫ y, smoothBump (euclideanDist x y ^ 2 / (r : ℝ) ^ 2) ∂area) =
      Real.pi * (r : ℝ) ^ 2 * ∫ t in (0 : ℝ)..1, smoothBump t := by
  have hb : Continuous smoothBump :=
    (expNegInvGlue.contDiff (n := 0)).continuous.comp (continuous_const.sub continuous_id)
  let D := {y | euclideanDist x y < (r : ℝ)}
  have hind : D.indicator (fun y => smoothBump (radialVariable r x y)) =
      fun y => smoothBump (radialVariable r x y) := by
    apply indicator_eq_self.mpr
    intro y hy
    by_contra hout
    have hle : (r : ℝ) ≤ euclideanDist x y := le_of_not_gt hout
    have hratio : 1 ≤ radialVariable r x y :=
      (one_le_div (sq_pos_of_pos r.property.1)).2 (pow_le_pow_left₀ r.property.1.le hle 2)
    exact hy (expNegInvGlue.zero_of_nonpos (sub_nonpos.mpr hratio))
  change (∫ y, smoothBump (radialVariable r x y) ∂area) = _
  calc
    _ = ∫ y in D, smoothBump (radialVariable r x y) ∂area := by
      rw [← integral_indicator (measurableSet_disk r x), hind]
    _ = ∫ t, smoothBump t ∂(area.restrict D).map (radialVariable r x) :=
      (integral_map (measurable_radialVariable r x).aemeasurable hb.aestronglyMeasurable).symm
    _ = _ := by
      rw [radial_distribution, integral_smul_measure, ENNReal.toReal_ofReal (by positivity),
        smul_eq_mul, intervalIntegral.integral_of_le zero_le_one, integral_Ioc_eq_integral_Ioo]

theorem integral_smoothKernel (r : Radius) (x : Point) : (∫ y, smoothKernel r x y ∂area) = 1 := by
  simp only [smoothKernel, integral_div, integral_smoothBump_radial]
  exact div_self (mul_pos (mul_pos Real.pi_pos (sq_pos_of_pos r.property.1))
    smoothBump_integral_pos).ne'

theorem norm_meanField_smooth_le (r : Radius) (z : Field) (x : Point) :
    ‖meanField (smoothKernel r) z x‖ ≤ ‖z‖ :=
  norm_meanField_le_of_unit_mass (smoothKernel_translationInvariant r) (integrable_smoothKernel_row r 0)
    (smoothKernel_nonneg r 0) (integral_smoothKernel r 0) z x

end

end PWFA.TorusOscillator
