module

import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# A constant-drive stage for trace and homeostat checks

The [numerical contract](../../docs/mathematics/numerical-methods.md) recovers exponential
stages, and the [memory contract](../../docs/mathematics/memory.md) recovers the homeostat
time constant of 50. The [experiment review](../../docs/research/recall-pilot-checks.md#internal-review-of-an-exponential-stage)
also considers a candidate pair trace driven by signed alignment within one episode.
The drive is held constant during each individual stage.
-/

namespace ExponentialStage
noncomputable section

private def stage (τ initial drive t : ℝ) : ℝ :=
  drive + (initial - drive) * Real.exp (-t/τ)

private theorem starts_at_initial (τ x q : ℝ) : stage τ x q 0 = x := by
  simp [stage]

private theorem stage_deriv (τ x q t : ℝ) :
    HasDerivAt (stage τ x q) ((q - stage τ x q t)/τ) t := by
  have h := (((hasDerivAt_id t).neg.div_const τ).exp.const_mul (x-q)).const_add q
  convert h using 1 <;> first | rfl | (dsimp [stage]; ring)

private theorem compose_same_drive (τ x q s t : ℝ) :
    stage τ (stage τ x q s) q t = stage τ x q (s+t) := by
  unfold stage
  rw [show -(s+t)/τ = -s/τ + -t/τ by ring, Real.exp_add]
  ring

private theorem stage_bounded {τ x q t lo hi : ℝ} (hτ : 0 < τ) (ht : 0 ≤ t)
    (hx : x ∈ Set.Icc lo hi) (hq : q ∈ Set.Icc lo hi) :
    stage τ x q t ∈ Set.Icc lo hi := by
  let r := Real.exp (-t/τ)
  have hr : 0 ≤ r := (Real.exp_pos _).le
  have hexp : -t/τ ≤ 0 := div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr ht) hτ.le
  have hc : 0 ≤ 1-r := sub_nonneg.mpr (Real.exp_le_one_iff.mpr hexp)
  change lo ≤ q+(x-q)*r ∧ q+(x-q)*r ≤ hi
  constructor
  · nlinarith [mul_le_mul_of_nonneg_right hx.1 hr, mul_le_mul_of_nonneg_right hq.1 hc]
  · nlinarith [mul_le_mul_of_nonneg_right hx.2 hr, mul_le_mul_of_nonneg_right hq.2 hc]

-- A nonnegative starting homeostat and nonnegative drive rule out a zero
-- denominator at all nonnegative times for this exact constant-drive stage.
private theorem gain_denominator {h q t : ℝ} (hh : 0 ≤ h) (hq : 0 ≤ q) (ht : 0 ≤ t) :
    1 ≤ 1 + stage 50 h q t := by
  have b := stage_bounded (τ := 50) (lo := 0) (hi := max h q) (by norm_num) ht
    ⟨hh, le_max_left h q⟩ ⟨hq, le_max_right h q⟩
  linarith [b.1]

-- Constant drives +1 then -1, or the reverse, have equal-time mean zero.
-- An exponential terminal read retains the order for every positive duration.
private theorem equal_duration_mean (t : ℝ) (ht : 0 < t) (c : ℝ) :
    (t*c + t*(-c))/(t+t) = 0 ∧ 0 < t+t := by
  constructor
  · rw [show t*c + t*(-c) = 0 by ring, zero_div]
  · linarith

private theorem opposite_halves {τ t : ℝ} (hτ : 0 < τ) (ht : 0 < t) :
    let r := Real.exp (-t/τ)
    stage τ (stage τ 0 1 t) (-1) t = -(1-r)^2 ∧
    stage τ (stage τ 0 (-1) t) 1 t = (1-r)^2 ∧ 0 < (1-r)^2 := by
  dsimp only
  have hr : Real.exp (-t/τ) < 1 := Real.exp_lt_one_iff.mpr (div_neg_of_neg_of_pos (by linarith) hτ)
  refine ⟨by unfold stage; ring, by unfold stage; ring, ?_⟩
  exact sq_pos_of_pos (sub_pos.mpr hr)

private theorem half_retention_example :
    stage 1 (stage 1 0 1 (Real.log 2)) (-1) (Real.log 2) = -1/4 ∧
    stage 1 (stage 1 0 (-1) (Real.log 2)) 1 (Real.log 2) = 1/4 := by
  norm_num [stage, Real.exp_neg, Real.exp_log (by norm_num : (0 : ℝ) < 2)]

-- The trial training durations are half and one homeostat time constant.
-- Compare unit constant drive from zero; the physical drive is still open.
private theorem duration_response :
    stage 50 0 1 25 = 1 - Real.exp (-(1/2)) ∧
    stage 50 0 1 50 = 1 - Real.exp (-1) ∧
    stage 50 0 1 25 < stage 50 0 1 50 := by
  have ordering : Real.exp (-1) < Real.exp (-(1/2)) := Real.exp_lt_exp.mpr (by norm_num)
  have at25 : stage 50 0 1 25 = 1 - Real.exp (-(1/2)) := by unfold stage; norm_num; ring
  have at50 : stage 50 0 1 50 = 1 - Real.exp (-1) := by unfold stage; norm_num; ring
  exact ⟨at25, at50, by rw [at25, at50]; linarith⟩

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``starts_at_initial, ``stage_deriv, ``compose_same_drive, ``stage_bounded,
      ``gain_denominator, ``equal_duration_mean, ``opposite_halves, ``half_retention_example, ``duration_response] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end ExponentialStage
