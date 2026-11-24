module

public import PWFA.TorusSynchronized
public import Mathlib.Analysis.Fourier.AddCircleMulti

/-!
# Exact torus waves

The integer pair specifies the turns around the two spatial coordinates. A character
turns translation into multiplication, so the kernel mean on this field reduces to one
complex coefficient. For a radial kernel reflection makes that coefficient real. The phase
lag then fixes the rotation rate for every integer pair, including the five axis and diagonal
directions in the baseline. [Dynamics](../docs/decisions/ADR-110.md) ·
[Selected modes](../docs/verification/slices/torus-oscillator-baseline.md#analytic-checks)
-/

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus MeasureTheory UnitAddTorus AddCircle
open scoped ComplexConjugate

noncomputable section

abbrev WaveIndex := Fin 2 → ℤ

/-- The central kernel row depends only on periodic Euclidean radius. -/
def RadialRow (kernel : Point → Point → ℝ) : Prop :=
  ∃ profile : ℝ → ℝ, ∀ u, kernel 0 u = profile (euclideanDist 0 u)

theorem smoothKernel_radial (r : Radius) : RadialRow (smoothKernel r) :=
  ⟨fun d => smoothBump (d ^ 2 / (r : ℝ) ^ 2) /
    (Real.pi * (r : ℝ) ^ 2 * ∫ s in (0 : ℝ)..1, smoothBump s), fun _ => rfl⟩

theorem diskKernel_radial (r : Radius) : RadialRow (diskKernel r) :=
  ⟨fun d => if d < (r : ℝ) then (Real.pi * (r : ℝ) ^ 2)⁻¹ else 0, fun _ => rfl⟩

theorem uniformKernel_radial : RadialRow uniformKernel := ⟨fun _ => 1, fun _ => rfl⟩

private theorem wave_norm (q : WaveIndex) (x : Point) : ‖mFourier q x‖ = 1 := by
  simp only [mFourier, ContinuousMap.coe_mk, fourier_apply, norm_prod, Circle.norm_coe,
    Finset.prod_const_one]

private theorem wave_add (q : WaveIndex) (x u : Point) :
    mFourier q (x + u) = mFourier q x * mFourier q u := by
  simp only [mFourier, ContinuousMap.coe_mk, Pi.add_apply, fourier_apply, smul_add,
    toCircle_add, Circle.coe_mul, Finset.prod_mul_distrib]

private theorem wave_neg (q : WaveIndex) (u : Point) : mFourier q (-u) = conj (mFourier q u) := by
  simp only [mFourier, ContinuousMap.coe_mk, Pi.neg_apply, fourier_apply, smul_neg,
    toCircle_neg, Circle.coe_inv_eq_conj, map_prod]

/-- The multiplier of the centered mean on a character, using the unit-area measure of ADR-110. -/
def waveCoefficient (kernel : Point → Point → ℝ) (q : WaveIndex) : ℂ :=
  ∫ u, (kernel 0 u : ℂ) * mFourier q u ∂area

theorem waveCoefficient_real {kernel : Point → Point → ℝ} (hr : RadialRow kernel) (q : WaveIndex) :
    ((waveCoefficient kernel q).re : ℂ) = waveCoefficient kernel q := by
  obtain ⟨profile, hp⟩ := hr
  -- Reversing displacement preserves area and radius but conjugates the character.
  apply Complex.conj_eq_iff_re.mp
  unfold waveCoefficient
  rw [← integral_conj, area_eq_volume]
  rw [← integral_neg_eq_self (fun u => (kernel 0 u : ℂ) * mFourier q u) volume]
  apply integral_congr_ae
  apply ae_of_all
  intro u
  have hd : euclideanDist 0 (-u) = euclideanDist 0 u := by
    simp [euclideanDist_eq_sqrt_sum, dist_eq_norm]
  simp only [hp, hd, wave_neg, map_mul, Complex.conj_ofReal]

theorem waveCoefficient_neg (kernel : Point → Point → ℝ) (q : WaveIndex) :
    (waveCoefficient kernel (-q)).re = (waveCoefficient kernel q).re := by
  have hc : waveCoefficient kernel (-q) = conj (waveCoefficient kernel q) := by
    unfold waveCoefficient
    rw [← integral_conj]
    simp only [mFourier_neg, map_mul, Complex.conj_ofReal]
  rw [hc, Complex.conj_re]

/-- Exchange the two coordinate circles of the square torus. -/
def swapAxes {α : Type*} (u : Fin 2 → α) : Fin 2 → α := u ∘ Equiv.swap 0 1

theorem waveCoefficient_swap {kernel : Point → Point → ℝ} (hr : RadialRow kernel) (q : WaveIndex) :
    waveCoefficient kernel (swapAxes q) = waveCoefficient kernel q := by
  obtain ⟨profile, hp⟩ := hr
  let E := MeasurableEquiv.piCongrLeft (fun _ : Fin 2 => UnitAddCircle) (Equiv.swap 0 1)
  have he (u : Point) (i : Fin 2) : E u i = u (Equiv.swap 0 1 i) := by
    simpa [E] using MeasurableEquiv.piCongrLeft_apply_apply (β := fun _ : Fin 2 => UnitAddCircle)
      (Equiv.swap 0 1) u (Equiv.swap 0 1 i)
  have hd (u : Point) : euclideanDist 0 (E u) = euclideanDist 0 u := by
    simp [euclideanDist_eq_sqrt_sum, Fin.sum_univ_two, he, add_comm]
  have hw (u : Point) : mFourier (swapAxes q) u = mFourier q (E u) := by
    simp [mFourier, Fin.prod_univ_two, swapAxes, he, mul_comm]
  unfold waveCoefficient
  rw [area_eq_volume, ← (volume_measurePreserving_piCongrLeft _ (Equiv.swap (0 : Fin 2) 1)).integral_comp'
    (fun u : Point => (kernel 0 u : ℂ) * mFourier q u)]
  apply integral_congr_ae
  refine ae_of_all _ fun u => ?_
  change (kernel 0 u : ℂ) * mFourier (swapAxes q) u = (kernel 0 (E u) : ℂ) * mFourier q (E u)
  simp only [hp, hd, hw]

theorem waveCoefficient_uniform_nonzero {q : WaveIndex} (hq : q ≠ 0) :
    waveCoefficient uniformKernel q = 0 := by
  rw [waveCoefficient, area_eq_volume]
  simp only [uniformKernel, Complex.ofReal_one, one_mul]
  rw [mFourier, ContinuousMap.coe_mk, MeasureTheory.integral_fintype_prod_volume_eq_prod]
  obtain ⟨i, hi⟩ := Function.ne_iff.mp hq
  apply Finset.prod_eq_zero (Finset.mem_univ i)
  rw [AddCircle.volume_eq_smul_haarAddCircle]
  simp only [ENNReal.ofReal_one, one_smul]
  have hc := congrFun (fourierCoeff_fourier (T := 1) (q i)) (0 : ℤ)
  change q i ≠ (0 : ℤ) at hi
  simpa only [fourierCoeff, neg_zero, fourier_zero, one_smul, Pi.single_eq_of_ne (Ne.symm hi)]
    using hc

/-- The synchronized mode sees the whole row mass, independent of its radial shape. -/
theorem waveCoefficient_zero {kernel : Point → Point → ℝ} (hm : (∫ u, kernel 0 u ∂area) = 1) :
    waveCoefficient kernel 0 = 1 := by
  simp only [waveCoefficient, mFourier_zero, ContinuousMap.one_apply, mul_one,
    integral_complex_ofReal, hm, Complex.ofReal_one]

/-- The sign comes from the negative phase lag in the selected sine interaction. -/
def waveRate (p : Parameters) (kernel : Point → Point → ℝ) (q : WaveIndex) : ℝ :=
  p.frequency - p.coupling * (waveCoefficient kernel q).re * Real.sin p.phaseLag

def waveField (p : Parameters) (kernel : Point → Point → ℝ) (q : WaveIndex) (t : ℝ) : Field :=
  rotatingValue (waveRate p kernel q) 1 t • mFourier q

theorem waveField_zero (p : Parameters) (kernel : Point → Point → ℝ) (q : WaveIndex) :
    waveField p kernel q 0 = mFourier q := by simp [waveField, rotatingValue]

theorem waveField_unit (p : Parameters) (kernel : Point → Point → ℝ) (q : WaveIndex)
    (t : ℝ) (x : Point) : ‖waveField p kernel q t x‖ = 1 := by
  simp only [waveField, ContinuousMap.smul_apply, smul_eq_mul, norm_mul, rotatingValue_norm,
    norm_one, wave_norm, one_mul]

theorem waveField_deriv (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) (hr : RadialRow kernel)
    (q : WaveIndex) (t : ℝ) :
    HasDerivAt (waveField p kernel q) (continuousRhs p kernel h hrow (waveField p kernel q t)) t := by
  -- Translation factors the current phase out of the local mean. The remaining factor is
  -- exactly the centered coefficient, even when the row has a sharp disk boundary.
  let rate := waveRate p kernel q
  let c := rotatingValue rate 1 t
  have hm (x : Point) : meanField kernel (waveField p kernel q t) x =
      waveField p kernel q t x * waveCoefficient kernel q := by
    rw [meanField_eq_translate h, waveCoefficient, ← integral_const_mul]
    apply integral_congr_ae
    refine ae_of_all _ fun u => ?_
    simp only [waveField, ContinuousMap.smul_apply, smul_eq_mul, wave_add]
    ring
  have hv : continuousRhs p kernel h hrow (waveField p kernel q t) =
      (Complex.I * c * rate) • mFourier q := by
    ext x
    let z := waveField p kernel q t x
    let weight := (waveCoefficient kernel q).re
    -- Unit modulus cancels the phase against its conjugate in the original right-hand side.
    have hz : conj z * z = 1 := by
      rw [← Complex.normSq_eq_conj_mul_self, Complex.normSq_eq_norm_sq, waveField_unit, one_pow, Complex.ofReal_one]
    have hs : angularVelocity p z (z * waveCoefficient kernel q) = rate := by
      rw [← waveCoefficient_real hr q]
      unfold angularVelocity
      rw [show Complex.mk (Real.cos p.phaseLag) (-Real.sin p.phaseLag) * conj z * (z * (weight : ℂ)) =
          Complex.mk (Real.cos p.phaseLag) (-Real.sin p.phaseLag) * (weight : ℂ) by
        calc
          _ = Complex.mk _ _ * (conj z * z) * (weight : ℂ) := by ring
          _ = _ := by rw [hz, mul_one]]
      simp only [Complex.mul_im, Complex.ofReal_re, Complex.ofReal_im, mul_zero, zero_add]
      change _ = p.frequency - p.coupling * weight * Real.sin p.phaseLag
      ring
    change pointVelocity p z (meanField kernel (waveField p kernel q t) x) = _
    rw [hm]
    change Complex.I * z * (angularVelocity p z (z * waveCoefficient kernel q) : ℂ) = _
    rw [hs]
    change Complex.I * (c * mFourier q x) * (rate : ℂ) = _ * mFourier q x
    ring
  rw [hv]
  exact (rotatingValue_deriv rate 1 t).smul_const (mFourier q)

end

end PWFA.TorusOscillator
