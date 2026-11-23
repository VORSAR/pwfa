/-
PWFA SLICE-001-PHASE — EXPERIMENTAL, NOT INDEPENDENTLY CERTIFIED.

Authorized by ADR-109 after bounded internal hostile review.
Excludes spatial geometry, evolution, learning, memory, continuity, winding and benchmarks.
These statements are purely algebraic facts about complex values of norm one.

Proof obligations: docs/verification/slices/phase-algebra-experiment.md
-/
module

public import Mathlib.Analysis.Complex.Norm

@[expose] public section

namespace PWFA
namespace Phase

universe u

/-- Complex phase values constrained to have unit norm. -/
abbrev UnitPhase := { z : ℂ // ‖z‖ = 1 }

/-- An unrestricted field of unit complex phases on any location type.
    No spatial continuity or topology is asserted here. -/
abbrev PhaseField (X : Type u) := X → UnitPhase

/-- The multiplicative identity is a valid phase. -/
def phaseOne : UnitPhase := ⟨1, by simpa using Complex.norm_natCast 1⟩

/-- Multiplication of two valid phases preserves unit norm. -/
def phaseMul (u v : UnitPhase) : UnitPhase :=
  ⟨u.1 * v.1, by rw [Complex.norm_mul, u.property, v.property, one_mul]⟩

/-- PH-P01: The unit phase has norm one. -/
theorem phaseOne_norm : ‖(phaseOne : ℂ)‖ = 1 :=
  phaseOne.property

/-- PH-P02: A product of unit phases has norm one. -/
theorem phaseMul_norm (u v : UnitPhase) :
    ‖((phaseMul u v : UnitPhase) : ℂ)‖ = 1 :=
  (phaseMul u v).property

/-- PH-P03: Phase multiplication is associative. -/
theorem phaseMul_assoc (u v w : UnitPhase) :
    phaseMul (phaseMul u v) w = phaseMul u (phaseMul v w) := by
  apply Subtype.ext
  change (u.1 * v.1) * w.1 = u.1 * (v.1 * w.1)
  exact mul_assoc _ _ _

/-- PH-P04: Multiplication by the identity on the left preserves a phase. -/
theorem phaseMul_one_left (u : UnitPhase) :
    phaseMul phaseOne u = u := by
  apply Subtype.ext
  change (1 : ℂ) * u.1 = u.1
  exact one_mul _

/-- PH-P05: Multiplication by the identity on the right preserves a phase. -/
theorem phaseMul_one_right (u : UnitPhase) :
    phaseMul u phaseOne = u := by
  apply Subtype.ext
  change u.1 * (1 : ℂ) = u.1
  exact mul_one _

/-- Phase multiplication lifted pointwise to arbitrary fields. -/
def pointwiseMul {X : Type u} (f g : PhaseField X) : PhaseField X :=
  fun x => phaseMul (f x) (g x)

/-- PH-P06: Pointwise multiplication preserves unit norm everywhere. -/
theorem pointwiseMul_norm {X : Type u}
    (f g : PhaseField X) (x : X) :
    ‖((pointwiseMul f g x : UnitPhase) : ℂ)‖ = 1 :=
  (pointwiseMul f g x).property

end Phase
end PWFA
