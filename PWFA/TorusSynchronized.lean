module

public import PWFA.TorusSmoothNormalization
public import Mathlib.Analysis.Complex.RealDeriv
public import Mathlib.Analysis.SpecialFunctions.ExpDeriv

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus PWFA.Phase MeasureTheory

noncomputable section

/-- Rotate an initial value with a fixed real angular velocity. -/
def rotatingValue (rate : ℝ) (initial : ℂ) (t : ℝ) : ℂ :=
  initial * Complex.exp (((t * rate : ℝ) : ℂ) * Complex.I)

theorem rotatingValue_norm (rate : ℝ) (initial : ℂ) (t : ℝ) :
    ‖rotatingValue rate initial t‖ = ‖initial‖ := by
  rw [rotatingValue, norm_mul, Complex.norm_exp_ofReal_mul_I, mul_one]

theorem rotatingValue_deriv (rate : ℝ) (initial : ℂ) (t : ℝ) :
    HasDerivAt (rotatingValue rate initial) (Complex.I * rotatingValue rate initial t * rate) t := by
  have hlinear : HasDerivAt (fun s : ℝ => s * rate) rate t := by
    simpa using (hasDerivAt_id t).mul_const rate
  have hexp := ((hlinear.ofReal_comp.mul_const Complex.I).cexp).const_mul initial
  unfold rotatingValue
  convert hexp using 1
  ring

def synchronizedField (p : Parameters) (initial : UnitPhase) (t : ℝ) : Field :=
  ContinuousMap.const Point (rotatingValue (p.frequency - p.coupling * Real.sin p.phaseLag) initial t)

theorem synchronizedField_zero (p : Parameters) (initial : UnitPhase) :
    synchronizedField p initial 0 = ContinuousMap.const Point (initial : ℂ) := by
  simp [synchronizedField, rotatingValue]

theorem synchronizedField_unit (p : Parameters) (initial : UnitPhase) (t : ℝ) (x : Point) :
    ‖synchronizedField p initial t x‖ = 1 := by
  simpa only [synchronizedField, ContinuousMap.const_apply, rotatingValue_norm] using initial.property

theorem meanField_const_of_unit_mass {kernel : Point → Point → ℝ} (x : Point)
    (hm : (∫ y, kernel x y ∂area) = 1) (value : ℂ) :
    meanField kernel (ContinuousMap.const Point value) x = value := by
  simp only [meanField, ContinuousMap.const_apply, integral_mul_const, integral_complex_ofReal, hm,
    Complex.ofReal_one, one_mul]

/-- Exact synchronized solution for every normalized translation-invariant kernel. -/
theorem synchronizedField_deriv (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area)
    (hmass : (∫ y, kernel 0 y ∂area) = 1) (initial : UnitPhase) (t : ℝ) :
    HasDerivAt (synchronizedField p initial)
      (continuousRhs p kernel h hrow (synchronizedField p initial t)) t := by
  let rate := p.frequency - p.coupling * Real.sin p.phaseLag
  let z := rotatingValue rate initial t
  let liftConst : ℂ →L[ℝ] Field := ContinuousLinearMap.const ℝ Point
  have hvel : continuousRhs p kernel h hrow (synchronizedField p initial t) =
      liftConst (Complex.I * z * rate) := by
    ext x
    change pointVelocity p z (meanField kernel (ContinuousMap.const Point z) x) =
      Complex.I * z * rate
    rw [meanField_const_of_unit_mass x ((integral_kernel_row_eq_origin h x).trans hmass)]
    let phase : UnitPhase := ⟨z, (rotatingValue_norm rate initial t).trans initial.property⟩
    change Complex.I * z * (angularVelocity p phase phase : ℂ) = _
    rw [angularVelocity_self]
  rw [hvel]
  exact liftConst.hasFDerivAt.comp_hasDerivAt t (rotatingValue_deriv rate initial t)

end

end PWFA.TorusOscillator
