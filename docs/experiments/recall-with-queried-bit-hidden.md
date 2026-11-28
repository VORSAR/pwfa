# Recall with the queried bit hidden

On 2026-11-28 the owner selected a test motivated by the [error-correction literature review](../research/error-correction-and-recall.md#what-survives-to-the-readout). In ordinary held-memory retrieval with structural coupling off, every visible bit kept its original sign, including all 32 flips. The experiment asks whether the trained oscillator can predict a bit from the remaining cue when that bit supplies no stimulus. [Ordinary retrieval control](structural-coupling-at-retrieval.md#paired-results-at-t40)

## Frozen protocol

Train exactly the existing held matrix on the four clean words. Use the original origin-aligned 128-site grid, uniform starting background, ±90° encoder, learned gain ¼, zero learned lag and **zero structural strength at retrieval**. Release the cue at zero, decode at $t=40$ relative to the simultaneous origin and keep the existing dead band. Repeat at steps 0.05 and 0.025. Apply both readouts to the same 16 corrupted cues and four clean probes. [Encoder and integration settings](first-trained-recall.md#protocol-fixed-before-observing-predictions)

For the ordinary control, run one trajectory per cue. For the new readout, take the original visible cue afresh for each index $j$, mark position $j$ missing, and run the same oscillator with the same frozen memory. Use only its decoded bit $j$ and assemble the sixteen answers in the original bit order. When $j$ was already masked, its input is identical to the ordinary cue. A previously visible queried bit leaves thirteen visible inputs on a corrupted cue; an already masked query leaves fourteen. Use no raw-word lookup, corruption labels, target, or feedback from an earlier query in oscillator retrieval. Each clean probe now measures reconstruction when its queried bit is withheld.

Report exact corrupted words over all scheduled cues, coverage, correct bits by corruption type, clean probes and agreement under time-step refinement. The sixteen trajectories together produce one scored word. Count a failed trajectory as a failed assembled word and propagate an unresolved queried symbol as an abstention. The new method costs sixteen retrieval trajectories per cue plus the one-trajectory control. Accuracy and execution cost are separate outcomes. This experiment uses the existing development roster with known earlier results.

If the new method has strictly higher all-cue exact-word accuracy at both step sizes and gains at least one common cue ID at both, replicate both arms without tuning. For that one fresh development library, use independent Python Random seeds 129044 (words) and 129045 (corruption and order). Draw a 16-bit word, its complement, and two more distinct random 16-bit words; redraw duplicates only. Generate four cues per word using four positions sampled without replacement, the first two flipped and the next two masked. Shuffle rows before assigning three-digit cue IDs starting at 001. Freeze the inputs before running this replication. The mission-level matched-budget benchmark is separate.

## Bounded internal review

At `5b2bf1b`, Codex (GPT-6), acting as internal reviewer under ADR-109, closed the following findings for this experimental readout.

- **QB-01.** Hide the queried symbol before physical encoding, independent of its original value; preserve every other symbol, including other masks. Test a copy-only predictor, indexing including both ends, an already masked bit, a partial abstention, and failure propagation.
- **QB-02.** Reuse the same held matrix, velocity, integration, origin and decoder for both arms. Rerun the direct control and match its primary-library outputs to the archive. Cross-check the assembled predictions by independently evaluating the same continuous-phase equations numerically.
- **QB-03.** Keep retrieval inputs separate from the scoring schedule and count all 16 scheduled cues. Record the same-cue pairing, compute cost and conditional fresh-library criterion. Retain the ordinary single-trajectory result as the performance reference for this model.

## Original development library

The ordinary run recovered 0/16 corrupted words. The sixteen-query readout recovered **8/16**, with exactly the same eight gained cue IDs at both step sizes (002, 004, 005, 008, 009, 011, 013 and 014). It corrected 27/32 flips, filled 30/32 masks, and preserved 168/192 initially correct bits. All eight successes belonged to the first word and its complement. Both arms answered every cue. Every bit agreed under refinement and with a separate numerical implementation. The ordinary control also reproduced the published predictions. [Primary predictions](queried-bit-recall/primary/steps-20) · [Refined predictions](queried-bit-recall/primary/steps-40) · [Ordinary control](first-recall/steps-20/structural-off) · [Original schedule](first-recall/schedule.tsv)

This met the preset replication rule. The four fresh words and sixteen corruptions were generated using the seeds above and committed before fresh retrieval. [Fresh words](queried-bit-recall/replication/words.txt) · [Fresh scoring schedule](queried-bit-recall/replication/schedule.tsv)

## Results at t=40

The held-memory model recovered eight complete corrupted words on each development library when it inferred each bit separately. Every corrupted word received a complete answer. Coverage was 16/16 in every row, so answered-only accuracy equals all-cue accuracy. Every decoded symbol in the table agreed at steps 0.05 and 0.025.

| Library | Readout | Exact corrupted words | Correct presented bits retained | Flips corrected | Masks recovered | Exact clean probes |
|---|---|---:|---:|---:|---:|---:|
| Original | Ordinary | 0/16 | 192/192 | 0/32 | 30/32 | 4/4 |
| Original | Each queried bit hidden | 8/16 | 168/192 | 27/32 | 30/32 | 2/4 |
| Fresh | Ordinary | 0/16 | 192/192 | 0/32 | 29/32 | 4/4 |
| Fresh | Each queried bit hidden | 8/16 | 173/192 | 31/32 | 29/32 | 4/4 |

On the fresh roster the gained cue IDs were 001, 005, 006, 007, 009, 010, 014 and 016. Neither library lost an exact corrupted word relative to the ordinary control. At the positions already omitted from the original cue, the two arms received identical inputs and always returned the same bit. On a clean probe the ordinary arm measures retention with all bits supplied. The assembled arm reconstructs each queried bit from the other fifteen. [Frozen fresh inputs](https://github.com/VORSAR/pwfa/commit/9ab78cb) · [Fresh predictions](queried-bit-recall/replication/steps-20) · [Refined fresh predictions](queried-bit-recall/replication/steps-40)

**Which words benefited?** In each library the per-target exact counts, in file order, were **4/4, 4/4, 0/4, 0/4**. Words 1 and 2 are complements. On the fresh roster the model repaired 31 of 32 flips overall, yet it also changed 19 of the 192 originally correct bits into errors. Looking only at flip correction would miss those errors and the concentration of successes on two targets. The ordinary static nearest-word lookup identified all 16 targets from the visible cues on each roster. That lookup uses the raw stored words and provides a separate reference. [Lookup and original-library geometry](../research/error-correction-and-recall.md#what-the-four-pwfa-words-actually-allow) · [Fresh lookup output](queried-bit-recall/replication/visible-lookup.tsv)

Fresh cue 003 illustrates the cost of changing an initially correct position. The assembled output corrected both flips (positions 2 and 6) and filled both masks (1 and 3). It also changed position 8 from the correct 0 to 1. Its word `0110111101011001` therefore scored a miss against the target `0110111001011001`.

The held training rule gives each episode one quarter of the memory. The encoder reverses the sign of every prepared angle for a complemented word on this uniform background. Cosine of the pairwise angle difference is invariant under that reversal. The complementary pair therefore contributes the same alignment matrix twice, for a total weight of one half. Each of the other words contributes one quarter. Whether that weighting explains the distribution of exact recalls is an open experimental question. The subsequent [complement-balanced comparison](complement-balanced-training.md#exact-words-at-t40) changed those weights on both libraries and measured which targets were recovered. [Lean reflection check](../../scripts/experiments/pairwise-phase-statistic.lean) · [Lean equal-episode check](../../scripts/experiments/episode-accumulation.lean)

The assembled word uses **16 trajectories per cue**. Each trajectory contributes its answer only at its own hidden position. Across both libraries, resolutions and clean/corrupted probes this used 1,280 query trajectories plus 80 ordinary controls. For verification, a separately written numerical calculation applied the learned matrix through the sine and cosine features of the four words. It reproduced all 2,560 scored output symbols. The 100-library held-out benchmark, a matched-resource comparison and independent Gate 1 review remain open. [Benchmark and success criterion](benchmarks.md) · [Gate policy](../verification/review-gates.md)

## Reproduce the runs

Build the [Lean simulator](../../scripts/experiments/first-trained-recall.lean) using the [original native compile commands](first-trained-recall.md#reproduce-the-measurement). Set `data` to the selected library directory containing the words and schedule. The scorer prepares the visible cues. Only it receives the corruption labels.

```sh
lean --run "$scorer" --export-cues "$data/schedule.tsv" > "$run_dir/cues.tsv"
"$run_dir/pilot" --visible-lookup "$data/words.txt" "$run_dir/cues.tsv" > "$run_dir/visible-lookup.tsv"
awk '{printf "word-%d\t%s\t................\n", NR, $0}' "$data/words.txt" > "$run_dir/clean-schedule.tsv"
for resolution in 20 40; do
  out="$run_dir/context-$resolution"
  "$run_dir/pilot" --compare-context "$resolution" "$data/words.txt" "$run_dir/cues.tsv" "$out"
  for arm in direct context; do
    lean --run "$scorer" "$data/schedule.tsv" "$out/$arm.tsv"
    lean --run "$scorer" "$run_dir/clean-schedule.tsv" "$out/$arm-clean.tsv"
  done
done
```
