module

public import PWFA.TorusWaves
public import Mathlib.Analysis.InnerProductSpace.Projection.Reflection

/-!
# Disk wave rates from chord lengths

[ADR-111](../docs/decisions/ADR-111.md) selects an open Euclidean disk of fixed density.
The [analytic checks](../docs/verification/slices/torus-oscillator-baseline.md#analytic-checks)
require a one-dimensional expression for its Fourier coefficient. We use the centered
coordinate square, align the wave direction with the horizontal axis, and integrate the
vertical chord. Each change of coordinates preserves area.
-/

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus UnitAddTorus AddCircle MeasureTheory Set
open scoped RealInnerProductSpace

noncomputable section

private abbrev Plane := EuclideanSpace ℝ (Fin 2)

/-- The frequency vector uses the Euclidean norm of the integer winding pair. -/
def frequencyVector (q : WaveIndex) : EuclideanSpace ℝ (Fin 2) :=
  WithLp.toLp 2 fun i => (q i : ℝ)

private theorem character_real_coordinates (q : WaveIndex) (u : Plane) :
    (mFourier q (ofCoordinates (WithLp.ofLp u))).re =
      Real.cos (2 * Real.pi * (inner ℝ (frequencyVector q) u)) := by
  have hc : mFourier q (ofCoordinates (WithLp.ofLp u)) =
      Complex.exp (((2 * Real.pi * (inner ℝ (frequencyVector q) u) : ℝ) : ℂ) * Complex.I) := by
    simp only [mFourier, ContinuousMap.coe_mk, Fin.prod_univ_two, ofCoordinates, fourier_coe_apply,
      Complex.ofReal_one, div_one, ← Complex.exp_add]
    congr 1
    simp [PiLp.inner_apply, Fin.sum_univ_two, frequencyVector]
    ring
  rw [hc, Complex.exp_re]
  simp

private theorem along_axis (v : Plane) (r : ℝ) :
    (∫ u in Metric.ball (0 : Plane) r, Real.cos (2 * Real.pi * (inner ℝ v u))) =
      ∫ u in Metric.ball (0 : Plane) r, Real.cos (2 * Real.pi * ‖v‖ * u 0) := by
  -- Reflection also handles a frequency already on the chosen axis.
  let axis : Plane := EuclideanSpace.single 0 ‖v‖
  let e := (ℝ ∙ (axis - v))ᗮ.reflection
  have hv : e axis = v := Submodule.reflection_sub (by simp [axis])
  have hb : e ⁻¹' Metric.ball (0 : Plane) r = Metric.ball 0 r := by
    ext u
    simp [Metric.mem_ball, dist_zero_right]
  rw [← e.measurePreserving.setIntegral_preimage_emb e.toHomeomorph.measurableEmbedding
    (fun u => Real.cos (2 * Real.pi * (inner ℝ v u))) (Metric.ball 0 r), hb]
  apply setIntegral_congr_fun measurableSet_ball
  intro u _
  have hi : inner ℝ v (e u) = ‖v‖ * u 0 := calc
    _ = inner ℝ (e axis) (e u) := congrArg (fun w => inner ℝ w (e u)) hv.symm
    _ = inner ℝ axis u := e.inner_map_map axis u
    _ = _ := by simp [axis, EuclideanSpace.inner_single_left]
  simp only [hi, mul_assoc]

private theorem vertical_section (r x y : ℝ) :
    x ^ 2 + y ^ 2 < r ^ 2 ↔
      y ∈ Ioo (-Real.sqrt (r ^ 2 - x ^ 2)) (Real.sqrt (r ^ 2 - x ^ 2)) := by
  rw [mem_Ioo, ← abs_lt, Real.lt_sqrt (abs_nonneg _), sq_abs]
  constructor <;> intro h <;> linarith

private theorem chord_integral (r c : ℝ) (hr : 0 < r) :
    (∫ u in Metric.ball (0 : Plane) r, Real.cos (c * u 0)) =
      4 * ∫ x in (0 : ℝ)..r, Real.sqrt (r ^ 2 - x ^ 2) * Real.cos (c * x) := by
  let e := (MeasurableEquiv.finTwoArrow (α := ℝ)).symm.trans (MeasurableEquiv.toLp 2 (Fin 2 → ℝ))
  have he : MeasurePreserving e := (PiLp.volume_preserving_toLp (Fin 2)).comp
    (volume_preserving_finTwoArrow ℝ).symm
  let disk := {p : ℝ × ℝ | p.1 ^ 2 + p.2 ^ 2 < r ^ 2}
  have hd : MeasurableSet disk := measurableSet_lt (by fun_prop) (by fun_prop)
  have h0 (x y : ℝ) : e (x,y) 0 = x := rfl
  have h1 (x y : ℝ) : e (x,y) 1 = y := rfl
  have hb : e ⁻¹' Metric.ball (0 : Plane) r = disk := by
    ext ⟨x, y⟩
    change dist (e (x,y)) 0 < r ↔ _
    rw [dist_zero_right, ← sq_lt_sq₀ (norm_nonneg _) hr.le, EuclideanSpace.real_norm_sq_eq,
      Fin.sum_univ_two, h0, h1]
    rfl
  rw [← he.setIntegral_preimage_emb e.measurableEmbedding (fun u : Plane => Real.cos (c * u 0))
    (Metric.ball 0 r), hb]
  change (∫ p in disk, Real.cos (c * p.1)) = _
  let f := disk.indicator (fun p : ℝ × ℝ => Real.cos (c * p.1))
  have hsub : disk ⊆ (Icc (-r) r) ×ˢ (Icc (-r) r) := by
    rintro ⟨x,y⟩ h
    change x ^ 2 + y ^ 2 < r ^ 2 at h
    change (_ ≤ x ∧ x ≤ _) ∧ (_ ≤ y ∧ y ≤ _)
    constructor <;> constructor <;> nlinarith [sq_nonneg x, sq_nonneg y]
  have hint : Integrable f := (integrable_indicator_iff hd).2
    (((show Continuous (fun p : ℝ × ℝ => Real.cos (c * p.1)) by fun_prop).continuousOn.integrableOn_compact
      (isCompact_Icc.prod isCompact_Icc)).mono_set hsub)
  rw [← integral_indicator hd]
  change (∫ p, f p ∂volume.prod volume) = _
  rw [integral_prod _ hint]
  let g (x : ℝ) := Real.sqrt (r ^ 2 - x ^ 2) * Real.cos (c * x)
  have hline (x : ℝ) : (∫ y, f (x,y)) = 2 * g x := by
    let a := Real.sqrt (r ^ 2 - x ^ 2)
    have hf (y : ℝ) : f (x,y) = (Ioo (-a) a).indicator (fun _ => Real.cos (c*x)) y := by
      simp only [f, disk, Set.indicator, mem_ofPred_eq, vertical_section, a]
    simp_rw [hf]
    rw [integral_indicator measurableSet_Ioo, setIntegral_const,
      Real.volume_real_Ioo_of_le (neg_nonpos.mpr (Real.sqrt_nonneg _) |>.trans (Real.sqrt_nonneg _)), smul_eq_mul]
    dsimp [g, a]
    ring
  simp_rw [hline]
  rw [integral_const_mul]
  -- Chord length is zero outside the horizontal diameter. The two half-diameters agree.
  have hg : Continuous g := by dsimp [g]; fun_prop
  have hsupport : (Ioc (-r) r).indicator g = g := by
    funext x
    by_cases h : x ∈ Ioc (-r) r
    · exact indicator_of_mem h _
    · rw [indicator_of_notMem h]
      change 0 = Real.sqrt _ * _
      rw [Real.sqrt_eq_zero_of_nonpos, zero_mul]
      simp only [mem_Ioc, not_and_or, not_lt, not_le] at h
      rcases h with h | h <;> nlinarith
  rw [← hsupport, integral_indicator measurableSet_Ioc,
    ← intervalIntegral.integral_of_le (by linarith : -r ≤ r)]
  have half : (∫ x in -r..0, g x) = ∫ x in (0 : ℝ)..r, g x := by
    have hn := intervalIntegral.integral_comp_neg (a := 0) (b := r) g
    simpa [g, mul_neg] using hn.symm
  rw [← intervalIntegral.integral_add_adjacent_intervals (hg.intervalIntegrable (-r) 0)
    (hg.intervalIntegrable 0 r), half]
  change 2 * (_ + _) = 4 * _
  ring

/-- The disk coefficient in the architecture's independent one-dimensional reference form. -/
theorem waveCoefficient_disk_chord (r : Radius) (q : WaveIndex) :
    (waveCoefficient (diskKernel r) q).re =
      4 / (Real.pi * (r : ℝ) ^ 2) * ∫ x in (0 : ℝ)..(r : ℝ),
        Real.sqrt ((r : ℝ) ^ 2 - x ^ 2) * Real.cos (2 * Real.pi * ‖frequencyVector q‖ * x) := by
  let D := {y | euclideanDist 0 y < (r : ℝ)}
  let k := (Real.pi * (r : ℝ) ^ 2)⁻¹
  have hi (y : Point) : (diskKernel r 0 y : ℂ) * mFourier q y =
      D.indicator (fun y => (k : ℂ) * mFourier q y) y := by
    by_cases h : y ∈ D
    · rw [indicator_of_mem h]
      simp [diskKernel, k, show euclideanDist 0 y < (r : ℝ) from h]
    · rw [indicator_of_notMem h]
      simp [diskKernel, show ¬ euclideanDist 0 y < (r : ℝ) from h]
  simp only [waveCoefficient, hi]
  rw [integral_indicator (measurableSet_disk r 0), integral_const_mul, Complex.re_ofReal_mul]
  let f : C(Point, ℝ) := ⟨fun y => (mFourier q y).re, Complex.continuous_re.comp (mFourier q).continuous⟩
  have hf : (∫ y in D, mFourier q y ∂area).re = ∫ y in D, f y ∂area :=
    (Complex.reCLM.integral_comp_comm (((mFourier q).continuous.integrable_of_hasCompactSupport
      (HasCompactSupport.of_compactSpace _)).integrableOn (s := D) (μ := area))).symm
  rw [hf, setIntegral_disk_coordinates]
  change k * (∫ u in Metric.ball (0 : Plane) r, (mFourier q (ofCoordinates (WithLp.ofLp u))).re) = _
  simp_rw [character_real_coordinates]
  rw [along_axis, chord_integral _ _ r.property.1]
  dsimp [k]
  ring

end

end PWFA.TorusOscillator
