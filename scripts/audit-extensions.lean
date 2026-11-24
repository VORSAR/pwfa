module

import PWFA
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Audit of the torus architecture

The examples check geometric, kernel and trajectory statements through the public import.
Concrete kernel instances exercise generic results with the hypotheses of the selected
architecture. Dependency inspection checks the foundations used to prove those statements.

[Specification](../docs/verification/slices/torus-oscillator-baseline.md) · [Scope and evidence](../docs/verification/review-gates.md)
-/

open Lean PWFA.Phase PWFA.Torus
open scoped ComplexConjugate Topology
open Filter Set

example (z : UnitPhase) : (phaseConj z : ℂ) = conj (z : ℂ) := rfl

example (z : UnitPhase) :
    phaseMul (phaseConj z) z = phaseOne ∧ phaseMul z (phaseConj z) = phaseOne :=
  ⟨phaseMul_conj_left z, phaseMul_conj_right z⟩

example (x y : Fin 2 → ℝ) :
    IsLeast (Set.range (latticeLength x y)) (euclideanDist (ofCoordinates x) (ofCoordinates y)) :=
  euclideanDist_isLeast_latticeLength x y

example :
    euclideanDist 0 (ofCoordinates (fun _ => 1 / 2)) = Real.sqrt 2 / 2 ∧
    dist (0 : Point) (ofCoordinates (fun _ => 1 / 2)) = 1 / 2 :=
  ⟨euclideanDist_diagonal, productDist_diagonal⟩

open PWFA.TorusOscillator in
example (p : Parameters) (z : UnitPhase) (x : Point) :
    baselineRhs p uniformKernel (ContinuousMap.const Point (z : ℂ)) x =
      Complex.I * (z : ℂ) * ((p.frequency - p.coupling * Real.sin p.phaseLag : ℝ) : ℂ) :=
  baselineRhs_uniform_const p z x

open PWFA.TorusOscillator in
example (r : Radius) (x y : Point) (h : (r : ℝ) ≤ euclideanDist x y) :
    smoothKernel r x y = 0 ∧ diskKernel r x y = 0 :=
  ⟨smoothKernel_zero_of_le_dist r h, diskKernel_zero_of_le_dist r h⟩

open PWFA.TorusOscillator in
example (p : Parameters) (r : Radius) (z : Field) :
    Continuous (baselineRhs p (diskKernel r) z) :=
  continuous_baselineRhs p (diskKernel_translationInvariant r) (integrable_diskKernel_row r 0) z

open PWFA.TorusOscillator in
example (z : Field) (x : Point) : ‖meanField uniformKernel z x‖ ≤ ‖z‖ :=
  norm_meanField_uniform_le z x

open PWFA.TorusOscillator in
example (p : Parameters) (r : Radius) (initial : Field) :
    ∃ ε > (0 : ℝ), ∃ solution : ℝ → Field, solution 0 = initial ∧
      ∀ t ∈ Ioo (-ε) ε, HasDerivAt solution (continuousRhs p (diskKernel r)
        (diskKernel_translationInvariant r) (integrable_diskKernel_row r 0) (solution t)) t := by
  exact exists_local_solution p (diskKernel_translationInvariant r) (integrable_diskKernel_row r 0)
    initial

open PWFA.TorusOscillator in
example (p : Parameters) (r : Radius) {z w : ℝ → Field} (hinitial : z 0 = w 0)
    (hz : ∀ᶠ t in 𝓝 0, HasDerivAt z (continuousRhs p (diskKernel r)
        (diskKernel_translationInvariant r) (integrable_diskKernel_row r 0) (z t)) t)
    (hw : ∀ᶠ t in 𝓝 0, HasDerivAt w (continuousRhs p (diskKernel r)
        (diskKernel_translationInvariant r) (integrable_diskKernel_row r 0) (w t)) t) :
    z =ᶠ[𝓝 0] w :=
  local_solution_unique p (diskKernel_translationInvariant r) (integrable_diskKernel_row r 0)
    hinitial hz hw

open PWFA.TorusOscillator in
example (p : Parameters) (r : Radius) (initial : Field) (hunit : ∀ x, ‖initial x‖ = 1) :
    ∃ ε > (0 : ℝ), ∃ solution : ℝ → Field, solution 0 = initial ∧
      ∀ t ∈ Ioo (-ε) ε,
        HasDerivAt solution (continuousRhs p (smoothKernel r)
          (smoothKernel_translationInvariant r) (integrable_smoothKernel_row r 0) (solution t)) t ∧
          ∀ x, ‖solution t x‖ = 1 :=
  exists_local_phase_solution p (smoothKernel_translationInvariant r)
    (integrable_smoothKernel_row r 0) initial hunit

open PWFA.TorusOscillator MeasureTheory in
example (r : Radius) (x : Point) :
    area {y | euclideanDist x y < (r : ℝ)} = ENNReal.ofReal (Real.pi * (r : ℝ) ^ 2) ∧
      (∫ y, diskKernel r x y ∂area) = 1 :=
  ⟨area_disk r x, integral_diskKernel r x⟩

open PWFA.TorusOscillator in
example (r : Radius) (z : Field) (x : Point) : ‖meanField (diskKernel r) z x‖ ≤ ‖z‖ :=
  norm_meanField_le_of_unit_mass (diskKernel_translationInvariant r) (integrable_diskKernel_row r 0)
    (diskKernel_nonneg r 0) (integral_diskKernel r 0) z x

open PWFA.TorusOscillator MeasureTheory in
example (r : Radius) (x : Point) (z : Field) :
    (∫ y, smoothKernel r x y ∂area) = 1 ∧ ‖meanField (smoothKernel r) z x‖ ≤ ‖z‖ :=
  ⟨integral_smoothKernel r x, norm_meanField_smooth_le r z x⟩

open PWFA.TorusOscillator in
example (p : Parameters) (z : UnitPhase) (r : Radius) (t : ℝ) :
    HasDerivAt (synchronizedField p z) (continuousRhs p (smoothKernel r)
      (smoothKernel_translationInvariant r) (integrable_smoothKernel_row r 0) (synchronizedField p z t)) t ∧
    HasDerivAt (synchronizedField p z) (continuousRhs p (diskKernel r)
      (diskKernel_translationInvariant r) (integrable_diskKernel_row r 0) (synchronizedField p z t)) t ∧
    HasDerivAt (synchronizedField p z) (continuousRhs p uniformKernel
      uniformKernel_translationInvariant (integrable_uniformKernel_row 0) (synchronizedField p z t)) t :=
  ⟨synchronizedField_deriv p _ _ (integral_smoothKernel r 0) z t,
    synchronizedField_deriv p _ _ (integral_diskKernel r 0) z t,
    synchronizedField_deriv p _ _ (by simp [uniformKernel]) z t⟩

open PWFA.TorusOscillator in
example (p : Parameters) (r : Radius) (initial : Field) (hunit : ∀ x, ‖initial x‖ = 1) :
    ∃! f : ℝ → Field, f 0 = initial ∧ ∀ t, HasDerivAt f (continuousRhs p (smoothKernel r)
      (smoothKernel_translationInvariant r) (integrable_smoothKernel_row r 0) (f t)) t :=
  existsUnique_global_phase_solution p _ _ initial hunit

open PWFA.TorusOscillator MeasureTheory in
example (p : Parameters) {kernel : Point → Point → ℝ} (h : TranslationInvariant kernel)
    (hr : Integrable (kernel 0) area) {f : ℝ → Field} (hu : ∀ x, ‖f 0 x‖ = 1)
    (hf : ∀ s, HasDerivAt f (continuousRhs p kernel h hr (f s)) s) (t : ℝ) :
    (coordinateWinding (f t) (global_solution_unit p h hr hu hf t) 0,
      coordinateWinding (f t) (global_solution_unit p h hr hu hf t) 1) =
    (coordinateWinding (f 0) hu 0, coordinateWinding (f 0) hu 1) :=
  congrArg₂ Prod.mk (global_solution_coordinateWinding p h hr hu hf t 0)
    (global_solution_coordinateWinding p h hr hu hf t 1)

-- This accepts every integer pair, including negative axes and the (1,1) diagonal.
open PWFA.TorusOscillator in
example (p : Parameters) (r : Radius) (q : WaveIndex) (t : ℝ) :
    HasDerivAt (waveField p (smoothKernel r) q) (continuousRhs p (smoothKernel r)
      (smoothKernel_translationInvariant r) (integrable_smoothKernel_row r 0)
      (waveField p (smoothKernel r) q t)) t :=
  waveField_deriv p (smoothKernel_translationInvariant r) (integrable_smoothKernel_row r 0)
    (smoothKernel_radial r) q t

open PWFA.TorusOscillator in
example (p : Parameters) {q : WaveIndex} (hq : q ≠ 0) :
    waveRate p uniformKernel q = p.frequency := by
  simp [waveRate, waveCoefficient_uniform_nonzero hq]

open PWFA.TorusOscillator in
example (r : Radius) (q : WaveIndex) :
    (waveCoefficient (diskKernel r) q).re =
      4 / (Real.pi * (r : ℝ) ^ 2) * ∫ x in (0 : ℝ)..(r : ℝ),
        Real.sqrt ((r : ℝ) ^ 2 - x ^ 2) * Real.cos (2 * Real.pi * ‖frequencyVector q‖ * x) :=
  waveCoefficient_disk_chord r q

open PWFA.TorusOscillator ContDiff in
example (r : Radius) (x : Fin 2 → ℝ) :
    ContDiffAt ℝ ∞ (liftedSmoothKernel r) (x,x) :=
  (contDiff_liftedSmoothKernel r).contDiffAt

open PWFA.TorusOscillator in
example (r : Radius) (x y : Fin 2 → ℝ)
    (h : euclideanDist (ofCoordinates x) (ofCoordinates y) = (r : ℝ)) (n : ℕ) :
    iteratedFDeriv ℝ n (liftedSmoothKernel r) (x,y) = 0 :=
  liftedSmoothKernel_flat_at_edge r (x,y) h n

open PWFA.HistoricalRing AddCircle MeasureTheory in
example (k a : ℝ) (x : UnitAddCircle) : (∫ y, kernel k a x y ∂haarAddCircle) = k :=
  integral_kernel k a x

-- The two nonuniform contrasts give different first-harmonic rates, in either direction.
open PWFA.HistoricalRing in
example : rate 0 (Real.pi/2 - 1/10) 1 (2/5) 1 = -(1/5) * Real.cos (1/10) ∧
    rate 0 (Real.pi/2 - 1/10) 1 (4/5) (-1) = -(2/5) * Real.cos (1/10) := by
  constructor
  · convert (historical_rates (2/5) (Or.inr (Or.inl rfl))).2.1 using 1
    ring
  · convert (historical_rates (4/5) (Or.inr (Or.inr rfl))).2.2 using 1
    ring

open PWFA.TorusOscillator in
run_cmd do
  let allowedAxioms := #[`propext, `Classical.choice, `Quot.sound]
  let declarations := #[
    ``phaseConj, ``phaseConj_norm, ``phaseConj_involutive, ``phaseMul_conj_left, ``phaseMul_conj_right,
    ``Point, ``ofCoordinates, ``ofCoordinates_add_lattice, ``euclideanDist, ``euclideanDist_eq_sqrt_sum,
    ``euclideanDist_nonneg, ``euclideanDist_eq_zero, ``euclideanDist_comm, ``euclideanDist_triangle,
    ``euclideanDist_add_right, ``latticeLength, ``euclideanDist_le_latticeLength,
    ``exists_latticeLength_eq_euclideanDist, ``euclideanDist_isLeast_latticeLength,
    ``euclideanDist_le_diameter, ``euclideanDist_diagonal, ``productDist_diagonal,
    ``PWFA.TorusOscillator.Field, ``Radius, ``area, ``area_univ, ``smoothBump, ``smoothBump_integral_pos,
    ``smoothKernel, ``smoothKernel_nonneg, ``smoothKernel_zero_of_le_dist, ``diskKernel,
    ``diskKernel_nonneg, ``diskKernel_zero_of_le_dist, ``uniformKernel, ``Parameters,
    ``meanField, ``meanField_uniform_const, ``angularVelocity, ``angularVelocity_self,
    ``pointVelocity, ``pointVelocity_tangent, ``baselineRhs, ``baselineRhs_tangent,
    ``baselineRhs_uniform_const, ``continuous_euclideanDist, ``TranslationInvariant,
    ``smoothKernel_translationInvariant, ``diskKernel_translationInvariant,
    ``uniformKernel_translationInvariant, ``continuous_smoothKernel_row,
    ``integral_smoothBump_radial, ``integral_smoothKernel, ``norm_meanField_smooth_le,
    ``rotatingValue_deriv, ``rotatingValue_norm, ``synchronizedField_zero, ``synchronizedField_unit, ``meanField_const_of_unit_mass, ``synchronizedField_deriv,
    ``exists_uniform_local_solution, ``global_solution_unit, ``existsUnique_global_phase_solution,
    ``coordinateLoop, ``coordinateWinding, ``coordinateWinding_eq_on_interval, ``local_solution_coordinateWinding, ``global_solution_coordinateWinding,
    ``waveCoefficient_real, ``waveCoefficient_zero, ``waveCoefficient_neg, ``waveCoefficient_swap, ``waveCoefficient_uniform_nonzero, ``waveField_zero, ``waveField_unit, ``waveField_deriv, ``setIntegral_disk_coordinates, ``waveCoefficient_disk_chord,
    ``liftedSmoothKernel_periodic, ``contDiff_liftedSmoothKernel, ``liftedSmoothKernel_flat_at_edge, ``liftedSmoothKernel_zero_near_tie,
    ``PWFA.HistoricalRing.kernel_coordinates, ``PWFA.HistoricalRing.integral_kernel, ``PWFA.HistoricalRing.mean_mode, ``PWFA.HistoricalRing.trajectory_initial, ``PWFA.HistoricalRing.trajectory_unit, ``PWFA.HistoricalRing.trajectory_speed, ``PWFA.HistoricalRing.trajectory_deriv, ``PWFA.HistoricalRing.historical_rates,
    ``measurableSet_disk, ``area_disk, ``integral_diskKernel,
    ``integrable_smoothKernel_row, ``integrable_diskKernel_row, ``integrable_uniformKernel_row,
    ``integral_kernel_row_eq_origin, ``meanField_eq_translate, ``continuous_meanField,
    ``norm_meanField_le, ``norm_meanField_le_of_unit_mass, ``norm_meanField_uniform_le,
    ``meanOperator, ``meanOperator_apply, ``norm_meanOperator_le, ``norm_meanOperator_sub_le,
    ``continuous_baselineRhs, ``continuousRhs, ``norm_continuousRhs_sub_le,
    ``lipschitzOnWith_continuousRhs, ``exists_local_solution, ``local_solution_unique,
    ``norm_local_solution_eq_initial, ``exists_local_phase_solution]
  for name in declarations do
    let axioms ← Lean.collectAxioms name
    let unexpected := axioms.filter fun axiomName => !allowedAxioms.contains axiomName
    unless unexpected.isEmpty do
      throwError "{name} depends on unsupported axioms: {unexpected}"
    logInfo m!"{name}: {axioms}"
