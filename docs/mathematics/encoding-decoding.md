# Spatial encoding and decoding

[ADR-095](../decisions/ADR-095.md) recovers the following engineering choices:

- Compact smooth `C∞` bumps with centers `(j+1/2)/N`.
- Bump radius `0.4/N`.
- An anchor value `0`.
- A `t=40` anchored signed-imaginary decoder.

[ADR-098](../decisions/ADR-098.md) recovers normalized observation rows and diagnostic quality gating.

The exact bump formula, normalization, decoder equation, calibration, pattern-to-phase mapping, error handling and sample constraints are **NOT RECOVERED**.

No claim of invertibility, disjointness, retrieval correctness, or robustness is established by these parameter summaries alone.

[ADR-095](../decisions/ADR-095.md) · [ADR-098](../decisions/ADR-098.md) · [Architecture interfaces](../architecture/interfaces.md) · [Benchmark](../experiments/benchmarks.md).
