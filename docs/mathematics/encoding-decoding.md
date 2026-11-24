# Spatial encoding and decoding

[ADR-095](../decisions/ADR-095.md) recovers the following engineering choices:

- Compact smooth `C∞` bumps with centers `(j+1/2)/N`.
- Bump radius `0.4/N`.
- An anchor value `0`.
- A `t=40` anchored signed-imaginary decoder.

[ADR-098](../decisions/ADR-098.md) recovers normalized observation rows and diagnostic quality gating.

## First 16-bit torus input

Place one bit at each center of a 4×4 tiling of the unit torus. Each coordinate ranges over $1/8,3/8,5/8,7/8$. The physical centers stay the same on all three solver grids. The bit index order and two-dimensional bump width and normalization remain open. The recovered one-dimensional center and radius above describe the historical ring reference. [Torus encoder decision](../decisions/ADR-115.md) · [Solver grids](../decisions/ADR-112.md)

The primary sample grid contains the physical bit centers and origin. A half-cell shift along both axes supplies a placement sensitivity test. The reconstruction rule for off-grid observations is still open. [Grid placement](../decisions/ADR-121.md)

## Presented and masked bits

A presented 0 uses a negative offset relative to the origin phase, and a presented 1 a positive offset. Use −90° and +90° in the primary map and −45° and +45° in the comparison. For a masked bit, omit its stimulus, record the background phase initialization, and score recovery against the hidden target. A masked site can already have a nonzero signed score. [Phase-map decision](../decisions/ADR-118.md) · [Mask decision](../decisions/ADR-119.md) · [Lean check](../../scripts/experiments/bit-phase-readout.lean)

For the primary validation, initialize the phase field uniformly. An omitted point then has the same phase as the origin and an initial signed point score of zero. Repeat with a recorded, reproducible, target-independent spatial background as a sensitivity check. Its generator and parameters still need specification. [Cue background](../decisions/ADR-120.md)

## Recall anchor

At the historical recall time $t=40$, use the field phase at $(0,0)$ as the common reference. For an observed phase $u_j$ the anchored signal is the imaginary part of the conjugate of this reference times $u_j$. Common rotation of the reference and observations leaves the signal invariant. The spatial observation operator, thresholds, treatment of ambiguous scores, and evaluation of the origin on the numerical grid remain to be specified. [Origin anchor decision](../decisions/ADR-116.md)

The historical summaries leave the exact bump formula, decoder calibration, mapping from bits to phases, error handling, and sample constraints unrecovered.

No claim of invertibility, disjointness, retrieval correctness, or robustness is established by these parameter summaries alone.

[Bit-to-phase research and readout margins](../research/bit-to-phase-map.md) · [ADR-095](../decisions/ADR-095.md) · [ADR-098](../decisions/ADR-098.md) · [Architecture interfaces](../architecture/interfaces.md) · [Benchmark](../experiments/benchmarks.md).
