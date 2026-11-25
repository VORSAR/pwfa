module

import Std

/-!
# Exact-word scoring for a candidate recall protocol

The [benchmark](../../docs/experiments/benchmarks.md#first-trained-recall-measurement)
compares a prediction at t=40 with the original target, including corrupted positions.
The [review](../../docs/research/recall-pilot-checks.md) scopes these finite examples.
All outputs below are synthetic. A simulator supplies the decoded bits separately.
-/

namespace RecallScoring

private abbrev Word := Fin 16 → Bool
private abbrev Decoded := Fin 16 → Option Bool

private inductive Result where
  | exact | wrong | abstained | failed
  deriving DecidableEq, BEq

-- An absent run and an unresolved bit are distinct reporting categories. A word
-- with both a tie and a wrong bit is classified as abstained in this trial policy.
private def outcome (allCorrect missing : Bool) : Result :=
  if allCorrect then .exact else if missing then .abstained else .wrong

private theorem outcome_exact (allCorrect missing : Bool) :
    outcome allCorrect missing = .exact ↔ allCorrect = true := by
  cases allCorrect <;> cases missing <;> decide

private def classify (target : Word) (prediction : Option Decoded) : Result :=
  match prediction with
  | none => .failed
  | some bits =>
    outcome (decide (∀ i, bits i = some (target i))) (decide (∃ i, bits i = none))

private theorem exact_iff (target : Word) (bits : Decoded) :
    classify target (some bits) = .exact ↔ ∀ i, bits i = some (target i) := by
  exact (outcome_exact _ _).trans (decide_eq_true_iff)

private inductive InputStatus where
  | clean | flipped | masked
  deriving DecidableEq, BEq

-- The corruption labels are available to the evaluator for diagnostics.
-- The presented cue contains no hidden bit value at a masked site.
private def cue (target : Word) (status : Fin 16 → InputStatus) : Decoded := fun i =>
  match status i with
  | .clean => some (target i)
  | .flipped => some (!(target i))
  | .masked => none

private def subsetCounts (target : Word) (bits : Decoded)
    (status : Fin 16 → InputStatus) (kind : InputStatus) : Nat × Nat :=
  let indices := (List.finRange 16).filter fun i => status i == kind
  (indices.countP (fun i => bits i == some (target i)), indices.length)

private def statuses (i : Fin 16) : InputStatus :=
  if i = 0 then .flipped else if i = 1 then .masked else .clean

private def target : Word := fun i => decide (i.val % 2 = 0)

-- A direct copy gets every uncorrupted bit right but corrects neither damaged bit.
example :
    let copy := cue target statuses
    classify target (some copy) = .abstained ∧
    subsetCounts target copy statuses .clean = (14, 14) ∧
    subsetCounts target copy statuses .flipped = (0, 1) ∧
    subsetCounts target copy statuses .masked = (0, 1) := by decide +kernel

-- Filling the missing bit while preserving the flipped input still misses the word.
-- Guessing the masked bit incorrectly after fixing the flip also misses the word.
example :
    classify target (some (fun i => some (if i = 0 then !(target i) else target i))) = .wrong ∧
    classify target (some (fun i => some (if i = 1 then !(target i) else target i))) = .wrong ∧
    classify target (some (fun i => some (target i))) = .exact ∧
    classify target none = .failed := by decide +kernel

-- Keep counts, including (0,0) for an empty denominator. Reporting a percentage
-- then requires a nonempty denominator. Both policies see the same trial list.
private def allCues (trials : List Result) : Nat × Nat := (trials.count .exact, trials.length)
private def completeOnly (trials : List Result) : Nat × Nat :=
  (trials.count .exact, trials.count .exact + trials.count .wrong)

example :
    let trials : List Result := [.exact, .wrong, .abstained, .failed]
    allCues trials = (1, 4) ∧ completeOnly trials = (1, 2) ∧
    allCues [] = (0, 0) ∧ completeOnly [.abstained, .failed] = (0, 0) := by decide +kernel

end RecallScoring
