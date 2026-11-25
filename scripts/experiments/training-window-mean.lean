module

import Mathlib.Analysis.SpecialFunctions.Integrals.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Elapsed-time mean of pairwise alignment

[ADR-125](../../docs/decisions/ADR-125.md) gives equal weight to each unit of time
within a word's training window. The [internal review](../../docs/research/recall-pilot-checks.md#internal-review-of-the-selected-time-mean)
requires bounds for signed unit phases and correct composition at event boundaries.
These properties concern exact interval integrals of integrable signals.
-/

namespace TrainingWindowMean
noncomputable section

open MeasureTheory
open scoped ComplexConjugate

private def mean (f : ℝ → ℝ) {a b : ℝ} (_ : a < b) : ℝ :=
  (∫ t in a..b, f t) / (b-a)

private theorem constant_mean (v : ℝ) {a b : ℝ} (h : a < b) :
    mean (fun _ => v) h = v := by
  rw [mean, intervalIntegral.integral_const, smul_eq_mul,
    div_eq_iff (sub_ne_zero.mpr h.ne')]
  exact mul_comm _ _

-- If both phases have norm one, the real part of their relative phase lies
-- between -1 and 1. Integrating those bounds preserves them after normalization.
private theorem pair_mean_bounded {u v : ℝ → ℂ} {a b : ℝ} (h : a < b)
    (hu : ∀ t ∈ Set.Icc a b, ‖u t‖ = 1) (hv : ∀ t ∈ Set.Icc a b, ‖v t‖ = 1)
    (hi : IntervalIntegrable (fun t => (conj (u t) * v t).re) volume a b) :
    mean (fun t => (conj (u t) * v t).re) h ∈ Set.Icc (-1 : ℝ) 1 := by
  have hb (t : ℝ) (ht : t ∈ Set.Icc a b) :
      |(conj (u t) * v t).re| ≤ 1 := by
    simpa only [norm_mul, Complex.norm_conj, hu t ht, hv t ht, one_mul] using
      Complex.abs_re_le_norm (conj (u t) * v t)
  have hlo := intervalIntegral.integral_mono_on h.le (g := fun t => (conj (u t) * v t).re)
    (f := fun _ => (-1 : ℝ)) intervalIntegrable_const hi (fun t ht => (abs_le.mp (hb t ht)).1)
  have hhi := intervalIntegral.integral_mono_on h.le (f := fun t => (conj (u t) * v t).re)
    (g := fun _ => (1 : ℝ)) hi intervalIntegrable_const (fun t ht => (abs_le.mp (hb t ht)).2)
  simp only [intervalIntegral.integral_const, smul_eq_mul] at hlo hhi
  exact ⟨(le_div_iff₀ (sub_pos.mpr h)).mpr (by linarith),
    (div_le_iff₀ (sub_pos.mpr h)).mpr (by linarith)⟩

-- Adjacent subwindows can have different durations. This identity holds for
-- the exact means even when the signal varies within both parts.
private theorem split_mean (f : ℝ → ℝ) {a b c : ℝ} (hab : a < b) (hbc : b < c)
    (hl : IntervalIntegrable f volume a b) (hr : IntervalIntegrable f volume b c) :
    mean f (hab.trans hbc) =
      ((b-a) * mean f hab + (c-b) * mean f hbc) / (c-a) := by
  simp only [mean, mul_div_cancel₀ _ (sub_ne_zero.mpr hab.ne'),
    mul_div_cancel₀ _ (sub_ne_zero.mpr hbc.ne')]
  rw [intervalIntegral.integral_add_adjacent_intervals hl hr]

-- Three units of +1 and a final unit of -1 give +1/2 even though the two
-- subwindow means considered as two equally weighted records would cancel.
private theorem unequal_durations (f : ℝ → ℝ) (hl : IntervalIntegrable f volume 0 3)
    (hr : IntervalIntegrable f volume 3 4) (h₁ : mean f (by norm_num : (0 : ℝ) < 3) = 1)
    (h₂ : mean f (by norm_num : (3 : ℝ) < 4) = -1) :
    mean f (by norm_num : (0 : ℝ) < 4) = 1/2 := by
  rw [split_mean f (by norm_num : (0 : ℝ) < 3) (by norm_num : (3 : ℝ) < 4) hl hr, h₁, h₂]
  norm_num

-- The same varying signal on [-1,1] exposes the separate choice of start/end
-- events. Full, early-half and late-half means are evaluated by integration.
private theorem ramp_windows :
    mean id (by norm_num : (-1 : ℝ) < 1) = 0 ∧
    mean id (by norm_num : (-1 : ℝ) < 0) = -1/2 ∧
    mean id (by norm_num : (0 : ℝ) < 1) = 1/2 := by
  norm_num [mean, id, integral_id]

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``constant_mean, ``pair_mean_bounded, ``split_mean, ``unequal_durations,
      ``ramp_windows] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end TrainingWindowMean
