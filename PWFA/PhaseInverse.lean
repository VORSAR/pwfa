module

public import PWFA.Phase

/-!
# Phase inversion

Complex conjugation reverses the angle and preserves unit modulus. Left and right inverse laws
justify canceling phases in products. Conjugation also appears explicitly in the phase-lag
interaction between a phase and its mean.

[Specification](../docs/decisions/ADR-103.md) · [Scope and evidence](../docs/verification/slices/phase-inverse-experiment.md)
-/

@[expose] public section

namespace PWFA.Phase

open scoped ComplexConjugate

/-- Complex conjugation of a unit phase. -/
def phaseConj (z : UnitPhase) : UnitPhase :=
  ⟨conj z.1, by rw [Complex.norm_conj, z.property]⟩

theorem phaseConj_norm (z : UnitPhase) : ‖(phaseConj z : ℂ)‖ = 1 :=
  (phaseConj z).property

theorem phaseConj_involutive (z : UnitPhase) : phaseConj (phaseConj z) = z := by
  apply Subtype.ext
  change conj (conj z.1) = z.1
  simp

theorem phaseMul_conj_right (z : UnitPhase) : phaseMul z (phaseConj z) = phaseOne := by
  apply Subtype.ext
  change z.1 * conj z.1 = 1
  rw [Complex.mul_conj, Complex.normSq_eq_norm_sq, z.property, one_pow, Complex.ofReal_one]

theorem phaseMul_conj_left (z : UnitPhase) : phaseMul (phaseConj z) z = phaseOne := by
  apply Subtype.ext
  change conj z.1 * z.1 = 1
  rw [mul_comm (conj z.1) z.1]
  exact congrArg (fun w : UnitPhase => w.1) (phaseMul_conj_right z)

end PWFA.Phase
