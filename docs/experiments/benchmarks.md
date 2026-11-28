# Exact-recall benchmark

**Status.** In the latest development experiment the ordinary held-memory control recovered 0/16 whole words on each of two libraries. Predicting each bit on its own trajectory recovered 8/16 on each. Rebalancing the training weights of the complementary pair gave 7/16 and 10/16 on those libraries and changed which targets were recovered. The 100-library held-out benchmark and matched-comparator comparison are pending. [First trained run](first-trained-recall.md#measured-exact-recall) · [Queried-bit experiment and cost](recall-with-queried-bit-hidden.md#results-at-t40) · [Complement-balanced comparison](complement-balanced-training.md#exact-words-at-t40)

The [paired structural retrieval experiment](structural-coupling-at-retrieval.md#paired-results-at-t40) reports full-word recovery, clean retention and flipped versus masked recovery for both free and held training.

The subsequent [held-training strength sweep](structural-coupling-at-retrieval.md#intermediate-strength-results) measures how intermediate structural weights affect those same endpoints.

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

The [first development experiment](first-trained-recall.md) trains a dense pair matrix from evolving phases and measures recall at $t=40$ with a fixed gain, a provisional cue transition and a point decoder. The adaptive model still needs scalar and homeostat dynamics, training events, and a finalized decoder. [Memory contract](../mathematics/memory.md) · [Training protocol](methodology.md) · [Decoder](../mathematics/encoding-decoding.md)

For the paired duration pilot, use 25 and 50 model time units per stored word on the same development libraries and cue roster. The retrieval endpoint is $t=40$ for both conditions. [Training durations](../decisions/ADR-127.md)

For an encoder-radius comparison, use the same target libraries, training order, corrupted cues, and other settings for each candidate width, and apply each width consistently in training and recall. Record the number of exact words and total cues, plus masked-bit recovery and flipped-bit correction so a whole-word miss can be interpreted. Count every scheduled cue in its condition and record ties and failed runs. Specify the aggregation rule across libraries before collecting results. If pilot results guide the choice of width, evaluate the frozen choice on untouched benchmark data. The external comparator and matched budget are needed to test the performance advantage below. A first measurement of PWFA's own recall rate can proceed once its recall path is defined.

[ADR-100](../decisions/ADR-100.md) specifies a **target**, not a result: at least five percentage points exact-recall advantage over a preregistered matched-budget comparator, with clustered 95% confidence interval lower bound above zero.

The [scoring experiment](../research/recall-pilot-checks.md#counting-exact-words) exercises exact matches, flips, masks, abstentions, missing runs, and both candidate denominators on artificial outputs. The owner selected exact matches divided by all scheduled cues as primary. Report coverage and accuracy among fully answered cues alongside it, with raw counts and undefined rates for zero denominators. The decoder confidence threshold remains open. [Counting decision](../decisions/ADR-122.md)

### Score a recall export

From the repository root, score one library and one experimental condition per invocation. Both inputs are tab-separated text with no header. Make the schedule before retrieval and keep the target and corruption labels on the evaluation side.

```sh
lean --run scripts/experiments/recall-scoring.lean schedule.tsv predictions.tsv
```

| File | Columns in order |
|---|---|
| Schedule | Unique cue ID, original 16-bit word, 16 corruption labels (`.` unchanged, `F` flipped, `M` masked). |
| Predictions | Cue ID, endpoint label `40`, 16 decoded symbols (`0`, `1`, or `?` for abstention). Use `FAILED` in the last column to report a failed run. |

IDs join the files regardless of row order. An absent scheduled ID counts as missing. A word with any unresolved bit counts as an abstention. The output reports the three ADR-122 fractions with integer counts, failed and missing cues separately, and correctly decoded masked/flipped bits over the corresponding scheduled positions. A missing prediction earns zero correct bits. An empty input group has undefined rates where the denominator is zero. Duplicate IDs, unscheduled predictions, malformed records, and an endpoint other than `40` produce an error. The simulator must supply the actual readout from that time. [Checked command and synthetic example](../research/recall-pilot-checks.md#scoring-command-check)

To prepare the identical retrieval inputs for both duration arms, export one visible-cue file on the evaluator’s side. Use distinct paths for the schedule and output.

```sh
lean --run scripts/experiments/recall-scoring.lean --export-cues schedule.tsv > cues.tsv
```

Each output row contains an opaque cue ID and 16 presented symbols. A flip presents the opposite bit. A mask produces `?` and the encoder omits that stimulus. Give the encoder only the symbols. Choose target-independent IDs, use them to match results, and keep the targets and corruption labels with the evaluator. Rows are sorted by ID for reproducible exports. This file order carries no scheduling semantics. [Cue export checks](../research/recall-pilot-checks.md#visible-cue-export)

Before running a development library, the evaluator can check whether different target words appear under identical presented cues.

```sh
lean --run scripts/experiments/recall-scoring.lean --cue-ambiguity schedule.tsv
```

The report counts distinct visible cues, visible cues paired with multiple targets, and the largest possible exact-word count for a deterministic predictor on that roster. It assumes a fixed library, background, initial retrieval state and other inputs. Apply it separately within each such condition. Keep all scheduled rows in the pilot, including collisions. The ceiling uses target frequencies and belongs on the evaluation side. A ceiling of 100% simply means each distinct cue in that roster has one target. [Proof and worked example](../research/recall-pilot-checks.md#identical-cues-with-different-targets)

For the two duration conditions in one development library, pass one common roster and the two exports in training-duration order. Each export has the same three columns as above, including the retrieval endpoint label `40`.

```sh
lean --run scripts/experiments/recall-scoring.lean --compare-durations schedule.tsv predictions25.tsv predictions50.tsv
```

The command shows both individual reports and counts cues recovered in both conditions, only at 25, only at 50, and in neither. It lists cue IDs recovered in just one condition and gives the signed all-cue rate difference, 50 minus 25. Failed or missing predictions stay in the common denominator. The experiment runner must record the actual training conditions and pair the underlying libraries, seeds, and cues. [Paired scoring check](../research/recall-pilot-checks.md#paired-command-check)

**Unspecified:** baseline identity, across-library aggregation, clustering unit, cue generator, rounding/seed specifics, model schedule, sample-size/power rationale and resource budget.

[Methodology](methodology.md) · [Controls](baselines.md) · [Research hypotheses](../vision/hypotheses.md) · [Verification obligations](../verification/proof-obligations.md).
