# Spatial encoding and decoding

[ADR-095](../decisions/ADR-095.md) recovers the following engineering choices:

- Compact smooth `C∞` bumps with centers `(j+1/2)/N`.
- Bump radius `0.4/N`.
- An anchor value `0`.
- A `t=40` anchored signed-imaginary decoder.

[ADR-098](../decisions/ADR-098.md) recovers normalized observation rows and diagnostic quality gating.

## First 16-bit torus input

Place one bit at each center of a 4×4 tiling of the unit torus. Each coordinate ranges over $1/8,3/8,5/8,7/8$. The physical centers stay the same on all three solver grids. The bit index order, two-dimensional bump radius and normalization, and phase mapping remain open. The recovered one-dimensional center and radius above describe the historical ring reference. [Torus encoder decision](../decisions/ADR-115.md) · [Solver grids](../decisions/ADR-112.md)

## Recall anchor

At the historical recall time $t=40$, use the field phase at $(0,0)$ as the common reference. For an observed phase $u_j$ the anchored signal is the imaginary part of the conjugate of this reference times $u_j$. Common rotation of the reference and observations leaves the signal invariant. The spatial observation operator, bit polarity, thresholds, treatment of ambiguous scores, and evaluation of the origin on the numerical grid remain to be specified. [Origin anchor decision](../decisions/ADR-116.md)

The historical summaries leave the exact bump formula, decoder calibration, mapping from bits to phases, error handling, and sample constraints unrecovered.

No claim of invertibility, disjointness, retrieval correctness, or robustness is established by these parameter summaries alone.

[Bit-to-phase research and readout margins](../research/bit-to-phase-map.md) · [ADR-095](../decisions/ADR-095.md) · [ADR-098](../decisions/ADR-098.md) · [Architecture interfaces](../architecture/interfaces.md) · [Benchmark](../experiments/benchmarks.md).
