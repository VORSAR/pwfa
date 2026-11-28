import Std

/-!
# First trained 16-bit recall development run

The [frozen protocol](../../docs/experiments/first-trained-recall.md) specifies
the one library, equations, inputs and scoring boundary for this experiment.
This executable reads training words and **visible** cues. The separate Lean
scorer has the evaluation targets and corruption labels. Angles are in radians.
The [held-training comparison](../../docs/experiments/held-word-training.md)
changes the phase history during training and reuses the original retrieval path.
The [structural retrieval comparison](../../docs/experiments/structural-coupling-at-retrieval.md)
uses each trained matrix in both retrieval conditions.
The [queried-bit experiment](../../docs/experiments/recall-with-queried-bit-hidden.md)
uses the same oscillator to reconstruct each position from a separately prepared cue.
The [complement-weight comparison](../../docs/experiments/complement-balanced-training.md)
changes only the coefficients of the four held episode matrices.
-/

namespace FirstRecall

private def nx := 16
private def ny := 8
private def sites := nx * ny
private def pi := 3.14159265358979323846
private def structuralLag := pi / 2 - 0.1
private def vector (n : Nat) (f : Nat → Float) : FloatArray := Id.run do
  let mut a := FloatArray.emptyWithCapacity n
  for i in [:n] do a := a.push (f i)
  return a

-- Grid nodes and bit centers coincide on the origin-aligned 16×8 grid.
private def center (bit : Nat) := 2 + 4 * (bit % 4) + nx * (1 + 2 * (bit / 4))

private def axisDistance (n a b : Nat) : Float :=
  let d := max a b - min a b
  (min d (n-d)).toFloat / n.toFloat

private def distanceSq (a b : Nat) : Float :=
  let x := axisDistance nx (a % nx) (b % nx)
  let y := axisDistance ny (a / nx) (b / nx)
  x*x + y*y

-- The factor e converting the structural bump to a peak-one bump cancels
-- under row normalization. For the encoder the value at the peak matters.
private def bump (s : Float) : Float :=
  if s < 1 then Float.exp (-s / (1-s)) else 0

private def prepare (symbols : String) : FloatArray := Id.run do
  let mut a := vector sites fun _ => 0
  for (c, bit) in symbols.toList.zipIdx do
    if c != '?' then
      let angle := if c == '1' then pi/2 else -pi/2
      for i in [:sites] do
        a := a.set! i (a[i]! + angle * bump (64 * distanceSq i (center bit)))
  return a

private def structuralWeights : FloatArray := Id.run do
  let raw i j := bump (16 * distanceSq i j)
  let mass := (vector sites (raw 0)).foldl (· + ·) 0
  return vector (sites*sites) fun k => raw (k / sites) (k % sites) / mass

private structure Entry where
  site : Nat
  re : Float
  im : Float
private abbrev Coupling := Array (Array Entry)

-- Structural weights carry exp(-iα); the frozen learned matrix has zero lag
-- and a single source-area factor 1/N (ADR-128/129). Both include the diagonal.
private def coupling (weights : FloatArray) (learned : Option FloatArray) (gain : Float)
    (structuralStrength : Float := 1) :
    Coupling := Id.run do
  let mut rows := #[]
  for i in [:sites] do
    let mut row := #[]
    for j in [:sites] do
      let k := i*sites+j
      -- IS-01 scales a normalized structural row without scaling the learned field.
      let w := structuralStrength * weights[k]!
      let l := match learned with
        | some m => gain * m[k]! / sites.toFloat
        | none => 0
      if w != 0 || l != 0 then
        row := row.push ⟨j, w*Float.cos structuralLag + l, -w*Float.sin structuralLag⟩
    rows := rows.push row
  return rows

private structure Phases where
  co : FloatArray
  si : FloatArray

private def phases (a : FloatArray) : Phases :=
  ⟨vector sites (fun i => Float.cos a[i]!), vector sites (fun i => Float.sin a[i]!)⟩

-- Imaginary part of conjugate(z_i) times the combined structural and
-- learned mean. The resulting real number is the angular velocity.
private def velocity (op : Coupling) (z : Phases) : FloatArray := Id.run do
  let mut speeds := FloatArray.emptyWithCapacity sites
  for row in op do
    let i := speeds.size
    let mut re := 0.0
    let mut im := 0.0
    for e in row do
      let c := z.co[e.site]!
      let s := z.si[e.site]!
      re := re + e.re*c - e.im*s
      im := im + e.re*s + e.im*c
    speeds := speeds.push (z.co[i]! * im - z.si[i]! * re)
  return speeds

private def advance (a v : FloatArray) (dt : Float) : FloatArray :=
  vector sites fun i => a[i]! + dt*v[i]!

-- The same midpoint snapshot supplies both the final update and the pair
-- statistic. Every new phase is represented on the unit circle via sin/cos.
private def step (op : Coupling) (a : FloatArray) (dt : Float) : FloatArray × Phases :=
  let mid := phases (advance a (velocity op (phases a)) (dt/2))
  (advance a (velocity op mid) dt, mid)

private def accumulate (sum : FloatArray) (mid : Phases) : FloatArray := Id.run do
  let mut sum := sum
  for i in [:sites] do
    let c := mid.co[i]!
    let s := mid.si[i]!
    for j in [:sites] do
      let k := i*sites+j
      sum := sum.set! k (sum[k]! + (c*mid.co[j]! + s*mid.si[j]!))
  return sum

-- ADR-124 through ADR-127 give each of four full windows equal weight.
-- All four have the same duration and constant dt in a single condition.
private def train (words : List String) (op : Coupling) (duration resolution : Nat) :
    FloatArray := Id.run do
  let steps := duration*resolution
  let dt := 1 / resolution.toFloat
  let mut sum := vector (sites*sites) fun _ => 0
  for w in words do
    let mut a := prepare w
    for _ in [:steps] do
      let (next, mid) := step op a dt
      sum := accumulate sum mid
      a := next
  return vector sum.size fun k => sum[k]! / (words.length*steps).toFloat

-- In a held episode every midpoint has the same prepared phases. Integer
-- numerators weight each complete matrix, including background sites.
-- The denominator is their sum, so the learned gain has the same scale.
private def heldMean (terms : List (String × Nat)) : FloatArray := Id.run do
  let mut sum := vector (sites*sites) fun _ => 0
  let mut total := 0
  for (word, count) in terms do
    let field := phases (prepare word)
    for _ in [:count] do sum := accumulate sum field
    total := total + count
  return vector sum.size fun k => sum[k]! / total.toFloat

-- ADR-124 gives each held episode one vote in the original control.
private def trainHeld (words : List String) : FloatArray :=
  heldMean (words.map fun w => (w, 1))

-- BW-01: readWords supplies four distinct binary words. For the experimental
-- arm only, both members of the unique complementary pair get one sixth.
-- Each remaining word gets two sixths, regardless of training-file order.
private def balancedTerms (words : List String) : Option (List (String × Nat)) := do
  let terms := words.map fun w =>
    let opposite := w.map fun c => if c == '0' then '1' else '0'
    (w, if words.contains opposite then 1 else 2)
  guard (terms.countP (fun t => t.2 == 1) == 2)
  return terms

#guard balancedTerms ["010", "000", "011", "111"] ==
  some [("010", 2), ("000", 1), ("011", 2), ("111", 1)]
#guard (balancedTerms ["000", "001", "010", "011"]).isNone
#guard (balancedTerms ["000", "111", "010", "101"]).isNone

private def validMemory (m : FloatArray) : Bool := Id.run do
  for i in [:sites] do
    if Float.abs (m[i*sites+i]! - 1) > 1e-10 then return false
    for j in [:sites] do
      let v := m[i*sites+j]!
      if !v.isFinite || Float.abs v > 1+1e-10 || Float.abs (v-m[j*sites+i]!) > 1e-10 then
        return false
  return true

private def decode (a : FloatArray) : String := Id.run do
  if !(a.foldl (fun ok t => ok && t.isFinite) true) then return "FAILED"
  let mut bits := ""
  for b in [:16] do
    let score := Float.sin (a[center b]! - a[0]!)
    bits := bits.push (if score > 0.000001 then '1' else if score < -0.000001 then '0' else '?')
  return bits

private def retrieve (op : Coupling) (symbols : String) (resolution : Nat) : String := Id.run do
  let mut a := prepare symbols
  let dt := 1 / resolution.toFloat
  for _ in [:40*resolution] do a := (step op a dt).1
  return decode a

-- QB-01: restart with the original cue for every bit and omit that bit
-- before encoding. Only its own decoded symbol enters the assembled word.
private def assembleContext (predict : String → String) (symbols : String) : String := Id.run do
  let original := symbols.toList
  let mut answer := ""
  for j in [:original.length] do
    let decoded := predict (String.ofList (original.set j '?'))
    if decoded == "FAILED" then return "FAILED"
    answer := answer.push decoded.toList[j]!
  return answer

#guard assembleContext id "10?0" == "????"
#guard assembleContext (fun _ => "10?0") "0110" == "10?0"
#guard assembleContext (fun q => if q == "0?10" then "FAILED" else "1111") "0110" == "FAILED"
#guard assembleContext (fun q => match q with
  | "?10?" => "1???"
  | "0?0?" => "?0??"
  | "01??" => "??1?"
  | "010?" => "???0"
  | _ => "FAILED") "010?" == "1010"

private def check (p : Bool) (msg : String) : IO Unit :=
  unless p do throw (IO.userError msg)

-- The synchronized trajectory and isolated positive pair torque catch sign,
-- area, phase lag, and angular-update errors before running a whole library.
private def controls : IO Unit := do
  let clean := "0011010011110001"
  let mixed := "?01101001111000?"
  check (decode (prepare clean) == clean && decode (prepare mixed) == mixed &&
    (prepare clean)[0]! == 0) "encoding / anchored sign"
  let uniform := vector sites fun _ => 0
  let op := coupling structuralWeights none 0
  let expected := -Float.sin structuralLag
  let (a, mid) := step op uniform 0.05
  check ((velocity op (phases uniform)).foldl (fun ok x => ok && Float.abs (x-expected) < 1e-12) true &&
    Float.abs (a[0]! - 0.05*expected) < 1e-12 &&
    Float.abs (mid.si[0]! - Float.sin (0.025*expected)) < 1e-12) "synchronized midpoint"
  let memory := vector (sites*sites) fun k =>
    if k == 1 || k == sites || k / sites == k % sites then 1 else 0
  let two := phases (uniform.set! 1 (pi/2))
  let pair := coupling (vector (sites*sites) fun _ => 0) (some memory) 0.25
  let v := velocity pair two
  let rate := 0.25 / sites.toFloat
  check (Float.abs (v[0]!-rate) < 1e-12 && Float.abs (v[1]!+rate) < 1e-12) "isolated pair"
  let sample := accumulate (vector (sites*sites) fun _ => 0) two
  check (validMemory sample && Float.abs sample[1]! < 1e-12 && sample[2]! == 1) "sample alignment"

  -- SR-02 isolates the structural contribution, with a nonzero learned
  -- torque. Removing both interactions must leave an arbitrary cue still.
  let combined := velocity (coupling structuralWeights (some memory) 0.25) two
  let structural := velocity op two
  check ((List.range sites).all fun i => Float.abs (combined[i]! - v[i]! - structural[i]!) < 1e-12)
    "retrieval contributions add"
  for strength in ([0.0, 0.25, 0.5, 0.75] : List Float) do
    let scaled := velocity (coupling structuralWeights (some memory) 0.25 strength) two
    check ((List.range sites).all fun i =>
      Float.abs (scaled[i]! - (v[i]! + strength*structural[i]!)) < 1e-12)
      s!"structural strength {strength} must preserve the full learned torque"
  let noInteraction := coupling (vector (sites*sites) fun _ => 0) none 0
  let initial := prepare mixed
  check ((step noInteraction initial 0.05).1 == initial) "zero-coupling cue retention"

  -- HT-01 checks four distinct words. At the first three centers their
  -- signed agreements give +1/2, -1/2 and 0 for the three different pairs.
  -- The neighboring bump site also contributes at its actual prepared phase.
  let held := trainHeld ["0000000000000000", "0010000000000000",
                         "1100000000000000", "0100000000000000"]
  let pairAt (a b : Nat) := held[center a * sites + center b]!
  check (validMemory held && Float.abs (pairAt 0 1 - 0.5) < 1e-12 &&
    Float.abs (pairAt 1 2 + 0.5) < 1e-12 && Float.abs (pairAt 0 2) < 1e-12 &&
    Float.abs (held[center 0 + 1]! - Float.cos (pi/2 * bump 0.25)) < 1e-12)
    "held full-field training mean"

  -- BW-02: for these four words, the two first bit centers agree in
  -- both complementary fields and disagree in both others. Equal weighting
  -- gives zero there; the selected coefficients give (1+1-2-2)/6.
  let library := ["0000000000000000", "1111111111111111", "1000000000000000", "0100000000000000"]
  let some terms := balancedTerms library | throw (IO.userError "expected one complement pair")
  let some reversed := balancedTerms library.reverse | throw (IO.userError "lost complement on reversal")
  let weighted := heldMean terms
  let k := center 0 * sites + center 1
  check (validMemory weighted && Float.abs ((trainHeld library)[k]!) < 1e-12 &&
    Float.abs (weighted[k]! + 1/3) < 1e-12 && reversed == terms.reverse)
    "complement weights, normalization and ordering"

private def wordOK (s : String) (allowMask : Bool) : Bool :=
  s.length == 16 && s.toList.all fun c => c == '0' || c == '1' || (allowMask && c == '?')

private def readLines (path : String) : IO (List String) := do
  return ((← IO.FS.readFile path).splitOn "\n").map (·.dropSuffix "\r" |>.toString)
    |>.filter (!·.isEmpty)

private def writePredictions (output : System.FilePath) (cues : List (String × String))
    (predict : String → String) : IO Unit := do
  let rows := cues.map fun (id, symbols) => id ++ "\t40\t" ++ predict symbols
  IO.FS.writeFile output (String.intercalate "\n" rows ++ "\n")
  IO.eprintln s!"Wrote {output}"

private def writeArm (output : System.FilePath) (op : Coupling) (cues : List (String × String))
    (resolution : Nat) : IO Unit :=
  writePredictions output cues (fun s => retrieve op s resolution)

private def readWords (wordsFile : String) : IO (List String) := do
  let words ← readLines wordsFile
  check (words.length == 4 && words.eraseDups.length == 4 && words.all (wordOK · false))
    "expected four distinct 16-bit training words"
  return words

private def readCues (cuesFile : String) : IO (List (String × String)) := do
  let mut cues := #[]
  for row in ← readLines cuesFile do
    let [id, symbols] := row.splitOn "\t" | throw (IO.userError "expected ID and visible cue")
    check (!id.isEmpty && wordOK symbols true) "invalid visible cue"
    cues := cues.push (id, symbols)
  let ids := cues.toList.map Prod.fst
  check (ids.length == 16 && ids.eraseDups.length == 16) "expected 16 distinct development cue IDs"
  return cues.toList

-- DI-02 is a static information check. It sees only a visible cue and the
-- four training words. An equal best distance is an unresolved prediction.
private def visibleDistance (cue word : String) : Nat :=
  (cue.toList.zip word.toList).countP fun (c, b) => c != '?' && c != b

private def nearest (words : List String) (cue : String) : Option String := do
  let distances := words.map fun w => (w, visibleDistance cue w)
  let best ← (distances.map Prod.snd).min?
  let [(w, _)] := distances.filter (·.2 == best) | none
  return w

#guard nearest ["0000", "1111"] "?010" == some "0000"
#guard nearest ["0000", "1111"] "?01?" == none
#guard nearest ["0000", "1111"] "????" == none

private def run (resolution : Nat) (words : List String) (cues : List (String × String))
    (directory : String) : IO Unit := do
  controls
  let dest : System.FilePath := directory
  IO.FS.createDirAll dest
  let weights := structuralWeights
  let structural := coupling weights none 0
  writeArm (dest / "off.tsv") structural cues resolution
  for duration in [25, 50] do
    let m := train words structural duration resolution
    check (validMemory m) s!"invalid {duration}-unit trained memory"
    writeArm (dest / s!"trained-{duration}.tsv") (coupling weights (some m) 0.25) cues resolution

private def cleanProbes (words : List String) : List (String × String) :=
  words.zipIdx.map fun (w, i) => (s!"word-{i+1}", w)

private def writeProbes (directory : System.FilePath) (label : String) (op : Coupling)
    (words : List String) (cues : List (String × String)) (resolution : Nat) : IO Unit := do
  IO.FS.createDirAll directory
  writeArm (directory / s!"{label}.tsv") op cues resolution
  writeArm (directory / s!"{label}-clean.tsv") op (cleanProbes words) resolution

-- HT-02 changes only the trained matrix. Both the damaged and clean cues
-- are released normally, with structural coupling active all the way to t=40.
private def runHeld (resolution : Nat) (words : List String) (cues : List (String × String))
    (directory : String) : IO Unit := do
  controls
  let held := trainHeld words
  check (validMemory held) "invalid held training memory"
  let op := coupling structuralWeights (some held) 0.25
  writeProbes directory "held" op words cues resolution

-- SR-01: train each matrix once, then pass that very matrix to both
-- retrieval operators. The free training trajectories always use structure.
private def compareRetrieval (resolution : Nat) (words : List String)
    (cues : List (String × String)) (directory : String) : IO Unit := do
  controls
  let weights := structuralWeights
  let trainingOp := coupling weights none 0
  let zeroWeights := vector (sites*sites) fun _ => 0
  let matrices := [("free-25", train words trainingOp 25 resolution),
                   ("free-50", train words trainingOp 50 resolution),
                   ("held", trainHeld words)]
  let dest : System.FilePath := directory
  for (label, memory) in matrices do
    check (validMemory memory) s!"invalid {label} training memory"
    for (arm, spatial) in [("structural-on", weights), ("structural-off", zeroWeights)] do
      let op := coupling spatial (some memory) 0.25
      writeProbes (dest / arm) label op words cues resolution

-- The predeclared strength screen keeps the same held matrix and gain at
-- every point. Zero and one reproduce the paired comparison as controls.
private def compareHeldStrengths (resolution : Nat) (words : List String)
    (cues : List (String × String)) (directory : System.FilePath) : IO Unit := do
  controls
  let held := trainHeld words
  check (validMemory held) "invalid held training memory"
  let weights := structuralWeights
  for (arm, strength) in [("zero", 0.0), ("quarter", 0.25), ("half", 0.5),
                           ("three-quarters", 0.75), ("one", 1.0)] do
    let op := coupling weights (some held) 0.25 strength
    writeProbes (directory / arm) "held" op words cues resolution

-- QB-02: the only difference between the two readouts is the presented
-- cue and which bit is taken from each trajectory. Neither predictor sees
-- the target or the positions that were deliberately flipped.
private def compareContext (resolution : Nat) (words : List String)
    (cues : List (String × String)) (directory : System.FilePath) (balanced : Bool := false) : IO Unit := do
  controls
  let memory ← if balanced then do
    let some terms := balancedTerms words
      | throw (IO.userError "balanced training requires exactly one complementary pair")
    pure (heldMean terms)
  else pure (trainHeld words)
  check (validMemory memory) "invalid held training memory"
  let op := coupling structuralWeights (some memory) 0.25 0
  writeProbes directory "direct" op words cues resolution
  let predict := assembleContext (fun s => retrieve op s resolution)
  writePredictions (directory / "context.tsv") cues predict
  writePredictions (directory / "context-clean.tsv") (cleanProbes words) predict

private def resolution (arg : String) : IO Nat := do
  let some r := arg.toNat? | throw (IO.userError "expected steps per unit")
  unless r == 20 || r == 40 do throw (IO.userError "use 20 or 40 steps per time unit")
  return r

end FirstRecall

def main (args : List String) : IO UInt32 := do
  match args with
  | ["--check"] => FirstRecall.controls
  | ["--visible-lookup", library, cues] =>
    let words ← FirstRecall.readWords library
    for (id, cue) in ← FirstRecall.readCues cues do
      IO.println (id ++ "\t" ++ (FirstRecall.nearest words cue).getD "????????????????")
  | ["--clean", steps, library, output] =>
    let words ← FirstRecall.readWords library
    FirstRecall.run (← FirstRecall.resolution steps) words (FirstRecall.cleanProbes words) output
  | ["--held", steps, words, cues, output] =>
    FirstRecall.runHeld (← FirstRecall.resolution steps) (← FirstRecall.readWords words)
      (← FirstRecall.readCues cues) output
  | ["--compare-structure", steps, words, cues, output] =>
    FirstRecall.compareRetrieval (← FirstRecall.resolution steps) (← FirstRecall.readWords words)
      (← FirstRecall.readCues cues) output
  | ["--held-strengths", steps, words, cues, output] =>
    FirstRecall.compareHeldStrengths (← FirstRecall.resolution steps) (← FirstRecall.readWords words)
      (← FirstRecall.readCues cues) output
  | ["--compare-context", steps, words, cues, output] =>
    FirstRecall.compareContext (← FirstRecall.resolution steps) (← FirstRecall.readWords words)
      (← FirstRecall.readCues cues) output
  | ["--balanced-context", steps, words, cues, output] =>
    FirstRecall.compareContext (← FirstRecall.resolution steps) (← FirstRecall.readWords words)
      (← FirstRecall.readCues cues) output true
  | [steps, words, cues, output] =>
    FirstRecall.run (← FirstRecall.resolution steps) (← FirstRecall.readWords words)
      (← FirstRecall.readCues cues) output
  | _ =>
    IO.eprintln "Usage: first-recall --check | (20|40) WORDS VISIBLE_CUES OUTPUT_DIRECTORY"
    IO.eprintln "       first-recall --held (20|40) WORDS VISIBLE_CUES OUTPUT_DIRECTORY"
    IO.eprintln "       first-recall --compare-structure (20|40) WORDS VISIBLE_CUES OUTPUT_DIRECTORY"
    IO.eprintln "       first-recall --held-strengths (20|40) WORDS VISIBLE_CUES OUTPUT_DIRECTORY"
    IO.eprintln "       first-recall (--compare-context|--balanced-context) (20|40) WORDS VISIBLE_CUES OUTPUT_DIRECTORY"
    IO.eprintln "       first-recall --clean (20|40) WORDS OUTPUT_DIRECTORY | --visible-lookup WORDS VISIBLE_CUES"
    return 2
  return 0
