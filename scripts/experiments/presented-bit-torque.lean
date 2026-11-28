module

import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Which sites does a bit feel at the start of learned retrieval?

[ADR-118](../../docs/decisions/ADR-118.md) selects ±90° as the primary bit phases and
±45° as the comparison. [ADR-128](../../docs/decisions/ADR-128.md) and
[ADR-129](../../docs/decisions/ADR-129.md) make the learned torque on a site the stored
pair value times the sine of the phase difference. The
[ordinary retrieval](../../docs/experiments/structural-coupling-at-retrieval.md#paired-results-at-t40)
kept every presented bit, and the
[queried-bit readout](../../docs/experiments/recall-with-queried-bit-hidden.md#results-at-t40)
corrected most flips. The [research note](../../docs/research/learned-retrieval-at-time-zero.md)
records the review findings PT-01 through PT-03. These statements concern the prepared cue at
time zero with structural coupling off. They say nothing about the trajectory after that instant.
-/

namespace PresentedBitTorque
noncomputable section

/-- A presented 1 has sign `+1` and a presented 0 has sign `-1`. -/
private def sign (b : Bool) : ℝ := if b then 1 else -1

private theorem sign_true : sign true = 1 := by simp [sign]
private theorem sign_false : sign false = -1 := by simp [sign]

-- Primary alphabet: two presented centers are a whole number of half turns apart,
-- so neither exerts a learned torque on the other for any stored pair value.
private theorem primary_pair_torque (x y : Bool) :
    Real.sin (Real.pi/2 * sign x - Real.pi/2 * sign y) = 0 := by
  cases x <;> cases y <;> simp only [sign_true, sign_false]
  · simp
  · rw [show Real.pi/2 * (-1 : ℝ) - Real.pi/2 * 1 = -Real.pi by ring]; simp
  · rw [show Real.pi/2 * (1 : ℝ) - Real.pi/2 * (-1) = Real.pi by ring]; simp
  · simp

-- Hence the other presented centers contribute nothing to a presented center,
-- whatever the memory row and whatever the other symbols are.
private theorem primary_presented_field {ι : Type} (s : Finset ι) (memory : ι → ℝ)
    (cue : ι → Bool) (y : Bool) :
    ∑ a ∈ s, memory a * Real.sin (Real.pi/2 * sign (cue a) - Real.pi/2 * sign y) = 0 := by
  simp [primary_pair_torque]

-- A shoulder site at any angle `α` pulls a presented center by an amount that
-- depends on the center's own symbol only. The neighbor's symbol cancels.
private theorem shoulder_on_presented (α : ℝ) (x y : Bool) :
    Real.sin (α * sign x - Real.pi/2 * sign y) = -(sign y * Real.cos α) := by
  cases x <;> cases y <;> simp only [sign_true, sign_false]
  · rw [show α * (-1 : ℝ) - Real.pi/2 * (-1) = Real.pi/2 - α by ring, Real.sin_pi_div_two_sub]
    ring
  · rw [show α * (-1 : ℝ) - Real.pi/2 * 1 = -(α + Real.pi/2) by ring, Real.sin_neg,
      Real.sin_add_pi_div_two]
    ring
  · rw [show α * (1 : ℝ) - Real.pi/2 * (-1) = α + Real.pi/2 by ring, Real.sin_add_pi_div_two]
    ring
  · rw [show α * (1 : ℝ) - Real.pi/2 * 1 = α - Real.pi/2 by ring, Real.sin_sub_pi_div_two]
    ring

private theorem shoulder_ignores_neighbor (α : ℝ) (x x' y : Bool) :
    Real.sin (α * sign x - Real.pi/2 * sign y) = Real.sin (α * sign x' - Real.pi/2 * sign y) := by
  rw [shoulder_on_presented, shoulder_on_presented]

-- PT-01: every site of an omitted bit, and every background site, sits at
-- angle zero. Its pull on a presented center is again fixed by that center's
-- own symbol. No site therefore carries another bit's value to a presented center.
private theorem zero_site_on_presented (y : Bool) :
    Real.sin (0 - Real.pi/2 * sign y) = -sign y := by
  cases y <;> simp [sign_true, sign_false]

-- A center whose stimulus is omitted stays at the background angle zero. Each
-- presented center then acts on it with its full signed symbol, so the summed
-- torque is the memory row applied to the visible symbols.
private theorem omitted_center_field {ι : Type} (s : Finset ι) (memory : ι → ℝ)
    (cue : ι → Bool) :
    ∑ a ∈ s, memory a * Real.sin (Real.pi/2 * sign (cue a) - 0) =
      ∑ a ∈ s, memory a * sign (cue a) := by
  refine Finset.sum_congr rfl fun a _ => ?_
  cases cue a <;> simp [sign_true, sign_false]

-- Shoulders act on an omitted center, and on any background site including
-- the origin anchor, with the same sign as their bit.
private theorem shoulder_on_background (α : ℝ) (x : Bool) :
    Real.sin (α * sign x - 0) = sign x * Real.sin α := by
  cases x <;> simp [sign_true, sign_false]

-- Comparison alphabet: unlike presented centers are a quarter turn apart and
-- do exert a torque. It is half the difference of the two signed symbols.
private theorem comparison_pair_torque (x y : Bool) :
    Real.sin (Real.pi/4 * sign x - Real.pi/4 * sign y) = (sign x - sign y) / 2 := by
  cases x <;> cases y <;> simp only [sign_true, sign_false]
  · simp
  · rw [show Real.pi/4 * (-1 : ℝ) - Real.pi/4 * 1 = -(Real.pi/2) by ring, Real.sin_neg,
      Real.sin_pi_div_two]
    norm_num
  · rw [show Real.pi/4 * (1 : ℝ) - Real.pi/4 * (-1) = Real.pi/2 by ring, Real.sin_pi_div_two]
    norm_num
  · simp

-- Stored pair values at the two alphabets. The primary value is the signed
-- product. The comparison value is never negative.
private theorem stored_pair_values (s t : Bool) :
    Real.cos (Real.pi/2 * sign s - Real.pi/2 * sign t) = sign s * sign t ∧
    Real.cos (Real.pi/4 * sign s - Real.pi/4 * sign t) = (1 + sign s * sign t) / 2 := by
  cases s <;> cases t <;> simp only [sign_true, sign_false]
  · constructor <;> simp
  · rw [show Real.pi/2 * (-1 : ℝ) - Real.pi/2 * 1 = -Real.pi by ring,
      show Real.pi/4 * (-1 : ℝ) - Real.pi/4 * 1 = -(Real.pi/2) by ring]
    constructor <;> simp
  · rw [show Real.pi/2 * (1 : ℝ) - Real.pi/2 * (-1) = Real.pi by ring,
      show Real.pi/4 * (1 : ℝ) - Real.pi/4 * (-1) = Real.pi/2 by ring]
    constructor <;> simp
  · constructor <;> simp

-- PT-02: stored alignment between a bit center and a background site at angle
-- zero. It vanishes at the primary alphabet and is positive at the comparison
-- alphabet, where every center is therefore tied to the whole background.
private theorem stored_background_values (s : Bool) :
    Real.cos (Real.pi/2 * sign s - 0) = 0 ∧
    Real.cos (Real.pi/4 * sign s - 0) = Real.sqrt 2 / 2 := by
  cases s <;> simp [sign_true, sign_false, Real.cos_pi_div_four]

-- Stored alignment of a shoulder site at angle `α` with a bit center and with a
-- background site. Together with `omitted_center_field` and `shoulder_on_background`
-- these give the two coefficients of the time-zero formula: each presented bit
-- acts on an omitted center with weight `1 + 2 sin² α`, and moves the origin
-- with weight `2 sin α cos α`.
private theorem stored_shoulder_values (α : ℝ) (s t : Bool) :
    Real.cos (Real.pi/2 * sign s - α * sign t) = sign s * sign t * Real.sin α ∧
    Real.cos (0 - α * sign t) = Real.cos α := by
  cases s <;> cases t <;> simp only [sign_true, sign_false] <;> constructor
  · rw [show Real.pi/2 * (-1 : ℝ) - α * (-1) = α - Real.pi/2 by ring, Real.cos_sub_pi_div_two]
    ring
  · simp
  · rw [show Real.pi/2 * (-1 : ℝ) - α * 1 = -(α + Real.pi/2) by ring, Real.cos_neg,
      Real.cos_add_pi_div_two]
    ring
  · simp
  · rw [show Real.pi/2 * (1 : ℝ) - α * (-1) = α + Real.pi/2 by ring, Real.cos_add_pi_div_two]
    ring
  · simp
  · rw [show Real.pi/2 * (1 : ℝ) - α * 1 = Real.pi/2 - α by ring, Real.cos_pi_div_two_sub]
    ring
  · simp

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``primary_pair_torque, ``primary_presented_field, ``shoulder_on_presented,
      ``shoulder_ignores_neighbor, ``zero_site_on_presented, ``omitted_center_field,
      ``shoulder_on_background, ``comparison_pair_torque, ``stored_pair_values,
      ``stored_background_values, ``stored_shoulder_values] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end PresentedBitTorque
