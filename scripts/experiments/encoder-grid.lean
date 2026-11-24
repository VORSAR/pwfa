module

import Std

/-!
# Which samples see a compact encoder bump?

The [solver grids](../../docs/decisions/ADR-112.md) have 128, 256 and 512 sites.
The [bit centers](../../docs/decisions/ADR-115.md) stay fixed when the grid is refined.
The [internal review](../../docs/research/bit-to-phase-map.md#internal-review-of-grid-placement-and-encoder-support)
specifies exact physical coordinates and an open support disk. These finite checks
describe which point samples have positive weight for a profile positive inside that disk.
-/

namespace EncoderGridExperiment

-- Reduction checks finite lists of up to 512 sites without native evaluation.
set_option maxRecDepth 8192

private abbrev Site := Nat × Nat
private def period : Nat := 320
private def grids : List Site := [(16, 8), (16, 16), (32, 16)]
private def bitAxis : List Nat := [40, 120, 200, 280]

private def product (xs ys : List Nat) : List Site :=
  xs.flatMap fun x => ys.map fun y => (x, y)

private def centers := product bitAxis bitAxis

private inductive Placement where
  | origin | halfCell

private def axis (n : Nat) (p : Placement) : List Nat :=
  let step := period / n
  let start := match p with | .origin => 0 | .halfCell => step / 2
  (List.range n).map fun k => start + step * k

private def samples (g : Site) (p : Placement) :=
  product (axis g.1 p) (axis g.2 p)

-- Coordinates lie in [0,320), with 0 and 320 representing the same point.
private def periodicGap (a b : Nat) : Nat :=
  let direct := max a b - min a b
  min direct (period - direct)

private def inside (r : Nat) (center sample : Site) : Bool :=
  let dx := periodicGap center.1 sample.1
  let dy := periodicGap center.2 sample.2
  dx * dx + dy * dy < r * r

-- Check membership of both the origin anchor and all sixteen distinct bit centers.
example : centers.eraseDups.length = 16 ∧ grids.all (fun g =>
    ((0, 0) :: centers).all fun c => (samples g .origin).contains c) = true := by decide +kernel

example : grids.all (fun g => ((0, 0) :: centers).all fun c =>
    !(samples g .halfCell).contains c) = true := by decide +kernel

-- A seam-crossing neighbor is inside. A point exactly one radius away is outside.
example : inside 32 (0, 0) (300, 0) = true ∧ inside 40 (40, 40) (40, 80) = false := by decide +kernel

-- Compare all sixteen centers separately. Counts run in the fixed grid order above.
private def countsAgree (p : Placement) (r : Nat) (expected : List Nat) : Bool :=
  (grids.map fun g =>
    let sites := samples g p
    centers.map fun c => sites.countP (inside r c)) ==
    expected.map fun count => List.replicate centers.length count

example : countsAgree .origin 32 [3, 9, 17] = true := by decide +kernel

example : countsAgree .origin 40 [3, 9, 21] = true := by decide +kernel

example : countsAgree .halfCell 32 [4, 12, 16] = true := by decide +kernel

example : countsAgree .halfCell 40 [8, 12, 28] = true := by decide +kernel

-- On the origin-aligned 16×8 grid both radii illuminate just the center's own row.
example : centers.all (fun c => ([32, 40] : List Nat).all fun r =>
    ((samples (16, 8) .origin).filter (inside r c)).all fun s => s.2 == c.2) = true := by
  decide +kernel

end EncoderGridExperiment
