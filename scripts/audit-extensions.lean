module

import PWFA
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

open Lean PWFA.Phase PWFA.Torus
open scoped ComplexConjugate

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

run_cmd do
  let allowedAxioms := #[`propext, `Classical.choice, `Quot.sound]
  let declarations := #[
    ``phaseConj, ``phaseConj_norm, ``phaseConj_involutive, ``phaseMul_conj_left, ``phaseMul_conj_right,
    ``Point, ``ofCoordinates, ``ofCoordinates_add_lattice, ``euclideanDist, ``euclideanDist_eq_sqrt_sum,
    ``euclideanDist_nonneg, ``euclideanDist_eq_zero, ``euclideanDist_comm, ``euclideanDist_triangle,
    ``euclideanDist_add_right, ``latticeLength, ``euclideanDist_le_latticeLength,
    ``exists_latticeLength_eq_euclideanDist, ``euclideanDist_isLeast_latticeLength,
    ``euclideanDist_le_diameter, ``euclideanDist_diagonal, ``productDist_diagonal]
  for name in declarations do
    let axioms ← Lean.collectAxioms name
    let unexpected := axioms.filter fun axiomName => !allowedAxioms.contains axiomName
    unless unexpected.isEmpty do
      throwError "{name} depends on unsupported axioms: {unexpected}"
    logInfo m!"{name}: {axioms}"
