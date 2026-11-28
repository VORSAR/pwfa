import Std

/-!
# Static references for recall from a pairwise memory

The [research note](../../docs/research/learned-retrieval-at-time-zero.md) scopes
these calculations. They read a four-word library and never run the phase solver.
The pair matrix is the signed agreement between bit positions under the
[episode weights](../../docs/decisions/ADR-124.md). The
[Lean identities](presented-bit-torque.lean) show that this is the learned memory
between bit centers at the primary alphabet. The [primary endpoint](../../docs/decisions/ADR-122.md)
counts whole words. Angles are in radians.
-/

namespace PairMemoryReference

private def bits := 16

-- A presented 1 is +1, a presented 0 is -1 and an omitted position is 0.
private def spins (s : String) : Array Int :=
  s.toList.toArray.map fun c => if c == '1' then 1 else if c == '0' then -1 else 0

private def render (x : Array Int) : String :=
  String.ofList (x.toList.map fun v => if v > 0 then '1' else if v < 0 then '0' else '?')

private def opposite (w : String) : String := w.map fun c => if c == '0' then '1' else '0'

-- Episode weights as integer numerators. Equal weights follow ADR-124. The
-- rebalanced arm gives each member of a complementary pair one share and
-- every other word two, as in the complement-balanced comparison.
private def weights (words : List String) (balanced : Bool) : List Int :=
  words.map fun w => if balanced && !words.contains (opposite w) then 2 else 1

-- Signed agreement between two positions, summed over the words with their
-- weights. Dividing by the weight total gives the stored pair value.
private def pairMatrix (words : List String) (ws : List Int) : Array Int := Id.run do
  let mut m := Array.replicate (bits*bits) (0 : Int)
  for (w, c) in words.zip ws do
    let s := spins w
    for i in [:bits] do
      for j in [:bits] do
        m := m.set! (i*bits+j) (m[i*bits+j]! + c * s[i]! * s[j]!)
  return m

-- The memory row of position j applied to every other position of the cue.
private def localField (m x : Array Int) (j : Nat) : Int := Id.run do
  let mut h := 0
  for a in [:bits] do
    if a != j then h := h + m[j*bits+a]! * x[a]!
  return h

-- Classical Hopfield recall: asynchronous sign updates in index order until a
-- full sweep changes nothing. A zero field leaves the position as it is, so
-- an omitted position with no evidence stays unresolved.
private def hopfield (m : Array Int) (cue : String) : String := Id.run do
  let mut x := spins cue
  for _ in [:50] do
    let mut changed := false
    for j in [:bits] do
      let h := localField m x j
      let s := if h > 0 then 1 else if h < 0 then -1 else x[j]!
      if s != x[j]! then
        x := x.set! j s
        changed := true
    if !changed then break
  return render x

-- Nearest stored word on the visible positions. A tie is unresolved.
private def visibleDistance (cue word : String) : Nat :=
  (cue.toList.zip word.toList).countP fun (c, b) => c != '?' && c != b

private def nearest (words : List String) (cue : String) : String := Id.run do
  let distances := words.map fun w => (w, visibleDistance cue w)
  let some best := (distances.map Prod.snd).min? | return render (Array.replicate bits 0)
  match distances.filter (·.2 == best) with
  | [(w, _)] => return w
  | _ => return render (Array.replicate bits 0)

private def pi := 3.14159265358979323846
-- Prepared angle of the two grid sites beside a presented center.
private def shoulder := pi / 2 * Float.exp (-1.0 / 3.0)
private def centerGain := 1 + 2 * Float.sin shoulder * Float.sin shoulder
private def anchorDrift := Float.sin (2 * shoulder)

-- Angular velocity at time zero of a center whose stimulus is omitted, taken
-- relative to the origin, in units of learned gain divided by the site count.
-- The first term is the pair memory applied to the visible symbols. The second
-- is the origin moving with the surplus of ones over zeros in the cue.
private def hiddenField (m : Array Int) (total : Int) (x : Array Int) (j : Nat)
    (drift : Bool) : Float := Id.run do
  let mut surplus : Int := 0
  for a in [:bits] do
    if a != j then surplus := surplus + x[a]!
  let field := centerGain * Float.ofInt (localField m x j) / Float.ofInt total
  return if drift then field - anchorDrift * Float.ofInt surplus else field

-- One symbol per position, each from the cue with that position hidden.
private def hiddenBits (m : Array Int) (total : Int) (drift : Bool) (cue : String) : String :=
  let x := spins cue
  String.ofList ((List.range bits).map fun j =>
    let f := hiddenField m total x j drift
    if f > 1e-9 then '1' else if f < -1e-9 then '0' else '?')

private def corrupt (w : String) (m1 m2 f1 f2 : Nat) : String :=
  String.ofList (w.toList.zipIdx.map fun (c, i) =>
    if i == m1 || i == m2 then '?'
    else if i == f1 || i == f2 then (if c == '1' then '0' else '1') else c)

private def total (ws : List Int) : Int := ws.foldl (· + ·) 0

#guard render (spins "10?0") == "10?0"
#guard weights ["000", "111", "010", "011"] true == [1, 1, 2, 2]
#guard weights ["000", "111", "010", "011"] false == [1, 1, 1, 1]
#guard corrupt "0000000000000000" 0 1 2 3 == "??11000000000000"
#guard nearest ["0000", "1111"] "?010" == "0000"
#guard nearest ["0000", "1111"] "?01?" == "????????????????"

private def check (p : Bool) (msg : String) : IO Unit :=
  unless p do throw (IO.userError msg)

-- A library that stores one word and its complement must return that word
-- from two flips and two omissions under every memory-based decoder.
private def controls : IO Unit := do
  let word := "0011010011110001"
  let library := [word, opposite word]
  let m := pairMatrix library (weights library false)
  let cue := corrupt word 0 5 9 14
  check (m[0]! == 2 && m[1]! == 2 && m[2]! == -2 && m[2*bits]! == -2) "pair matrix entries"
  check (hopfield m cue == word) "Hopfield recall of a single stored pair"
  check (hiddenBits m 2 true cue == word && hiddenBits m 2 false cue == word)
    "time-zero hidden-bit prediction for a single stored pair"
  check (nearest library cue == word) "nearest visible word"
  check (hopfield m "????????????????" == "????????????????") "no evidence stays unresolved"
  check (Float.abs (centerGain - 2.62899) < 1e-4 && Float.abs (anchorDrift - 0.77741) < 1e-4)
    "shoulder constants"
  let mixed := ["0011010011110001", "1100101100001110", "0001101010100001", "0101000001110001"]
  check (weights mixed true == [1, 1, 2, 2] && total (weights mixed true) == 6) "rebalanced weights"
  IO.println "Static reference controls passed"

private def readLines (path : String) : IO (List String) := do
  return ((← IO.FS.readFile path).splitOn "\n").map (·.dropSuffix "\r" |>.toString)
    |>.filter (!·.isEmpty)

private def readWords (path : String) : IO (List String) := do
  let words ← readLines path
  check (words.length == 4 && words.eraseDups.length == 4 &&
    words.all fun w => w.length == bits && w.toList.all fun c => c == '0' || c == '1')
    "expected four distinct 16-bit words"
  return words

private def percent (hits cases : Nat) : String :=
  let n := (hits * 10000 + cases / 2) / cases
  let frac := n % 100
  s!"{n / 100}.{if frac < 10 then "0" else ""}{frac}%"

-- Every target, unordered pair of omissions and unordered pair of flips
-- outside the omissions, each counted once.
private def enumerate (words : List String) : IO Unit := do
  let equal := weights words false
  let balanced := weights words true
  let me := pairMatrix words equal
  let mb := pairMatrix words balanced
  let decoders : List (String × (String → String)) := [
    ("Nearest visible word", nearest words),
    ("Hopfield, equal weights", hopfield me),
    ("Hopfield, rebalanced weights", hopfield mb),
    ("Time-zero hidden bit, equal weights", hiddenBits me (total equal) true),
    ("Time-zero hidden bit, rebalanced weights", hiddenBits mb (total balanced) true),
    ("Same without origin drift, equal weights", hiddenBits me (total equal) false),
    ("Same without origin drift, rebalanced weights", hiddenBits mb (total balanced) false)]
  let mut hits := Array.replicate (decoders.length * 4) 0
  let mut cases := 0
  for (w, k) in words.zipIdx do
    for m1 in [:bits] do
      for m2 in [m1+1:bits] do
        for f1 in [:bits] do
          for f2 in [f1+1:bits] do
            if f1 == m1 || f1 == m2 || f2 == m1 || f2 == m2 then continue
            let cue := corrupt w m1 m2 f1 f2
            cases := cases + 1
            for ((_, decode), d) in decoders.zipIdx do
              if decode cue == w then hits := hits.modify (d*4+k) (· + 1)
  IO.println s!"Target-labelled cases: {cases}"
  for ((name, _), d) in decoders.zipIdx do
    let row := (List.range 4).map fun k => hits[d*4+k]!
    let all := row.foldl (· + ·) 0
    IO.println s!"{name}: {all}/{cases} ({percent all cases}); per word {row}"

-- Compare the time-zero prediction with archived hidden-bit oscillator output.
private def agreement (words : List String) (balanced : Bool) (cuesFile predictionsFile : String) :
    IO Unit := do
  let ws := weights words balanced
  let m := pairMatrix words ws
  let mut predictions : List (String × String) := []
  for row in ← readLines predictionsFile do
    let [id, _, word] := row.splitOn "\t" | throw (IO.userError "expected ID, endpoint and word")
    predictions := (id, word) :: predictions
  let mut same := 0
  let mut unresolved := 0
  let mut differ := 0
  let mut wordsSame := 0
  let mut rows := 0
  for row in ← readLines cuesFile do
    let [id, cue] := row.splitOn "\t" | throw (IO.userError "expected ID and visible cue")
    let some observed := predictions.lookup id | throw (IO.userError s!"no prediction for {id}")
    let predicted := hiddenBits m (total ws) true cue
    rows := rows + 1
    if predicted == observed then wordsSame := wordsSame + 1
    for (p, o) in predicted.toList.zip observed.toList do
      if p == '?' then unresolved := unresolved + 1
      else if p == o then same := same + 1
      else differ := differ + 1
  IO.println s!"Time-zero sign equals archived symbol: {same}/{same + unresolved + differ}; unresolved {unresolved}; whole words identical {wordsSame}/{rows}"

-- Whole-word scores of the static references on a scheduled roster.
private def roster (words : List String) (scheduleFile : String) : IO Unit := do
  let me := pairMatrix words (weights words false)
  let mb := pairMatrix words (weights words true)
  let mut near := 0
  let mut equal := 0
  let mut balanced := 0
  let mut rows := 0
  for row in ← readLines scheduleFile do
    let [_, target, labels] := row.splitOn "\t" | throw (IO.userError "expected ID, target and labels")
    let cue := String.ofList ((target.toList.zip labels.toList).map fun (c, l) =>
      if l == 'M' then '?' else if l == 'F' then (if c == '1' then '0' else '1') else c)
    rows := rows + 1
    if nearest words cue == target then near := near + 1
    if hopfield me cue == target then equal := equal + 1
    if hopfield mb cue == target then balanced := balanced + 1
  IO.println s!"Nearest visible word {near}/{rows}; Hopfield equal {equal}/{rows}; Hopfield rebalanced {balanced}/{rows}"

end PairMemoryReference

def main (args : List String) : IO UInt32 := do
  match args with
  | ["--check"] => PairMemoryReference.controls
  | ["--enumerate", library] =>
    PairMemoryReference.enumerate (← PairMemoryReference.readWords library)
  | ["--roster", library, schedule] =>
    PairMemoryReference.roster (← PairMemoryReference.readWords library) schedule
  | ["--agreement", weighting, library, cues, predictions] =>
    unless weighting == "equal" || weighting == "rebalanced" do
      IO.eprintln "weighting must be equal or rebalanced"
      return 2
    PairMemoryReference.agreement (← PairMemoryReference.readWords library)
      (weighting == "rebalanced") cues predictions
  | _ =>
    IO.eprintln "Usage: pair-memory-reference --check | --enumerate WORDS | --roster WORDS SCHEDULE"
    IO.eprintln "       pair-memory-reference --agreement (equal|rebalanced) WORDS VISIBLE_CUES PREDICTIONS"
    return 2
  return 0
