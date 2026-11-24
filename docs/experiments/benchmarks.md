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
| Recall endpoint | Decode at $t=40$ relative to the simultaneous phase at the origin |

The primary accuracy question is how often the trained system recovers the **entire original 16-bit word** from a corrupted cue at $t=40$, including the flipped and masked positions. A clean encoder score at cue preparation measures the input signal. A high score there can faithfully encode a flipped input. The hidden target is used for scoring after recall. [Recall time and anchor](../decisions/ADR-116.md) · [Held-out benchmark](../decisions/ADR-099.md) · [Clean encoder results](../research/bit-to-phase-map.md#checked-clean-readout-at-the-candidate-radii)

The first 16-bit torus input uses the sixteen centers of a 4×4 tiling. Its 128-site solver grid has dimensions 16×8. [Input geometry](../decisions/ADR-115.md) · [Solver grid](../decisions/ADR-112.md)

For phase-map validation, compare the primary ±90° map with the ±45° map on the same cues. A masked position receives no bit-specific stimulus. Record the cue background initialization and evaluate the masked positions against their held-out target bits at recall. [Bit phases](../decisions/ADR-118.md) · [Masked cues](../decisions/ADR-119.md)

Run the primary encoder validation on a uniform unit-phase background. Repeat on a reproducible, target-independent spatial background, recording its initialization. Pair backgrounds and corrupted cues across both phase maps. [Cue background](../decisions/ADR-120.md)

**Sensitivity experiments:** 32-bit patterns, 256/512 samples, loads 1/8/16, phase/radius/orientation, antipodal conditions, reversed order.

## First trained recall measurement

The first end-to-end pilot needs a specified learned-memory and trace update, training schedule and reset/carry values, cue-to-recall transition and clock origin, runnable evolution through $t=40$, and a decoder with an explicit ambiguity rule. The current Lean checks cover the unforced oscillator and cue geometry. The repository has no trained recall runs to score. [Memory contract](../mathematics/memory.md) · [Training protocol](methodology.md) · [Decoder](../mathematics/encoding-decoding.md)

For an encoder-radius comparison, use the same target libraries, training order, corrupted cues, and other settings for each candidate width, and apply each width consistently in training and recall. Record the number of exact words and total cues, plus masked-bit recovery and flipped-bit correction so a whole-word miss can be interpreted. Record ties or failed runs explicitly and fix their scoring and the aggregation rule before collecting results. If pilot results guide the choice of width, evaluate the frozen choice on untouched benchmark data. The external comparator and matched budget are needed to test the performance advantage below. A first measurement of PWFA's own recall rate can proceed once its recall path is defined.

[ADR-100](../decisions/ADR-100.md) specifies a **target**, not a result: at least five percentage points exact-recall advantage over a preregistered matched-budget comparator, with clustered 95% confidence interval lower bound above zero.

**Unspecified:** baseline identity, exact recall metric, clustering unit, cue generator, rounding/seed specifics, model schedule, sample-size/power rationale and resource budget.

[Methodology](methodology.md) · [Controls](baselines.md) · [Research hypotheses](../vision/hypotheses.md) · [Verification obligations](../verification/proof-obligations.md).
