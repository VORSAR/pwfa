module

import Mathlib.Analysis.Complex.Norm
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Four-word training and dense learned retrieval on exact phase histories

[ADR-123](../../docs/decisions/ADR-123.md) uses signed alignment. The
[full window](../../docs/decisions/ADR-126.md) includes every training segment.
[ADR-124](../../docs/decisions/ADR-124.md) gives four completed words equal weight.
[ADR-128](../../docs/decisions/ADR-128.md) then applies one cell area per source.
The [internal review](../../docs/research/recall-pilot-checks.md#internal-review-of-four-word-memory-construction)
limits the reference calculation to piecewise-constant rational unit phases.
-/

namespace FourWordMemory

open scoped ComplexConjugate

private abbrev Coord := ℚ × ℚ
private abbrev Snapshot (n : Nat) := Fin n → Coord
private abbrev Memory (n : Nat) := Fin n → Fin n → ℚ

private def alignment (u v : Coord) : ℚ := u.1*v.1 + u.2*v.2

-- The executable rational dot product is exactly the specified complex statistic.
private theorem alignment_complex (u v : Coord) :
    (alignment u v : ℝ) = (conj (⟨u.1,u.2⟩ : ℂ) * (⟨v.1,v.2⟩ : ℂ)).re := by
  simp [alignment, Complex.mul_re]

private structure Segment (n : Nat) where
  duration : ℚ
  phases : Snapshot n

private abbrev Episode (n : Nat) := List (Segment n)
private abbrev Library (n : Nat) := Fin 4 → Episode n

private def elapsed (e : Episode n) : ℚ := (e.map Segment.duration).sum

private def valid (duration : ℚ) (e : Episode n) : Prop :=
  0 < duration ∧ elapsed e = duration ∧
  ∀ s ∈ e, 0 < s.duration ∧ ∀ j, alignment (s.phases j) (s.phases j) = 1

private instance (duration : ℚ) (e : Episode n) : Decidable (valid duration e) := by
  unfold valid
  infer_instance

-- These are exact integrals for phases held constant throughout each segment.
private def episodeMean (e : Episode n) (i j : Fin n) : ℚ :=
  (e.map fun s => s.duration * alignment (s.phases i) (s.phases j)).sum / elapsed e

private def fourMean (words : Library n) (i j : Fin n) : ℚ :=
  ((List.finRange 4).map fun k => episodeMean (words k) i j).sum / 4

private def train (duration : ℚ) (words : Library n) : Option (Memory n) :=
  if 0 < n ∧ ∀ k, valid duration (words k) then some (fourMean words) else none

private theorem symmetric (words : Library n) (i j : Fin n) :
    fourMean words i j = fourMean words j i := by
  have sym (a b : Coord) : alignment a b = alignment b a := by unfold alignment; ring
  unfold fourMean episodeMean
  simp_rw [show ∀ s : Segment n, alignment (s.phases i) (s.phases j) =
    alignment (s.phases j) (s.phases i) from fun s => sym _ _]

private theorem episode_diagonal {duration : ℚ} {e : Episode n} (h : valid duration e)
    (i : Fin n) : episodeMean e i i = 1 := by
  obtain ⟨hd, length_eq, units⟩ := h
  have same : (e.map fun s => s.duration * alignment (s.phases i) (s.phases i)) =
      e.map Segment.duration := List.map_congr_left fun s hs => by rw [(units s hs).2 i, mul_one]
  unfold episodeMean
  rw [same, ← elapsed, length_eq, div_self hd.ne']

private theorem trained_invariants {duration : ℚ} {words : Library n} {m : Memory n}
    (ok : train duration words = some m) (i j : Fin n) : m i j = m j i ∧ m i i = 1 := by
  unfold train at ok
  split at ok
  · rename_i validWords
    cases ok
    refine ⟨symmetric words i j, ?_⟩
    norm_num [fourMean, fun k => episode_diagonal (validWords.2 k) i]
  · contradiction

-- Sum signed associations against both coordinates of the current phase.
-- One factor 1/N accounts for equal cell area in the learned retrieval field.
private def field (m : Memory n) (z : Snapshot n) (i : Fin n) : Coord :=
  (((List.finRange n).map fun j => m i j * (z j).1).sum / n,
   ((List.finRange n).map fun j => m i j * (z j).2).sum / n)

private def twoSites (a b : Coord) : Snapshot 2 := fun j => if j = 0 then a else b

private def history (duration : ℚ) : Library 2 := fun word =>
  let agree := twoSites (0,1) (0,1)
  let oppose := twoSites (0,1) (0,-1)
  let rightAngle := twoSites (1,0) (0,1)
  match word.val with
  | 0 => [⟨3*duration/4, agree⟩, ⟨duration/4, oppose⟩]
  | 1 => [⟨duration, oppose⟩]
  | 2 => [⟨duration, agree⟩]
  | _ => [⟨duration, rightAngle⟩]

private def probe := twoSites (1,0) (0,1)

private def result (duration : ℚ) := (train duration (history duration)).map fun m =>
  ((m 0 0, m 0 1, m 1 0, m 1 1), field m probe 0, field m probe 1)

-- The 50-unit control stretches every segment twofold. It has the same exact
-- normalized history; an evolving oscillator is free to give different results.
example : result 25 = some ((1,1/8,1/8,1), (1/2,1/16), (1/16,1/2)) ∧
    result 50 = result 25 := by decide +kernel

-- All four words put these two training sites in opposition. Their first stored
-- row sums to zero, but its response to the same complex probe is nonzero.
example : ((train 25 fun _ => [⟨25, twoSites (0,1) (0,-1)⟩]).map fun m =>
    (m 0 0 + m 0 1, field m probe 0)) = some (0, (1/2,-1/2)) := by decide +kernel

example : (train 50 (history 25)).isNone ∧ (train 0 (history 0)).isNone ∧
    (train 25 (fun _ => [] : Library 2)).isNone ∧
    (train 25 (fun _ => [⟨-1, probe⟩, ⟨26, probe⟩])).isNone ∧
    (train 25 (fun _ => [⟨0, probe⟩, ⟨25, probe⟩])).isNone ∧
    (train 25 (fun _ => [⟨25, Fin.elim0⟩] : Library 0)).isNone ∧
    (train 25 (fun _ => [⟨25, twoSites (2,0) (0,1)⟩])).isNone := by decide +kernel

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``alignment_complex, ``symmetric, ``episode_diagonal, ``trained_invariants] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end FourWordMemory

/-- Run the two-site exact-history reference at both selected training durations. -/
public def main : IO Unit := do
  for duration in ([25, 50] : List ℚ) do
    let some ((a,b,c,d), u, v) := FourWordMemory.result duration
      | throw (IO.userError "invalid reference history")
    IO.println s!"{duration} units per word: M=[[{a},{b}],[{c},{d}]], field=[{u},{v}]"
