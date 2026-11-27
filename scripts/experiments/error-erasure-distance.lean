module

import Mathlib.InformationTheory.Hamming
meta import Lean.Util.CollectAxioms

/-!
# Error and erasure geometry for the first recall library

The [research review](../../docs/research/error-correction-and-recall.md) specifies
EC-01 through EC-03. The [primary endpoint](../../docs/decisions/ADR-122.md)
counts whole words. This file uses mathlib for the general bound and a finite
enumeration for the one published library. It never calls the phase solver.
-/

namespace ErrorErasureDistance

private def visible {n : Nat} (erased : Finset (Fin n)) (word : Fin n → Bool) (i : Fin n) :=
  if i ∈ erased then false else word i

-- Assigning the same filler to both words at every mask counts exactly the
-- disagreements on the visible coordinates. Each mask can conceal at most one.
private theorem lostDistance {n : Nat} (erased : Finset (Fin n)) (x y : Fin n → Bool) :
    hammingDist x y ≤ hammingDist (visible erased x) (visible erased y) + erased.card := by
  unfold hammingDist
  refine (Finset.card_le_card ?_).trans (Finset.card_union_le _ _)
  intro i hi
  by_cases hm : i ∈ erased
  · exact Finset.mem_union_right _ hm
  · apply Finset.mem_union_left
    simpa [Finset.mem_filter, visible, hm] using hi

-- Apply this pairwise to every rival. With at most e visible errors and s
-- masks, a minimum separation strictly greater than 2e+s selects the target.
private theorem uniquelyCloser {n : Nat} (erased : Finset (Fin n)) (target other cue : Fin n → Bool)
    (errors : Nat) (he : hammingDist (visible erased target) (visible erased cue) ≤ errors)
    (sep : 2 * errors + erased.card < hammingDist target other) :
    hammingDist (visible erased target) (visible erased cue) <
      hammingDist (visible erased other) (visible erased cue) := by
  have hp := lostDistance erased target other
  have ht := hammingDist_triangle_right (visible erased target) (visible erased other)
    (visible erased cue)
  omega

run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``lostDistance, ``uniquelyCloser] do
    unless (← Lean.collectAxioms name).all (allowed.contains ·) do
      throwError "{name} has unexpected dependencies"

private abbrev Bits := BitVec 16

-- Words are read in printed bit order. A one in 'known' marks a visible
-- position. Keep the cue's unknown symbols out of every distance comparison.
private def parseCue (s : String) : Option (Bits × Bits) := do
  guard (s.length == 16)
  let mut word : Bits := 0
  let mut known : Bits := 0
  for c in s.toList do
    guard (c == '0' || c == '1' || c == '?')
    word := (word <<< 1) ||| (if c == '1' then 1 else 0)
    known := (known <<< 1) ||| (if c == '?' then 0 else 1)
  return (word, known)

private def distance (visibleMask a b : Bits) : Nat := (((a ^^^ b) &&& visibleMask).cpop).toNat

-- Each mask occurs once per pair of distinct bit positions.
private def pairs : List Bits := do
  let i ← List.range 16
  let j ← List.range i
  return ((1 : Bits) <<< i) ||| (1 <<< j)

private structure Counts where
  right : Nat := 0
  tie : Nat := 0
  wrong : Nat := 0
  ambiguousExact : Nat := 0
  deriving BEq, Repr

private def audit (words : List Bits) : Counts := Id.run do
  let mut counts : Counts := {}
  for hidden in pairs do
    let known := ~~~hidden
    for flip in pairs do
      if (flip &&& hidden) != 0 then continue
      for target in words do
        let cue := target ^^^ flip
        let ds := words.map (distance known cue ·)
        let best := ds.min?.getD 17
        if ds.count best > 1 then counts := {counts with tie := counts.tie + 1}
        else if best == distance known cue target then counts := {counts with right := counts.right + 1}
        else counts := {counts with wrong := counts.wrong + 1}
        if ds.count 2 > 1 then counts := {counts with ambiguousExact := counts.ambiguousExact + 1}
  return counts

private def check (p : Bool) (message : String) : IO Unit :=
  unless p do throw (IO.userError message)

def run (path : String) : IO Unit := do
  let lines := (← IO.FS.readFile path).splitOn "\n" |>.map (·.trimAscii.toString) |>.filter (!·.isEmpty)
  let some words := lines.mapM (fun s => do
    let (word, known) ← parseCue s
    guard (known == ~~~(0 : Bits))
    return word) | throw (IO.userError "invalid library word")
  check (words.length == 4 && words.eraseDups.length == 4) "expected four distinct words"
  let pairDistances := words.zipIdx.flatMap fun (w, i) => (words.drop (i+1)).map (distance (~~~0) w ·)
  check (pairDistances == [16,6,4,10,12,6]) "unexpected pair distances for the published library"
  let some (cue, known) := parseCue "?10?010011110001" | throw (IO.userError "invalid witness")
  check ((~~~known).cpop.toNat == 2 && words.map (distance known cue ·) == [2,12,6,2])
    "two different targets must generate the witness with exactly two flips and two erasures"
  check (pairs.length == 120 && pairs.eraseDups.length == 120) "two-position mask enumeration"
  let counts := audit words
  check (counts == ⟨41958,1422,300,1422⟩) "exhaustive static decoder counts changed"
  IO.println s!"Six pair distances: {pairDistances}; witness distances: {words.map (distance known cue ·)}"
  IO.println s!"Static nearest-visible decoder: {counts.right} correct, {counts.tie} tied, {counts.wrong} wrong"
  IO.println s!"Cases with multiple targets at exactly two visible errors: {counts.ambiguousExact}"

end ErrorErasureDistance

public def main (args : List String) : IO Unit := do
  let [path] := args | throw (IO.userError "expected the path to the first development library")
  ErrorErasureDistance.run path
