# Held versus freely evolving training words

The owner requested this comparison on 2026-11-27 after freely evolving training recovered 0/16 corrupted cues and retained 0/4 clean words at retrieval time 40. The question is whether preserving the presented word throughout training improves exact-word recall with the same retrieval dynamics. The experiment uses the existing development library. [Original protocol and results](first-trained-recall.md) · [Whole-word endpoint](../decisions/ADR-122.md)

## Protocol fixed before running the held arm

For each of the four clean training words, prepare the same 128 oscillator phases as in the original experiment. In the **free** arm, release the word at the start of its episode and average the signed pair alignments as the oscillators evolve. In the **held** arm, clamp the entire prepared spatial phase field, including the background, through the full episode. The time mean of each pair's constant alignment equals its initial value for any positive episode duration. Give the four word means equal weight. A single held matrix therefore supplies both the 25- and 50-unit comparisons. [Exact time-mean check](../../scripts/experiments/training-window-mean.lean) · [Episode weighting](../decisions/ADR-124.md) · [Training durations](../decisions/ADR-127.md)

At retrieval, release the cue at zero and evolve to $t=40$ with structural coupling on, its original lag and strength, learned gain $1/4$, and zero learned lag. Use the frozen 16 corrupted cues and the same four clean retention probes. Repeat at steps 0.05 and 0.025. Pair by cue ID within each duration and step. The primary endpoint is exact words over all 16 scheduled cues. Report clean-word retention over four words, coverage, correct bits by corruption type, and any changed predictions under step refinement. The held arm contributes one observation per cue and step size. [Frozen roster](first-recall/schedule.tsv) · [Retrieval field](../decisions/ADR-128.md) · [Learned lag](../decisions/ADR-129.md)

## Internal review

At `1657d8e`, Codex (GPT-6), the author in the internal reviewer role, closed these findings for this experimental comparison under ADR-109.

- **HT-01.** Clamp all prepared sites throughout training. Use the existing complex dot-product accumulator on each prepared word, divide the sum by four, and check the resulting symmetry, diagonal and signed cross-site values. Repeating a frozen snapshot at every midpoint would merely repeat the same training statistic.
- **HT-02.** Use the same encoder, structural kernel, learned gain, retrieval integrator and origin-relative decoder for both arms. Rerun the free-arm predictions and compare them with the original archive. Direct only visible corrupted symbols or a designated clean probe to retrieval.
- **HT-03.** Preserve per-cue outputs at both time steps. Count incomplete or missing responses in their scheduled denominator. Report bit changes separately from exact recall and distinguish four clean probes from the sixteen damaged cues.

This scope authorizes the controlled comparison. Selection of a permanent training rule and evaluation on untouched libraries remain open. [Experimental review policy](../decisions/ADR-109.md)

## Results at retrieval time 40

Holding the four training words fixed gave **0/16 exact corrupted-cue recoveries** and **0/4 exact clean-word retentions**. Both freely evolving training durations gave the same exact-word counts. All scheduled probes returned complete predictions in every arm at both step sizes. The paired difference in exact recall was zero percentage points at each duration. [Frozen protocol revision](https://github.com/VORSAR/pwfa/commit/225fb0b) · [Simulator revision](https://github.com/VORSAR/pwfa/commit/3d25132)

| Training, step 0.05 | Exact corrupted cues | Exact clean probes | Initially correct bits retained on corrupted cues | Masked bits recovered | Flips corrected | Total correct on corrupted cues | Correct bits on clean probes |
|---|---:|---:|---:|---:|---:|---:|---:|
| Free, 25 units | 0/16 | 0/4 | 99/192 | 17/32 | 14/32 | 130/256 | 32/64 |
| Free, 50 units | 0/16 | 0/4 | 93/192 | 18/32 | 16/32 | 127/256 | 37/64 |
| Held, either duration | 0/16 | 0/4 | 107/192 | 17/32 | 17/32 | 141/256 | 35/64 |

The largest bit-count difference came from retaining more of the initially correct positions in the corrupted cues. Held training completely recovered none of the four clean words, even with the clean target supplied at the start of retrieval. The evidence supports testing the retrieval dynamics next. This one library gives no whole-word accuracy basis for choosing a permanent training rule. [Corrupted-cue predictions](first-recall/steps-20/held.tsv) · [Clean predictions](first-recall/steps-20/held-clean.tsv) · [Free-arm results](first-trained-recall.md#measured-exact-recall)

**Step refinement.** At step 0.025 every held prediction on the 16 corrupted cues repeated exactly. On the clean probes, the first bit of word 3 changed and the held score became 34/64. The free arms gave 129/256 and 129/256 correct bits respectively on the corrupted cues and again 32/64 and 37/64 on the clean probes. All exact-word counts stayed at zero. [Refined corrupted-cue predictions](first-recall/steps-40/held.tsv) · [Refined clean predictions](first-recall/steps-40/held-clean.tsv)

**Verification.** The free training rerun reproduced every archived prediction in both step sizes, including the disabled-learning controls. The held matrix passed checks for finite signed entries, symmetry and unit diagonal. On a four-word fixture the Lean executable also checked positive, negative and zero cross-site entries and a site on the shoulder of an encoder bump. A separate calculation formed the matrix directly from cosines of angle differences and evolved complex unit phases; its decoded symbols agreed with all 640 held-arm bit outputs across the two step sizes. These checks verify the implementation against the stated experimental protocol. Independent Gate 1 remains open.

## Reproduce the comparison

The subsequent [retrieval comparison](structural-coupling-at-retrieval.md#paired-results-at-t40) tested each of these same memories with structural coupling on and off.

Use the [original build and free-run commands](first-trained-recall.md#reproduce-the-measurement) with the current simulator. In the same shell, run the held arm on the identical exported cues. The clean schedule below contains one row per stored word, with every position marked clean. Each prediction file has the usual ID, endpoint and decoded symbols.

```sh
awk '{printf "word-%d\t%s\t................\n", NR, $0}' "$data/words.txt" > "$run_dir/clean-schedule.tsv"
for resolution in 20 40; do
  out="$run_dir/held-$resolution"
  "$run_dir/pilot" --held "$resolution" "$data/words.txt" "$run_dir/cues.tsv" "$out"
  lean --run "$scorer" "$data/schedule.tsv" "$out/held.tsv"
  lean --run "$scorer" "$run_dir/clean-schedule.tsv" "$out/held-clean.tsv"
done
```
