# Exact-recall benchmark

**Status:** proposed/selected configuration; **no recorded results**.

[ADR-099](../decisions/ADR-099.md) identifies the *primary* benchmark:

| Parameter | Recovered selection |
|---|---|
| Pattern length | 16 bits |
| Spatial samples | 128 |
| Stored patterns | 4 |
| Libraries | 100 |
| Cue corruption | 10% flipped, 10% masked, rounded non-overlapping rule |
| Evaluation cues | Held-out, deterministic |

The first 16-bit torus input uses the sixteen centers of a 4×4 tiling. Its 128-site solver grid has dimensions 16×8. [Input geometry](../decisions/ADR-115.md) · [Solver grid](../decisions/ADR-112.md)

**Sensitivity experiments:** 32-bit patterns, 256/512 samples, loads 1/8/16, phase/radius/orientation, antipodal conditions, reversed order.

[ADR-100](../decisions/ADR-100.md) specifies a **target**, not a result: at least five percentage points exact-recall advantage over a preregistered matched-budget comparator, with clustered 95% confidence interval lower bound above zero.

**Unspecified:** baseline identity, exact recall metric, clustering unit, cue generator, rounding/seed specifics, model schedule, sample-size/power rationale and resource budget.

[Methodology](methodology.md) · [Controls](baselines.md) · [Research hypotheses](../vision/hypotheses.md) · [Verification obligations](../verification/proof-obligations.md).
