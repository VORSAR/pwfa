module

import PWFA.TorusOscillator
import Mathlib.Analysis.SpecialFunctions.Trigonometric.ArctanDeriv
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Exact two-site learned phase correction at the recall endpoint

The [internal review](../../docs/research/recall-pilot-checks.md#internal-review-of-the-learned-phase-lag)
isolates a learned sine interaction. [ADR-128](../../docs/decisions/ADR-128.md)
fixes each cell area to one half for two sites. The symmetric memory has diagonal
one and off-diagonal m. The common gain g and learned lag β remain symbolic.
-/

namespace LearnedPhaseLag
noncomputable section

open PWFA.TorusOscillator
open scoped ComplexConjugate

private def phase (a : ℝ) : ℂ := ⟨Real.cos a, Real.sin a⟩

private def torque (β a b : ℝ) : ℝ := (phase (-β) * conj (phase a) * phase b).im

private theorem torque_sine (β a b : ℝ) : torque β a b = Real.sin (b-a-β) := by
  simp [torque, phase, Complex.mul_im, Complex.mul_re, Real.sin_sub, Real.cos_sub]
  ring

-- Both the stored self-entry and the remote signed pair contribute.
private def speed (g m β a b : ℝ) := g * (torque β a a + m * torque β a b) / 2

private theorem speed_from_learned_mean (g m β a b : ℝ) :
    speed g m β a b = angularVelocity ⟨0,g,β⟩ (phase a)
      ((phase a + (m : ℂ) * phase b) / 2) := by
  simp [speed, torque, angularVelocity, phase, Complex.mul_im, Complex.mul_re,
    Complex.add_re, Complex.add_im, Complex.div_ofNat_re, Complex.div_ofNat_im]
  ring

-- Subtract the two velocities. Common self-rotation cancels. At positive g
-- and m the in-phase correction scales with cos β.
private theorem relative_speed (g m β a b : ℝ) :
    speed g m β b a - speed g m β a b = -(g*m*Real.cos β) * Real.sin (b-a) := by
  simp only [speed, torque_sine, sub_self, zero_sub]
  rw [show a-b = -(b-a) by ring]
  simp only [Real.sin_sub, Real.cos_neg, Real.sin_neg]
  ring

-- Start the two sites a quarter turn apart. With k=g cos β for m=1,
-- tan(δ/2) decays exactly as exp(-kt).
private def gap (k t : ℝ) := 2 * Real.arctan (Real.exp (-k*t))

private theorem sin_double_arctan (x : ℝ) :
    Real.sin (2 * Real.arctan x) = 2*x/(1+x^2) := by
  have hs := Real.tan_mul_cos (Real.cos_arctan_pos x).ne'
  rw [Real.tan_arctan] at hs
  rw [Real.sin_two_mul, ← hs]
  linear_combination (2*x) * Real.cos_sq_arctan x

private theorem quarter_turn (k : ℝ) : gap k 0 = Real.pi/2 := by
  simp [gap, Real.arctan_one]
  ring

private theorem gap_deriv (k t : ℝ) :
    HasDerivAt (gap k) (-k * Real.sin (gap k t)) t := by
  let e := Real.exp (-k*t)
  have he : HasDerivAt (fun s : ℝ => Real.exp (-k*s)) (e * (-k)) t := by
    simpa [e] using ((hasDerivAt_id t).const_mul (-k)).exp
  have hd := ((Real.hasDerivAt_arctan e).comp t he).const_mul 2
  convert hd using 1
  · rfl
  · rw [gap, sin_double_arctan]
    dsimp [e]
    ring

-- The endpoint formula applies at arbitrary gain. The comparison below uses
-- one common positive gain and varies only the learned phase lag.
private theorem half_angle_at_forty (g β : ℝ) :
    Real.tan (gap (g*Real.cos β) 40 / 2) = Real.exp (-40*g*Real.cos β) := by
  unfold gap
  rw [mul_div_cancel_left₀ _ (by norm_num : (2 : ℝ) ≠ 0), Real.tan_arctan]
  congr 1
  ring

private theorem same_lag_vs_zero (g : ℝ) (hg : 0 < g) :
    let α := Real.pi/2-1/10
    Real.tan (gap (g*Real.cos 0) 40 / 2) <
      Real.tan (gap (g*Real.cos α) 40 / 2) ∧
    Real.tan (gap (g*Real.cos α) 40 / 2) < 1 := by
  dsimp only
  rw [half_angle_at_forty, half_angle_at_forty, Real.cos_zero, Real.cos_pi_div_two_sub]
  have hp : 0 < Real.sin (1/10) := Real.sin_pos_of_pos_of_lt_pi (by norm_num)
    (by linarith [Real.two_le_pi])
  have hl : Real.sin (1/10) < 1 := lt_trans (Real.sin_lt (by norm_num : (0 : ℝ) < 1/10)) (by norm_num)
  constructor
  · apply Real.exp_lt_exp.mpr
    nlinarith [mul_pos hg (sub_pos.mpr hl)]
  · apply Real.exp_lt_one_iff.mpr
    nlinarith [mul_pos hg hp]

private theorem smaller_phase_gap (g : ℝ) (hg : 0 < g) :
    let α := Real.pi/2-1/10
    gap (g*Real.cos 0) 40 < gap (g*Real.cos α) 40 ∧ gap (g*Real.cos α) 40 < Real.pi/2 := by
  have h := same_lag_vs_zero g hg
  have recover (k : ℝ) : 2 * Real.arctan (Real.tan (gap k 40/2)) = gap k 40 := by
    simp [gap, Real.tan_arctan]
  constructor
  · simpa only [recover] using mul_lt_mul_of_pos_left (Real.arctan_strictMono h.1) (by norm_num : (0:ℝ)<2)
  · have late := mul_lt_mul_of_pos_left (Real.arctan_strictMono h.2) (by norm_num : (0:ℝ)<2)
    rw [recover, Real.arctan_one] at late
    linarith

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``torque_sine, ``speed_from_learned_mean, ``relative_speed, ``quarter_turn,
      ``gap_deriv, ``half_angle_at_forty, ``same_lag_vs_zero, ``smaller_phase_gap] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end LearnedPhaseLag
