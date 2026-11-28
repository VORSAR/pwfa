module

import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# One bit among neighbours held at their two positions

The [literature note](../../docs/research/one-run-correction-in-the-literature.md) compares
three ways to let a single retrieval run correct a wrong bit: the present first-harmonic
learned pull given more time, an added second-harmonic term, and a mirrored two-network
design. The note records the review findings OB-01 through OB-04. Here every other bit
center is held at ±90° from the origin and one bit is free at angle `θ`. Its pull from a
neighbour is the stored value times the sine of the phase difference, as in
[ADR-128](../../docs/decisions/ADR-128.md) and [ADR-129](../../docs/decisions/ADR-129.md).
Shoulder and background sites are left out. Nothing here follows a full trajectory.
-/

namespace BitAmongFixedNeighbours
noncomputable section

/-- A presented 1 has sign `+1` and a presented 0 has sign `-1`. -/
private def sign (b : Bool) : ℝ := if b then 1 else -1

private theorem sign_true : sign true = 1 := by simp [sign]
private theorem sign_false : sign false = -1 := by simp [sign]

-- OB-01. The first-harmonic pull of a held neighbour on the free bit is the
-- neighbour's symbol times cos θ. It vanishes when the free bit is at ±90°.
private theorem first_harmonic_pull (x : Bool) (θ : ℝ) :
    Real.sin (Real.pi/2 * sign x - θ) = sign x * Real.cos θ := by
  cases x <;> simp only [sign_true, sign_false]
  · rw [show Real.pi/2 * (-1 : ℝ) - θ = -(θ + Real.pi/2) by ring, Real.sin_neg,
      Real.sin_add_pi_div_two]
    ring
  · rw [show Real.pi/2 * (1 : ℝ) - θ = Real.pi/2 - θ by ring, Real.sin_pi_div_two_sub]
    ring

-- Summed over the neighbours, the pull is the memory row applied to their
-- symbols, times cos θ. The first factor is the evidence a Hopfield update uses.
private theorem evidence_pull {ι : Type} (s : Finset ι) (memory : ι → ℝ) (cue : ι → Bool)
    (θ : ℝ) :
    ∑ a ∈ s, memory a * Real.sin (Real.pi/2 * sign (cue a) - θ) =
      (∑ a ∈ s, memory a * sign (cue a)) * Real.cos θ := by
  rw [Finset.sum_mul]
  exact Finset.sum_congr rfl fun a _ => by rw [first_harmonic_pull]; ring

-- OB-02. A second-harmonic pull from a held neighbour does not depend on the
-- neighbour's symbol. It only draws the free bit toward +90° or -90°.
private theorem second_harmonic_pull (x : Bool) (θ : ℝ) :
    Real.sin (2 * (Real.pi/2 * sign x - θ)) = Real.sin (2 * θ) := by
  cases x <;> simp only [sign_true, sign_false]
  · rw [show 2 * (Real.pi/2 * (-1 : ℝ) - θ) = -(2 * θ) - Real.pi by ring, Real.sin_sub_pi,
      Real.sin_neg]
    ring
  · rw [show 2 * (Real.pi/2 * (1 : ℝ) - θ) = Real.pi - 2 * θ by ring, Real.sin_pi_sub]

/-- Angular velocity of the free bit: evidence `h` through the first harmonic and a
second-harmonic term of total strength `c`. -/
private def velocity (h c θ : ℝ) : ℝ := h * Real.cos θ + c * Real.sin (2 * θ)

-- Displace the bit by `u` from its position `y`. Its velocity toward that
-- position is sin u times (y h + 2 c cos u). For 0 < u < 90° the first factor is
-- positive, so the bit returns exactly when the second factor is positive.
private theorem toward_position (h c u : ℝ) (y : Bool) :
    sign y * velocity h c (sign y * (Real.pi/2 - u)) =
      Real.sin u * (sign y * h + 2 * c * Real.cos u) := by
  cases y <;> simp only [sign_true, sign_false, velocity]
  · rw [show (-1 : ℝ) * (Real.pi/2 - u) = -(Real.pi/2 - u) by ring, Real.cos_neg,
      Real.cos_pi_div_two_sub, show 2 * -(Real.pi/2 - u) = -(Real.pi - 2 * u) by ring,
      Real.sin_neg, Real.sin_pi_sub, Real.sin_two_mul]
    ring
  · rw [show (1 : ℝ) * (Real.pi/2 - u) = Real.pi/2 - u by ring, Real.cos_pi_div_two_sub,
      show 2 * (Real.pi/2 - u) = Real.pi - 2 * u by ring, Real.sin_pi_sub, Real.sin_two_mul]
    ring

-- First harmonic alone: a bit that agrees with its evidence returns to its
-- position, and a bit that opposes its evidence moves away from it.
private theorem first_harmonic_follows_evidence (h u : ℝ) (y : Bool)
    (hu : 0 < Real.sin u) :
    (0 < sign y * velocity h 0 (sign y * (Real.pi/2 - u)) ↔ 0 < sign y * h) := by
  rw [toward_position,
    show Real.sin u * (sign y * h + 2 * 0 * Real.cos u) = Real.sin u * (sign y * h) by ring]
  constructor
  · intro hp
    by_contra hneg
    have hle : sign y * h ≤ 0 := not_lt.mp hneg
    nlinarith [mul_nonneg hu.le (neg_nonneg.mpr hle)]
  · intro hp
    exact mul_pos hu hp

-- With the second-harmonic term, a wrong bit stays wrong whenever its evidence
-- is weaker than 2 c cos u. A term that is too strong freezes mistakes.
private theorem second_harmonic_can_freeze (h c u : ℝ) (y : Bool) (hu : 0 < Real.sin u)
    (weak : -(sign y * h) < 2 * c * Real.cos u) :
    0 < sign y * velocity h c (sign y * (Real.pi/2 - u)) := by
  rw [toward_position]
  exact mul_pos hu (by linarith)

-- OB-03. The mirrored two-network design of Heger and Krischer has, for one
-- free bit with phase difference Δ and `M` stored words, the effective rate
-- -sin Δ (h + (M/2) cos Δ) up to a positive factor. Measured from the origin
-- as θ = 90° - Δ, that is the velocity above with second-harmonic strength M/4.
private theorem mirrored_design_rate (h M θ : ℝ) :
    Real.sin (Real.pi/2 - θ) * (h + M/2 * Real.cos (Real.pi/2 - θ)) = velocity h (M/4) θ := by
  rw [Real.sin_pi_div_two_sub, Real.cos_pi_div_two_sub, velocity, Real.sin_two_mul]
  ring

-- OB-04. The learned gain multiplies the whole learned velocity. With no
-- structural coupling a larger gain therefore acts as a faster clock.
private theorem gain_scales_velocity {ι : Type} (s : Finset ι) (g : ℝ) (memory angle : ι → ℝ)
    (here : ℝ) :
    ∑ a ∈ s, g * memory a * Real.sin (angle a - here) =
      g * ∑ a ∈ s, memory a * Real.sin (angle a - here) := by
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun a _ => by ring

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``first_harmonic_pull, ``evidence_pull, ``second_harmonic_pull,
      ``toward_position, ``first_harmonic_follows_evidence, ``second_harmonic_can_freeze,
      ``mirrored_design_rate, ``gain_scales_velocity] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end BitAmongFixedNeighbours
