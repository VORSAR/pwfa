module

public import PWFA.TorusSynchronized
public import Mathlib.Analysis.Fourier.AddCircle

/-!
# Recovered one-dimensional oscillator controls

The [historical ring equations](../docs/mathematics/ring-oscillator-reference.md) put the
coupling strength inside the structural kernel. This module integrates that kernel on the
unit ring, substitutes rotating Fourier modes into the original phase law, and checks the
three recovered contrasts. The [torus kernel decision](../docs/decisions/ADR-111.md) keeps
this contrast sweep on the ring.
-/

@[expose] public section

namespace PWFA.HistoricalRing

open AddCircle MeasureTheory PWFA.TorusOscillator
open scoped ComplexConjugate

noncomputable section

/-- The real part of the first character is the cosine of the displacement in turns. -/
def kernel (coupling contrast : ℝ) (x y : UnitAddCircle) : ℝ :=
  coupling * (1 + contrast * (fourier 1 (x - y)).re)

theorem kernel_coordinates (k a x y : ℝ) :
    kernel k a x y = k * (1 + a * Real.cos (2 * Real.pi * (x-y))) := by
  simp only [kernel, ← QuotientAddGroup.mk_sub, fourier_coe_apply, Int.cast_one, Complex.ofReal_one,
    mul_one, div_one, Complex.exp_re]
  simp

/-- Haar integral of a pure character, indexed by its integer winding. -/
def mass (n : ℤ) : ℝ := if n = 0 then 1 else 0

/-- Orthogonality to the constant mode on a circle of total mass one. -/
private theorem integral_character (n : ℤ) :
    (∫ u : UnitAddCircle, fourier n u ∂haarAddCircle) = (mass n : ℂ) := by
  by_cases h : n = 0
  · subst n
    simp [mass]
  · have hc := congrFun (fourierCoeff_fourier (T := 1) n) (0 : ℤ)
    simpa only [fourierCoeff, neg_zero, fourier_zero, one_smul, Pi.single_eq_of_ne (Ne.symm h),
      mass, ite_eq_right h, Complex.ofReal_zero] using hc

/-- Only zero and the two first harmonics survive the recovered cosine kernel. -/
def multiplier (a : ℝ) (n : ℤ) : ℝ :=
  mass n + a / 2 * (mass (1+n) + mass (-1+n))

private theorem integrable_character (n : ℤ) :
    Integrable (fun u : UnitAddCircle => fourier n u) haarAddCircle :=
  (fourier n).continuous.integrable_of_hasCompactSupport (HasCompactSupport.of_compactSpace _)

private theorem centered_mean (k a : ℝ) (n : ℤ) :
    (∫ u : UnitAddCircle, (kernel k a 0 u : ℂ) * fourier n u ∂haarAddCircle) =
      ((k * multiplier a n : ℝ) : ℂ) := by
  have expand (u : UnitAddCircle) : (kernel k a 0 u : ℂ) * fourier n u =
      (k : ℂ) * (fourier n u + (a / 2 : ℂ) * (fourier (1+n) u + fourier (-1+n) u)) := by
    have heven : (fourier 1 (0-u)).re = (fourier 1 u).re := by
      simp [fourier_apply, toCircle_neg]
    simp only [kernel, heven, Complex.ofReal_mul, Complex.ofReal_add, Complex.ofReal_one,
      fourier_add, fourier_neg]
    have hc := Complex.add_conj (fourier 1 u)
    push_cast at hc
    linear_combination (k : ℂ) * (a : ℂ) * fourier n u / 2 * (-hc)
  simp_rw [expand]
  have hi : Integrable (fun u : UnitAddCircle => (a / 2 : ℂ) * (fourier (1+n) u + fourier (-1+n) u)) haarAddCircle :=
    ((integrable_character (1+n)).add (integrable_character (-1+n))).const_mul _
  rw [integral_const_mul, integral_add (integrable_character n) hi,
    integral_const_mul, integral_add (integrable_character (1+n)) (integrable_character (-1+n))]
  rw [integral_character n, integral_character (1+n), integral_character (-1+n)]
  push_cast [multiplier]
  rfl

/-- Convolution against a character at any center; the row already contains the coupling. -/
theorem mean_mode (k a : ℝ) (n : ℤ) (x : UnitAddCircle) :
    (∫ y : UnitAddCircle, (kernel k a x y : ℂ) * fourier n y ∂haarAddCircle) =
      fourier n x * (k * multiplier a n : ℝ) := by
  rw [← integral_add_left_eq_self (μ := haarAddCircle) (fun y => (kernel k a x y : ℂ) * fourier n y) x,
    ← centered_mean, ← integral_const_mul]
  apply integral_congr_ae
  refine ae_of_all _ fun u => ?_
  simp only [kernel, sub_add_cancel_left, zero_sub, fourier_apply, smul_add, toCircle_add, Circle.coe_mul]
  ring

theorem integral_kernel (k a : ℝ) (x : UnitAddCircle) :
    (∫ y, kernel k a x y ∂haarAddCircle) = k := by
  have h := mean_mode k a 0 x
  simpa [fourier_zero, multiplier, mass, integral_complex_ofReal] using congrArg Complex.re h

/-- Instantaneous angular velocity from the recovered structural integral. -/
def speed (ω α k a : ℝ) (z : UnitAddCircle → ℂ) (x : UnitAddCircle) : ℝ :=
  ω + ∫ y, kernel k a x y * (Complex.mk (Real.cos α) (-Real.sin α) * conj (z x) * z y).im
    ∂haarAddCircle

def rate (ω α k a : ℝ) (n : ℤ) : ℝ := ω - k * multiplier a n * Real.sin α

def trajectory (ω α k a : ℝ) (n : ℤ) (t : ℝ) (x : UnitAddCircle) : ℂ :=
  rotatingValue (rate ω α k a n) 1 t * fourier n x

theorem trajectory_initial (ω α k a : ℝ) (n : ℤ) (x : UnitAddCircle) :
    trajectory ω α k a n 0 x = fourier n x := by simp [trajectory, rotatingValue]

theorem trajectory_unit (ω α k a : ℝ) (n : ℤ) (t : ℝ) (x : UnitAddCircle) :
    ‖trajectory ω α k a n t x‖ = 1 := by
  simp only [trajectory, norm_mul, rotatingValue_norm, norm_one, one_mul, fourier_apply, Circle.norm_coe]

theorem trajectory_speed (ω α k a : ℝ) (n : ℤ) (t : ℝ) (x : UnitAddCircle) :
    speed ω α k a (trajectory ω α k a n t) x = rate ω α k a n := by
  let z := trajectory ω α k a n t
  let lag := Complex.mk (Real.cos α) (-Real.sin α)
  let A := lag * conj (z x) * rotatingValue (rate ω α k a n) 1 t
  let row (y : UnitAddCircle) := (kernel k a x y : ℂ) * fourier n y
  have hrow : Continuous row := by
    dsimp [row, kernel]
    fun_prop
  -- Move the imaginary-part map through the integral. Only the real multiplier and
  -- the imaginary part of the phase-lag factor remain after unit phases cancel.
  have hi (y : UnitAddCircle) :
      kernel k a x y * (lag * conj (z x) * z y).im = (A * row y).im := by
    rw [show A * row y = (kernel k a x y : ℂ) * (lag * conj (z x) * z y) by dsimp [A,row,z,trajectory]; ring,
      Complex.im_ofReal_mul]
  change ω + (∫ y, kernel k a x y * (lag * conj (z x) * z y).im ∂haarAddCircle) = _
  simp_rw [hi]
  have him : (∫ y, (A * row y).im ∂haarAddCircle) = (∫ y, A * row y ∂haarAddCircle).im :=
    Complex.imCLM.integral_comp_comm ((hrow.integrable_of_hasCompactSupport
      (HasCompactSupport.of_compactSpace _)).const_mul A)
  rw [him, integral_const_mul]
  change ω + (A * (∫ y, (kernel k a x y : ℂ) * fourier n y ∂haarAddCircle)).im = _
  rw [mean_mode]
  have hz : conj (z x) * z x = 1 := by
    rw [← Complex.normSq_eq_conj_mul_self, Complex.normSq_eq_norm_sq, trajectory_unit, one_pow,
      Complex.ofReal_one]
  have hprod : A * (fourier n x * ((k * multiplier a n : ℝ) : ℂ)) =
      lag * ((k * multiplier a n : ℝ) : ℂ) := calc
    _ = lag * (conj (z x) * z x) * ((k * multiplier a n : ℝ) : ℂ) := by dsimp [A,z,trajectory]; ring
    _ = _ := by rw [hz, mul_one]
  rw [hprod, Complex.mul_im]
  simp [lag, rate]
  ring

/-- The rotating wave solves the original pointwise equation at every real time. -/
theorem trajectory_deriv (ω α k a : ℝ) (n : ℤ) (t : ℝ) (x : UnitAddCircle) :
    HasDerivAt (fun s => trajectory ω α k a n s x)
      (Complex.I * trajectory ω α k a n t x * (speed ω α k a (trajectory ω α k a n t) x : ℂ)) t := by
  rw [trajectory_speed]
  unfold trajectory
  convert (rotatingValue_deriv (rate ω α k a n) 1 t).mul_const (fourier n x) using 1
  ring

/-- Exact counterparts of the three rows of the recovered numerical reference table. -/
theorem historical_rates (a : ℝ) (ha : a = 0 ∨ a = 2/5 ∨ a = 4/5) :
    rate 0 (Real.pi/2 - 1/10) 1 a 0 = -Real.cos (1/10) ∧
    rate 0 (Real.pi/2 - 1/10) 1 a 1 = -(a/2) * Real.cos (1/10) ∧
    rate 0 (Real.pi/2 - 1/10) 1 a (-1) = -(a/2) * Real.cos (1/10) := by
  rcases ha with rfl | rfl | rfl <;> norm_num [rate, multiplier, mass, Real.sin_pi_div_two_sub]

end

end PWFA.HistoricalRing
