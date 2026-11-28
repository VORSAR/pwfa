# Structural coupling during retrieval

On 2026-11-27 the owner selected a paired test of structural coupling during retrieval. With this coupling active, the free 25-unit, free 50-unit and held training conditions each recovered 0/16 corrupted cues and retained 0/4 clean words. Measure what happens when only the structural contribution to the retrieval velocity is removed. [Training comparison](held-word-training.md#results-at-retrieval-time-40) · [Whole-word accuracy criterion](../decisions/ADR-122.md)

## Protocol fixed before the comparison

Regenerate each learned matrix from the existing four training words. Free training uses the original structural dynamics for its entire 25- or 50-unit window. Held training uses the mean alignment of the four clamped initial fields, shared by both durations. For each matrix, construct two retrieval operators from that same in-memory matrix at learned gain $1/4$, zero learned lag and cell area $1/128$. Set the structural weights to the original normalized smooth row in one operator and to zero in the other. [Learned field](../decisions/ADR-128.md) · [Learned lag](../decisions/ADR-129.md) · [Original settings](first-trained-recall.md#protocol-fixed-before-observing-predictions)

Release each of the original 16 visible corrupted cues and four clean probes at time zero. Read relative to the simultaneous origin at $t=40$ with the existing threshold. Use step 0.05 and repeat at 0.025. The primary comparison for each matrix is the difference in exact-word recovery over the 16 scheduled corrupted cues. Report complete predictions, clean retention, masked and flipped recovery, and step sensitivity. Report any gains or losses by cue ID. This development experiment follows inspection of the same library; generalization requires untouched libraries.

## Internal review

Against `c07c2f3`, Codex (GPT-6), author in the internal reviewer role, closed the following findings for the experiment under ADR-109.

- **SR-01.** Build each matrix once per resolution and pass that matrix to both retrieval operators. Keep structural coupling active in free training, preserve the learned coefficient and preserve the decoder and clock. Match every structural-on prediction to its earlier archive.
- **SR-02.** Check that removing the structural term preserves signed learned torque and that the on-minus-off instantaneous velocity matches the structural contribution. As a control with intrinsic frequency and both gains zero, the prepared cue is stationary. A clean word can then persist without error correction; recovery of flipped and masked bits is essential to interpret any gain.
- **SR-03.** Pair every scheduled cue and clean probe by ID, preserving unresolved predictions. Report the two step sizes and check the structural-off outputs using the complex equation. Keep the disabled structural interaction distinct in the filenames from the original disabled learned interaction.

This review authorizes the comparison only. The results will inform the choice of retrieval dynamics. [Experimental review policy](../decisions/ADR-109.md)

## Paired results at t=40

**Exact recovery of corrupted cues was 0/16 in every condition.** The structural-off arm retained all four clean words for every matrix, up from 0/4 with structural coupling on. On the corrupted cues it retained all 192 initially correct bits and corrected zero of the 32 flips. Thus every visible input bit kept its presented sign, including the two wrong bits in each cue. Held training recovered 30/32 masked bits under structural-off retrieval, compared with 22/32 for each free training duration. [Frozen protocol](https://github.com/VORSAR/pwfa/commit/e94aa8c) · [Lean simulator revision](https://github.com/VORSAR/pwfa/commit/9781153)

| Training memory | Structural retrieval | Exact corrupted words | Exact clean words | Initially correct bits retained | Masked bits recovered | Flips corrected |
|---|---|---:|---:|---:|---:|---:|
| Free, 25 units | On | 0/16 | 0/4 | 99/192 | 17/32 | 14/32 |
| Free, 25 units | Off | 0/16 | 4/4 | 192/192 | 22/32 | 0/32 |
| Free, 50 units | On | 0/16 | 0/4 | 93/192 | 18/32 | 16/32 |
| Free, 50 units | Off | 0/16 | 4/4 | 192/192 | 22/32 | 0/32 |
| Held, either duration | On | 0/16 | 0/4 | 107/192 | 17/32 | 17/32 |
| Held, either duration | Off | 0/16 | 4/4 | 192/192 | 30/32 | 0/32 |

The table uses step 0.05. Every condition returned 16/16 complete corrupted-cue predictions and 4/4 complete clean predictions. In each paired comparison the same four clean probe IDs (`word-1` through `word-4`) gained exact retention when structural coupling was removed. No corrupted cue gained or lost an exact match. At step 0.025 all structural-off predictions repeated bit for bit and all structural-on predictions reproduced the previous archive at that step. [Structural-off predictions, step 0.05](first-recall/steps-20/structural-off) · [Structural-off predictions, step 0.025](first-recall/steps-40/structural-off) · [Earlier structural-on results and refinement details](held-word-training.md#results-at-retrieval-time-40)

The held, structural-off combination preserved the cue wherever a bit was presented and filled 30 of 32 omissions correctly on this one library. At zero intrinsic frequency an interaction-free trajectory would retain the input too, but an omitted bit starts with zero anchored score and would abstain on a stationary cue. Issuing definite answers to the masks here required evolution. Correcting wrong visible bits while retaining the correct ones is the remaining obstacle on these cues.

**Verification.** The Lean scorer checked all 24 prediction files (three matrices, two retrieval arms, two step sizes, clean and corrupted inputs). A separate complex-matrix calculation agreed with all 1,920 structural-off bit outputs. The executable checks the signed learned pair torque, additivity of the two contributions and stationarity when both are removed. This single previously inspected development library supplies no matched-budget or held-out performance estimate.

## Follow-up protocol for intermediate strengths

On 2026-11-27 the owner selected a sweep at $s=1/4,1/2,3/4$ after inspecting the strength-zero and strength-one results above. Use held training with the same four clean words, all 16 corrupted cues, the four clean probes and both time steps. The retrieval velocity is $s$ times the original structural contribution plus the full zero-lag learned contribution at gain $1/4$. The multiplier applies after structural row normalization. Reuse the same held matrix at every strength. Retain the previous zero and one as reference arms. [Held memory](held-word-training.md#protocol-fixed-before-running-the-held-arm)

At `e88ad09`, Codex (GPT-6) in the internal reviewer role closed two findings under ADR-109. **IS-01.** Check at each intermediate strength that the instantaneous phase velocity equals the learned-only velocity plus the specified fraction of the structural velocity; renormalizing the scaled row would erase the intervention. Match the strength-zero and strength-one outputs to the prior archives. **IS-02.** Report exact words, complete answers, masked, flipped and initially correct positions, clean retention and refinement differences for every strength. Score all cues against their original targets. Archive the three new arms regardless of outcome.

For the development screen, call a strength promising if at least one *same* corrupted cue is exact at both time steps. Replicate every such strength on one fresh development library alongside zero and one. Use the original four-word generation and disjoint two-flip/two-mask procedure with word seed 129042 and corruption seed 129043. Keep the held-out mission benchmark untouched. If no strength passes the screen, retain the negative result and leave those seeds unused. This rule prioritizes reproducible whole-word recovery over bit-level changes.

## Intermediate strength results

With held training and fixed learned gain $1/4$, structural strengths **¼, ½ and ¾ each recovered 0/16 complete corrupted words at $t=40$**, at both time steps. Every trial returned a complete answer. Each intermediate strength retained one of the four clean words. There was no gain in paired exact corrupted-word recall against either endpoint. [Frozen screen](https://github.com/VORSAR/pwfa/commit/1a85dad) · [Simulator revision](https://github.com/VORSAR/pwfa/commit/d6bd5be)

| Structural strength, step 0.05 | Exact corrupted words | Exact clean words | Initially correct bits retained | Flips corrected | Masked bits recovered |
|---|---:|---:|---:|---:|---:|
| 0 | 0/16 | 4/4 | 192/192 | 0/32 | 30/32 |
| ¼ | 0/16 | 1/4 | 163/192 | 16/32 | 18/32 |
| ½ | 0/16 | 1/4 | 152/192 | 17/32 | 18/32 |
| ¾ | 0/16 | 1/4 | 119/192 | 17/32 | 20/32 |
| 1 | 0/16 | 0/4 | 107/192 | 17/32 | 17/32 |

At quarter strength the model corrected both flips in five cues. Two of those cues, `004` and `010`, finished one bit short of the target; in both cases the remaining error was a masked position. Across the roster, quarter strength also lost 29 previously correct bits. The sole exact clean probe was `word-2` at ¼ and ¾ and `word-3` at ½. These secondary observations describe this development set. [Primary-step predictions](first-recall/steps-20/held-strengths)

At step 0.025 the ¼ and ½ predictions repeated exactly. At ¾ one initially correct bit changed from wrong to correct, increasing retention to 120/192. All masked-bit, flip and exact-word counts repeated. The zero and one controls reproduced their archived outputs at each step. The alternative complex-matrix calculation agreed with all 1,920 new decoded symbols. No setting met the prespecified screen for fresh-library replication. The planned replication seeds remain unused. [Refined predictions](first-recall/steps-40/held-strengths)

## Reproduce the comparison

The [error-correction review](../research/error-correction-and-recall.md#what-survives-to-the-readout) checks whether the intended word was still the nearest stored word to each archived output and distinguishes this diagnostic from the primary exact-word score.

Build the current [Lean simulator](../../scripts/experiments/first-trained-recall.lean) and export the visible cues using the [original commands](first-trained-recall.md#reproduce-the-measurement). In that shell, run the following. Each output directory contains corrupted and clean predictions for each matrix. The outer loop reruns both training and retrieval at the stated resolution.

```sh
awk '{printf "word-%d\t%s\t................\n", NR, $0}' "$data/words.txt" > "$run_dir/clean-schedule.tsv"
for resolution in 20 40; do
  out="$run_dir/retrieval-$resolution"
  "$run_dir/pilot" --compare-structure "$resolution" "$data/words.txt" "$run_dir/cues.tsv" "$out"
  for arm in structural-on structural-off; do
    for memory in free-25 free-50 held; do
      lean --run "$scorer" "$data/schedule.tsv" "$out/$arm/$memory.tsv"
      lean --run "$scorer" "$run_dir/clean-schedule.tsv" "$out/$arm/$memory-clean.tsv"
    done
  done
done
```

For the held-training strength sweep, use the same binary, training words, cues and schedules.

```sh
for resolution in 20 40; do
  out="$run_dir/strengths-$resolution"
  "$run_dir/pilot" --held-strengths "$resolution" "$data/words.txt" "$run_dir/cues.tsv" "$out"
  for strength in zero quarter half three-quarters one; do
    lean --run "$scorer" "$data/schedule.tsv" "$out/$strength/held.tsv"
    lean --run "$scorer" "$run_dir/clean-schedule.tsv" "$out/$strength/held-clean.tsv"
  done
done
```
