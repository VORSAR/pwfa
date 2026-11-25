module

import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Candidate instantaneous input to a pairwise training trace

The [recall pilot review](../../docs/research/recall-pilot-checks.md) compares two
statistics of the relative phase. The [memory contract](../../docs/mathematics/memory.md)
distinguishes the pairwise memory from the historical global scalar gain.
These statements concern one sample of a pair, before any learning or time evolution.
-/

namespace PairwisePhaseStatistic
noncomputable section

open scoped ComplexConjugate

private def phase (a : ℝ) : ℂ := ⟨Real.cos a, Real.sin a⟩
private def alignment (a b : ℂ) : ℝ := (conj a * b).re

-- Real alignment is the cosine of the difference of the two measured angles.
private theorem at_angles (a b : ℝ) :
    alignment (phase a) (phase b) = Real.cos (a-b) := by
  simp [alignment, phase, Complex.mul_re, Real.cos_sub]

private theorem symmetric (a b : ℂ) : alignment a b = alignment b a := by
  simp [alignment, Complex.mul_re]
  ring

-- A common unit rotation can be written as an angle added to both phases.
private theorem shared_rotation (a b r : ℝ) :
    alignment (phase (r+a)) (phase (r+b)) = alignment (phase a) (phase b) := by
  simp only [at_angles]
  congr 1
  ring

private theorem like_symbols (a : ℝ) : alignment (phase a) (phase a) = 1 := by
  simp [at_angles]

private theorem unlike_symbols :
    alignment (phase (Real.pi/2)) (phase (-(Real.pi/2))) = -1 ∧
    alignment (phase (Real.pi/4)) (phase (-(Real.pi/4))) = 0 := by
  simp only [at_angles]
  rw [show Real.pi/2 - -(Real.pi/2) = Real.pi by ring,
    show Real.pi/4 - -(Real.pi/4) = Real.pi / 2 by ring]
  simp

-- For the primary alphabet, squaring collapses the two relations to one value.
private theorem squared_collision :
    alignment (phase (Real.pi/2)) (phase (Real.pi/2)) ^ 2 =
      alignment (phase (Real.pi/2)) (phase (-(Real.pi/2))) ^ 2 := by
  rw [like_symbols, unlike_symbols.1]
  norm_num

-- Reversing every signed angle preserves every real pair statistic. This covers
-- both alphabets, and a uniform zero-angle background including the origin.
private theorem reversed_angles (a b : ℝ) :
    alignment (phase (-a)) (phase (-b)) = alignment (phase a) (phase b) := by
  rw [at_angles, at_angles, show -a - -b = -(a-b) by ring, Real.cos_neg]

private theorem word_complement {ι : Type} (bits : ι → Bool) (θ : ℝ) (i j : ι) :
    let angle := fun (v : Bool) => if v then θ else -θ
    alignment (phase (angle (!(bits i)))) (phase (angle (!(bits j)))) =
      alignment (phase (angle (bits i))) (phase (angle (bits j))) := by
  dsimp only
  have flip (v : Bool) : (if !v then θ else -θ) = -(if v then θ else -θ) := by
    cases v <;> simp
  simp only [flip, reversed_angles]

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``at_angles, ``symmetric, ``shared_rotation, ``like_symbols,
      ``unlike_symbols, ``squared_collision, ``reversed_angles, ``word_complement] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end PairwisePhaseStatistic
