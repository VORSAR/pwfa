module

public import PWFA.TorusDistance
public import PWFA.Phase
public import Mathlib.Analysis.SpecialFunctions.SmoothTransition
public import Mathlib.MeasureTheory.Constructions.Pi
public import Mathlib.MeasureTheory.Group.AddCircle
public import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
public import Mathlib.MeasureTheory.Measure.Haar.Basic

/-!
# Unforced oscillator

All three structural kernels use the same normalized area. The resulting complex mean enters
the real angular velocity with a negative phase lag. Coupling strength enters once in that
angular velocity. Multiplication by the imaginary unit and local phase gives a tangent
velocity.

[Specification](../docs/decisions/ADR-110.md) · [Scope and evidence](../docs/verification/slices/torus-oscillator-baseline.md#state-and-phase-equation)
-/

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus PWFA.Phase MeasureTheory MeasureTheory.Measure TopologicalSpace
open scoped ComplexConjugate Topology

noncomputable section

/-- Continuous fields in the ambient space for the phase equation. -/
abbrev Field := C(Point, ℂ)

/-- The radius in units of the torus period. -/
abbrev Radius := { r : ℝ // 0 < r ∧ r < 1 / 2 }

/-- Uniform area on the unit torus, normalized to total mass one. -/
def area : Measure Point :=
  addHaarMeasure (⊤ : PositiveCompacts Point)

theorem area_univ : area Set.univ = 1 := by
  exact addHaarMeasure_self

/-- The smooth bump in the squared radial coordinate. -/
def smoothBump (s : ℝ) : ℝ :=
  expNegInvGlue (1 - s)

theorem smoothBump_integral_pos : 0 < ∫ s in (0 : ℝ)..1, smoothBump s := by
  have hc : Continuous smoothBump :=
    (expNegInvGlue.contDiff (n := 0)).continuous.comp (continuous_const.sub continuous_id)
  apply intervalIntegral.integral_pos (by norm_num) hc.continuousOn
  · exact fun s _ => expNegInvGlue.nonneg (1 - s)
  · refine ⟨0, by norm_num, ?_⟩
    exact expNegInvGlue.pos_of_pos (by norm_num : (0 : ℝ) < 1 - 0)

/-- The smooth finite-range kernel selected in ADR-111. -/
def smoothKernel (radius : Radius) (x y : Point) : ℝ :=
  smoothBump (euclideanDist x y ^ 2 / (radius : ℝ) ^ 2) /
    (Real.pi * (radius : ℝ) ^ 2 * (∫ s in (0 : ℝ)..1, smoothBump s))

/-- Uniform density within a disk of the same support radius. -/
def diskKernel (radius : Radius) (x y : Point) : ℝ :=
  if euclideanDist x y < (radius : ℝ) then (Real.pi * (radius : ℝ) ^ 2)⁻¹ else 0

/-- The all-to-all control, with no distance weighting. -/
def uniformKernel (_ _ : Point) : ℝ := 1

theorem smoothKernel_nonneg (radius : Radius) (x y : Point) : 0 ≤ smoothKernel radius x y :=
  div_nonneg (expNegInvGlue.nonneg _)
    (mul_nonneg (mul_nonneg Real.pi_pos.le (sq_nonneg _)) smoothBump_integral_pos.le)

theorem smoothKernel_zero_of_le_dist (radius : Radius) {x y : Point}
    (h : (radius : ℝ) ≤ euclideanDist x y) : smoothKernel radius x y = 0 := by
  have hsq := pow_le_pow_left₀ radius.property.1.le h 2
  have hratio : 1 ≤ euclideanDist x y ^ 2 / (radius : ℝ) ^ 2 :=
    (one_le_div (pow_pos radius.property.1 2)).2 hsq
  simp [smoothKernel, smoothBump, expNegInvGlue.zero_of_nonpos (sub_nonpos.mpr hratio)]

theorem diskKernel_zero_of_le_dist (radius : Radius) {x y : Point}
    (h : (radius : ℝ) ≤ euclideanDist x y) : diskKernel radius x y = 0 := by
  simp [diskKernel, not_lt_of_ge h]

theorem diskKernel_nonneg (radius : Radius) (x y : Point) : 0 ≤ diskKernel radius x y := by
  unfold diskKernel
  split <;> positivity

structure Parameters where
  frequency : ℝ
  coupling : ℝ
  phaseLag : ℝ

/-- Kernel-weighted complex mean over torus area. -/
def meanField (kernel : Point → Point → ℝ) (z : Field) (x : Point) : ℂ :=
  ∫ y, (kernel x y : ℂ) * z y ∂area

theorem meanField_uniform_const (value : ℂ) (x : Point) :
    meanField uniformKernel (ContinuousMap.const Point value) x = value := by
  simp [meanField, uniformKernel, Measure.real, area_univ]

/-- Real angular velocity with the historical negative phase lag. -/
def angularVelocity (p : Parameters) (z mean : ℂ) : ℝ :=
  p.frequency + p.coupling * (Complex.mk (Real.cos p.phaseLag) (-Real.sin p.phaseLag) *
    conj z * mean).im

theorem angularVelocity_self (p : Parameters) (z : UnitPhase) :
    angularVelocity p z z = p.frequency - p.coupling * Real.sin p.phaseLag := by
  unfold angularVelocity
  rw [mul_assoc, ← Complex.normSq_eq_conj_mul_self, Complex.normSq_eq_norm_sq, z.property]
  simp [sub_eq_add_neg]

/-- The right-hand side at a point, with coupling applied through the angular velocity. -/
def pointVelocity (p : Parameters) (z mean : ℂ) : ℂ :=
  Complex.I * z * (angularVelocity p z mean : ℂ)

theorem pointVelocity_tangent (p : Parameters) (z mean : ℂ) :
    (conj z * pointVelocity p z mean).re = 0 := by
  let speed := angularVelocity p z mean
  change (conj z * (Complex.I * z * (speed : ℂ))).re = 0
  rw [show conj z * (Complex.I * z * (speed : ℂ)) =
      Complex.I * ((speed * Complex.normSq z : ℝ) : ℂ) by
    rw [Complex.ofReal_mul, Complex.normSq_eq_conj_mul_self]
    ring]
  simp

/-- The pointwise unforced phase velocity for a selected structural kernel. -/
def baselineRhs (p : Parameters) (kernel : Point → Point → ℝ) (z : Field) (x : Point) : ℂ :=
  pointVelocity p (z x) (meanField kernel z x)

theorem baselineRhs_tangent (p : Parameters) (kernel : Point → Point → ℝ) (z : Field) (x : Point) :
    (conj (z x) * baselineRhs p kernel z x).re = 0 :=
  pointVelocity_tangent p (z x) (meanField kernel z x)

theorem baselineRhs_uniform_const (p : Parameters) (z : UnitPhase) (x : Point) :
    baselineRhs p uniformKernel (ContinuousMap.const Point (z : ℂ)) x =
      Complex.I * (z : ℂ) * ((p.frequency - p.coupling * Real.sin p.phaseLag : ℝ) : ℂ) := by
  simp only [baselineRhs, ContinuousMap.const_apply, meanField_uniform_const, pointVelocity,
    angularVelocity_self]

end

end PWFA.TorusOscillator
