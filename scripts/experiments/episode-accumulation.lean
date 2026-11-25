module

import Mathlib.Basic.Real.Basic
import Mathlib.Order.Interval.Set.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Which presentations contribute to pairwise memory?

The [training protocol](../../docs/decisions/ADR-096.md) presents four words sequentially
in the primary benchmark and repeats training in reverse order. This experiment compares
two ways to accumulate one signed alignment summary per pair and episode. See the
[review assumptions](../../docs/research/recall-pilot-checks.md#internal-review-of-episode-accumulation-and-recall-scoring-inputs).
-/

namespace EpisodeAccumulation
noncomputable section

-- After n equally weighted episodes, include the next one once.
private def runningMean (n : Nat) (old sample : ℝ) : ℝ :=
  ((n : ℝ)*old + sample) / ((n : ℝ)+1)

private theorem initial_mean (old sample : ℝ) : runningMean 0 old sample = sample := by
  simp [runningMean]

private theorem mean_bounded (n : Nat) {old sample : ℝ}
    (ho : old ∈ Set.Icc (-1 : ℝ) 1) (hs : sample ∈ Set.Icc (-1 : ℝ) 1) :
    runningMean n old sample ∈ Set.Icc (-1 : ℝ) 1 := by
  have hn : 0 ≤ (n : ℝ) := Nat.cast_nonneg n
  have hd : 0 < (n : ℝ) + 1 := by linarith
  exact ⟨(le_div_iff₀ hd).mpr (by nlinarith [mul_le_mul_of_nonneg_left ho.1 hn, hs.1]),
    (div_le_iff₀ hd).mpr (by nlinarith [mul_le_mul_of_nonneg_left ho.2 hn, hs.2])⟩

private def meanFour (a b c d : ℝ) : ℝ :=
  runningMean 3 (runningMean 2 (runningMean 1 (runningMean 0 0 a) b) c) d

private theorem four_equal_weights (a b c d : ℝ) : meanFour a b c d = (a+b+c+d)/4 := by
  unfold meanFour runningMean
  push_cast
  ring

-- Retention is the fraction of the old pair state kept after the current episode.
private def retain (r old sample : ℝ) : ℝ := r*old + (1-r)*sample

private theorem retention_bounded {r old sample : ℝ} (hr : r ∈ Set.Icc (0 : ℝ) 1)
    (ho : old ∈ Set.Icc (-1 : ℝ) 1) (hs : sample ∈ Set.Icc (-1 : ℝ) 1) :
    retain r old sample ∈ Set.Icc (-1 : ℝ) 1 := by
  have h : 0 ≤ 1-r := sub_nonneg.mpr hr.2
  unfold retain
  constructor
  · nlinarith [mul_le_mul_of_nonneg_left ho.1 hr.1, mul_le_mul_of_nonneg_left hs.1 h]
  · nlinarith [mul_le_mul_of_nonneg_left ho.2 hr.1, mul_le_mul_of_nonneg_left hs.2 h]

private def retainedFour (r a b c d : ℝ) : ℝ :=
  retain r (retain r (retain r (retain r 0 a) b) c) d

private theorem fixed_inputs_reversed (a b c d : ℝ) :
    meanFour a b c d = meanFour d c b a := by
  rw [four_equal_weights, four_equal_weights]
  ring

private theorem conflicting_episodes :
    meanFour 1 1 (-1) (-1) = 0 ∧ meanFour (-1) (-1) 1 1 = 0 ∧
    retainedFour (1/2) 1 1 (-1) (-1) = -9/16 ∧
    retainedFour (1/2) (-1) (-1) 1 1 = 9/16 := by
  norm_num [four_equal_weights, retainedFour, retain]

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``initial_mean, ``mean_bounded, ``four_equal_weights, ``retention_bounded,
      ``fixed_inputs_reversed, ``conflicting_episodes] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end EpisodeAccumulation
