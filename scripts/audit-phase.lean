module

import PWFA
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Audit of the phase contract

The examples pin the mathematical carrier, operations and required theorem types. The
declaration audit examines their proof dependencies. Together these checks cover the semantics
of the public interface as well as the foundations of its proofs.

[Specification](../docs/verification/slices/phase-algebra-experiment.md) · [Scope and evidence](../docs/verification/review-gates.md)
-/

open Lean PWFA.Phase

universe u

-- Check the meanings of the definitions independently of their theorem statements.
example : UnitPhase = {z : ℂ // ‖z‖ = 1} := rfl
example (X : Type u) : PhaseField X = (X → UnitPhase) := rfl
example : (phaseOne : ℂ) = 1 := rfl

example (a b : UnitPhase) : (phaseMul a b : ℂ) = (a : ℂ) * (b : ℂ) := rfl

example {X : Type u} (f g : PhaseField X) (x : X) :
    pointwiseMul f g x = phaseMul (f x) (g x) := rfl

-- Check PH-P01 through PH-P06 through the public PWFA entry point.
example : ‖(phaseOne : ℂ)‖ = 1 := phaseOne_norm
example (a b : UnitPhase) : ‖(phaseMul a b : ℂ)‖ = 1 := phaseMul_norm a b

example (a b c : UnitPhase) :
    phaseMul (phaseMul a b) c = phaseMul a (phaseMul b c) := phaseMul_assoc a b c

example (a : UnitPhase) : phaseMul phaseOne a = a := phaseMul_one_left a
example (a : UnitPhase) : phaseMul a phaseOne = a := phaseMul_one_right a

example {X : Type u} (f g : PhaseField X) (x : X) :
    ‖(pointwiseMul f g x : ℂ)‖ = 1 := pointwiseMul_norm f g x

run_cmd do
  let allowedAxioms := #[`propext, `Classical.choice, `Quot.sound]
  let declarations := #[``UnitPhase, ``PhaseField, ``phaseOne, ``phaseMul, ``pointwiseMul,
    ``phaseOne_norm, ``phaseMul_norm, ``phaseMul_assoc, ``phaseMul_one_left,
    ``phaseMul_one_right, ``pointwiseMul_norm]
  for name in declarations do
    let axioms ← Lean.collectAxioms name
    let unexpected := axioms.filter fun axiomName => !allowedAxioms.contains axiomName
    unless unexpected.isEmpty do
      throwError "{name} depends on unsupported axioms: {unexpected}"
    logInfo m!"{name}: {axioms}"
