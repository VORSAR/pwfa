# Spatial encoding and decoding

[ADR-095](../decisions/ADR-095.md) recovers the following engineering choices:

- Compact smooth `C∞` bumps with centers `(j+1/2)/N`.
- Bump radius `0.4/N`.
- An anchor value `0`.
- A `t=40` anchored signed-imaginary decoder.

[ADR-098](../decisions/ADR-098.md) recovers normalized observation rows and diagnostic quality gating.

## First 16-bit torus input

Place one bit at each center of a 4×4 tiling of the unit torus. Each coordinate ranges over $1/8,3/8,5/8,7/8$. The physical centers stay the same on all three solver grids. The bit index order, two-dimensional bump radius and normalization, phase mapping, anchor behavior, and ambiguity rule remain open. The recovered one-dimensional center and radius above describe the historical ring reference. [Torus encoder decision](../decisions/ADR-115.md) · [Solver grids](../decisions/ADR-112.md)

The exact bump formula, normalization, decoder equation, calibration, pattern-to-phase mapping, error handling and sample constraints are **NOT RECOVERED**.

No claim of invertibility, disjointness, retrieval correctness, or robustness is established by these parameter summaries alone.

[ADR-095](../decisions/ADR-095.md) · [ADR-098](../decisions/ADR-098.md) · [Architecture interfaces](../architecture/interfaces.md) · [Benchmark](../experiments/benchmarks.md).
