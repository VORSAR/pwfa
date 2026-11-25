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

-- Score one condition and library at a time. The separate schedule fixes the
-- ADR-122 denominator before any model output is read. IDs join the two files.
private structure Scheduled where
  target : Word
  status : Fin 16 → InputStatus

private def parse16 {α : Type} (s : String) (parse : Char → Option α) :
    Except String (Fin 16 → α) := do
  let some values := s.toList.mapM parse | throw s!"invalid symbol in '{s}'"
  let arr := values.toArray
  if h : arr.size = 16 then
    return fun i => arr[i.val]'(by simpa only [h] using i.isLt)
  else
    throw s!"expected 16 positions, found {arr.size}"

private def parseBit : Char → Option Bool
  | '0' => some false
  | '1' => some true
  | _ => none

private def parseSchedule : List String → Except String Scheduled
  | [word, labels] => do
    let target ← parse16 word parseBit
    let status ← parse16 labels fun
      | '.' => some .clean
      | 'F' => some .flipped
      | 'M' => some .masked
      | _ => none
    return ⟨target, status⟩
  | _ => throw "expected cue ID, target word, and corruption labels"

private def parsePrediction : List String → Except String (Option Decoded)
  | ["40", "FAILED"] => return none
  | ["40", word] => do
    let bits ← parse16 word fun c =>
      if c == '?' then some none else (parseBit c).map some
    return some bits
  | [time, _] => throw s!"expected endpoint 40, found '{time}'"
  | _ => throw "expected cue ID, endpoint 40, and decoded word or FAILED"

private def readRows {α : Type} (input : String) (parse : List String → Except String α) :
    Except String (Std.HashMap String α) := do
  let mut rows := ∅
  for (line, n) in (input.splitOn "\n").zipIdx do
    let line := (line.dropSuffix "\r").toString
    if line.isEmpty then continue
    let id :: fields := line.splitOn "\t" | throw s!"line {n+1}: expected cue ID"
    if id.isEmpty || id.trimAscii.toString != id then throw s!"line {n+1}: invalid cue ID"
    if rows.contains id then throw s!"line {n+1}: duplicate cue ID '{id}'"
    match parse fields with
    | .error e => throw s!"line {n+1}, cue '{id}': {e}"
    | .ok value => rows := rows.insert id value
  return rows

private structure Report where
  exact : Nat := 0
  wrong : Nat := 0
  abstained : Nat := 0
  failed : Nat := 0
  missing : Nat := 0
  maskedCorrect : Nat := 0
  maskedTotal : Nat := 0
  flippedCorrect : Nat := 0
  flippedTotal : Nat := 0
  deriving BEq

private abbrev Schedule := Std.HashMap String Scheduled
private abbrev Predictions := Std.HashMap String (Option Decoded)

private def validatedPredictions (planned : Schedule) (predictions : String) :
    Except String Predictions := do
  let returned ← (readRows predictions parsePrediction).mapError ("predictions: " ++ ·)
  for (id, _) in returned.toList do
    unless planned.contains id do throw s!"unscheduled cue '{id}'"
  return returned

private def reportFor (planned : Schedule) (returned : Predictions) : Report := Id.run do
  let mut report : Report := {}
  for (id, item) in planned.toList do
    let row := returned.get? id
    let bits := row.join
    let scored := bits.getD (fun _ => none)
    let (mc, mt) := subsetCounts item.target scored item.status .masked
    let (fc, ft) := subsetCounts item.target scored item.status .flipped
    report := { report with
      maskedCorrect := report.maskedCorrect + mc, maskedTotal := report.maskedTotal + mt
      flippedCorrect := report.flippedCorrect + fc, flippedTotal := report.flippedTotal + ft }
    match classify item.target bits with
    | .exact => report := { report with exact := report.exact + 1 }
    | .wrong => report := { report with wrong := report.wrong + 1 }
    | .abstained => report := { report with abstained := report.abstained + 1 }
    | .failed =>
      if row.isNone then report := { report with missing := report.missing + 1 }
      else report := { report with failed := report.failed + 1 }
  return report

private def evaluate (schedule predictions : String) : Except String Report := do
  let planned ← (readRows schedule parseSchedule).mapError ("schedule: " ++ ·)
  return reportFor planned (← validatedPredictions planned predictions)

private def fraction (n d : Nat) : String :=
  if d = 0 then s!"undefined ({n}/{d})" else s!"{n}/{d}"

private def formatReport (r : Report) : String :=
  let answered := r.exact + r.wrong
  let total := answered + r.abstained + r.failed + r.missing
  String.intercalate "\n" [
    s!"Exact words / scheduled cues: {fraction r.exact total}",
    s!"Coverage: {fraction answered total}",
    s!"Exact words / fully answered cues: {fraction r.exact answered}",
    s!"Masked bits correct / scheduled masked bits: {fraction r.maskedCorrect r.maskedTotal}",
    s!"Flipped bits corrected / scheduled flipped bits: {fraction r.flippedCorrect r.flippedTotal}",
    s!"Exact {r.exact}, wrong {r.wrong}, abstained {r.abstained}, failed {r.failed}, missing {r.missing}"]

-- ADR-127 uses the same scheduled cues in two independently trained conditions.
-- Keep the IDs of the discordant pairs so equal aggregate rates remain interpretable.
private structure PairedReport where
  at25 : Report
  at50 : Report
  both : Nat := 0
  neither : Nat := 0
  only25 : Array String := #[]
  only50 : Array String := #[]

private def paired (schedule predictions25 predictions50 : String) : Except String PairedReport := do
  let planned ← (readRows schedule parseSchedule).mapError ("schedule: " ++ ·)
  let p25 ← (validatedPredictions planned predictions25).mapError ("25-unit " ++ ·)
  let p50 ← (validatedPredictions planned predictions50).mapError ("50-unit " ++ ·)
  let mut result := { at25 := reportFor planned p25, at50 := reportFor planned p50 : PairedReport }
  for (id, item) in planned.toList do
    let hit (p : Predictions) := classify item.target (p.get? id).join == .exact
    match hit p25, hit p50 with
    | true, true => result := { result with both := result.both + 1 }
    | false, false => result := { result with neither := result.neither + 1 }
    | true, false => result := { result with only25 := result.only25.push id }
    | false, true => result := { result with only50 := result.only50.push id }
  return { result with only25 := result.only25.qsort, only50 := result.only50.qsort }

private def pairedDifference (r : PairedReport) : String :=
  let n := r.both + r.only25.size + r.only50.size + r.neither
  let delta := (r.only50.size : Int) - (r.only25.size : Int)
  if n = 0 then "undefined (0/0)" else s!"{delta}/{n}"

-- The common successes cancel for any four-cell paired comparison.
private theorem discordant_difference (both only25 only50 : Nat) :
    ((both + only50 : Nat) : Int) - ((both + only25 : Nat) : Int) =
      (only50 : Int) - (only25 : Int) := by omega

private def formatPair (r : PairedReport) : String :=
  String.intercalate "\n" [
    "25-unit training", formatReport r.at25, "", "50-unit training", formatReport r.at50, "",
    s!"Exact in both {r.both}, only at 25 {r.only25.size}, only at 50 {r.only50.size}, neither {r.neither}",
    s!"Exact recall difference (50 minus 25, all scheduled cues): {pairedDifference r}",
    "Only at 25 (cue IDs): " ++ String.intercalate ", " r.only25.toList,
    "Only at 50 (cue IDs): " ++ String.intercalate ", " r.only50.toList]

-- The pure file boundary is tested when the research CI compiles this module.
private def fixtureSchedule := String.intercalate "\n" <|
  ["a", "b", "c", "d", "e"].map (· ++ "\t0000000000000000\tFM..............")
private def fixtureResults := "c\t40\t0?00000000000000\na\t40\t0000000000000000\nd\t40\tFAILED\nb\t40\t1000000000000000"

#guard (evaluate fixtureSchedule fixtureResults).toOption == some {
  exact := 1, wrong := 1, abstained := 1, failed := 1, missing := 1,
  maskedCorrect := 2, maskedTotal := 5, flippedCorrect := 2, flippedTotal := 5 }
#guard (evaluate "" "").toOption == some {}
#guard (evaluate fixtureSchedule (fixtureResults ++ "\na\t40\tFAILED")).isOk == false
#guard (evaluate (fixtureSchedule ++ "\n" ++ fixtureSchedule) "").isOk == false
#guard (evaluate fixtureSchedule "unknown\t40\tFAILED").isOk == false
#guard (evaluate fixtureSchedule "a\t39\t0000000000000000").isOk == false
#guard (evaluate fixtureSchedule "a\t40\t0x00000000000000").isOk == false
#guard (evaluate fixtureSchedule "a\t40\t0").isOk == false
#guard (evaluate "a\t?000000000000000\tFM.............." "").isOk == false
#guard fraction 0 0 == "undefined (0/0)"

-- Same marginal accuracy on these five cues hides two discordant outcomes.
private def pairedFixture := "b\t40\t0000000000000000\nd\t40\tFAILED"
#guard ((paired fixtureSchedule fixtureResults pairedFixture).toOption.map fun p =>
    (p.at25.exact, p.at50.exact, p.both, p.neither, p.only25, p.only50, pairedDifference p)) ==
    some (1, 1, 0, 3, #["a"], #["b"], "0/5")
#guard ((paired fixtureSchedule fixtureResults "").toOption.map pairedDifference) == some "-1/5"
#guard ((paired fixtureSchedule "" fixtureResults).toOption.map pairedDifference) == some "1/5"
#guard ((paired fixtureSchedule fixtureResults fixtureResults).toOption.map fun p =>
    (p.both, p.neither, p.only25.size, p.only50.size)) == some (1, 4, 0, 0)
#guard ((paired "" "" "").toOption.map pairedDifference) == some "undefined (0/0)"
#guard ((paired fixtureSchedule "" "e\t40\t0000000000000000\nc\t40\t0000000000000000").toOption.map
    (·.only50)) == some #["c", "e"]
#guard (paired fixtureSchedule "" "unknown\t40\tFAILED").isOk == false
#guard (paired fixtureSchedule "a\t39\tFAILED" "").isOk == false

end RecallScoring

/-- Score an exported condition at t=40 using the frozen cue roster. -/
public def main (args : List String) : IO UInt32 := do
  let result ← match args with
  | ["--compare-durations", schedule, p25, p50] => do
    let result := RecallScoring.paired (← IO.FS.readFile schedule) (← IO.FS.readFile p25)
      (← IO.FS.readFile p50)
    pure (result.map RecallScoring.formatPair)
  | [schedule, predictions] => do
    let result := RecallScoring.evaluate (← IO.FS.readFile schedule) (← IO.FS.readFile predictions)
    pure (result.map RecallScoring.formatReport)
  | _ => do
    IO.eprintln "Usage: lean --run scripts/experiments/recall-scoring.lean SCHEDULE.tsv PREDICTIONS.tsv"
    IO.eprintln "   or: lean --run scripts/experiments/recall-scoring.lean --compare-durations SCHEDULE.tsv PRED25.tsv PRED50.tsv"
    return 2
  match result with
  | .error e => IO.eprintln e; return 1
  | .ok report => IO.println report; return 0
