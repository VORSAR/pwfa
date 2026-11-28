# Balancing the complementary pair in held training

On 2026-11-28 the owner selected option A, a paired test of training weights on the two existing development libraries. In each library the queried-bit oscillator had recovered all four cues for each of the complementary words and zero cues for either remaining word. An alternative was to draw four unrelated words while retaining equal episode weights. Testing weights on the same cues isolates the proposed explanation more directly. The choice covers this experiment. [Earlier per-word results](recall-with-queried-bit-hidden.md#results-at-t40) · [Baseline episode weighting](../decisions/ADR-124.md)

## Frozen comparison

For each library train on its same four held phase fields. Use equal episode weights of ¼ in the control. In the experimental arm assign ⅙ to each member of the complementary pair and ⅓ to each of the other two words. Reversing every prepared angle preserves signed alignment, so the two complementary words supply the same matrix. The new weights give each of the three distinct alignment patterns one third of the learned matrix. The four targets are scored separately. [Reflection check](../../scripts/experiments/pairwise-phase-statistic.lean) · [Episode mean check](../../scripts/experiments/episode-accumulation.lean)

Use the original 16 cues and four clean probes in each library. For both weightings run the same held-memory oscillator with structural strength zero, learned gain ¼ and zero learned lag. Apply both the sixteen-trajectory queried-bit readout and the one-trajectory ordinary control at time 40. Use the same encoder, decoder and steps 0.05 and 0.025. Only the scorer receives the target and corruption labels for each cue. [Retrieval protocol](recall-with-queried-bit-hidden.md#frozen-protocol) · [First library](first-recall/schedule.tsv) · [Second library](queried-bit-recall/replication/schedule.tsv)

The primary comparison is exact assembled words out of all 16 scheduled corrupted cues in each library, paired by cue ID and summarized separately for each of its four targets. Count gains and losses, coverage, flips repaired, missing bits filled, correct presented bits retained and clean probes. Check every output symbol under time-step refinement. Interpret improvement in words 3 and 4 alongside any loss in words 1 and 2. These two development rosters were used to select the question. The held-out benchmark remains open. [Scoring rule](../decisions/ADR-122.md) · [Mission criterion](../decisions/ADR-100.md)

## Bounded internal review

At revision `2412433`, Codex (GPT-6) reviewed this experimental slice under ADR-109. Independent Gate 1 remains open. The following findings were closed in the design before implementation. [Review policy](../decisions/ADR-109.md)

- **BW-01.** Identify the complementary words from the training library. Require exactly one complementary pair among four distinct binary words. Check that reordering words preserves the weighting and that libraries with zero or two pairs are rejected.
- **BW-02.** Preserve total learned strength. Check symmetry and unit diagonal and an off-diagonal entry with distinct known equal and rebalanced values. Use the same held training phases and the same integration and scoring paths in both arms.
- **BW-03.** Replay the equal-weight predictions against the archive and cross-check rebalanced predictions using a separate numerical implementation. Report abstentions as misses and keep the one- and sixteen-trajectory results distinct.

## Exact words at t=40

Each column for a stored word counts complete recoveries among its four corrupted cues. Words 1 and 2 form the complementary pair in both libraries. The primary readout assembles sixteen separate oscillator trajectories per cue. Every cue received a complete answer, so accuracy among answered cues equals accuracy among scheduled cues. [Frozen comparison](https://github.com/VORSAR/pwfa/commit/7a7cdba) · [Simulator revision](https://github.com/VORSAR/pwfa/commit/1e5925f)

| Development library | Training weights | Word 1 | Word 2 | Word 3 | Word 4 | All cues |
|---|---|---:|---:|---:|---:|---:|
| Original | Equal | 4/4 | 4/4 | 0/4 | 0/4 | 8/16 |
| Original | Rebalanced | 3/4 | 1/4 | 0/4 | 3/4 | 7/16 |
| Second | Equal | 4/4 | 4/4 | 0/4 | 0/4 | 8/16 |
| Second | Rebalanced | 2/4 | 2/4 | 4/4 | 2/4 | 10/16 |

On the original library rebalancing gained cues 010, 012 and 015 and lost 002, 004, 008 and 013. On the second library it gained 003, 004, 008, 012, 013 and 015 and lost 001, 007, 009 and 014. Four previously exact cues stayed exact on each library. Across the two rosters, rebalancing added nine exact recalls from outside the complementary pairs and lost eight from those pairs. The net gain of one word combines opposite changes in the two libraries. Both had already informed the choice of experiment.

### What happened to individual bits

| Library | Training weights | Initially correct bits retained | Flips corrected | Masks recovered | Exact clean probes |
|---|---|---:|---:|---:|---:|
| Original | Equal | 168/192 | 27/32 | 30/32 | 2/4 |
| Original | Rebalanced | 176/192 | 27/32 | 31/32 | 3/4 |
| Second | Equal | 173/192 | 31/32 | 29/32 | 4/4 |
| Second | Rebalanced | 185/192 | 32/32 | 31/32 | 4/4 |

On the original library the rebalanced model decoded nine more bits correctly, yet recovered one fewer complete word. It could reconstruct word 3 from a clean presentation one hidden position at a time, but missed all four corrupted cues for that word. On the second library it corrected every flip, and six cues still fell short of exact recall.

The ordinary one-trajectory control recovered 0/16 corrupted words and retained 4/4 clean words in each library under either weighting. It kept every presented bit, including all flips. With rebalancing it filled 31/32 omitted bits correctly on each roster. Its equal-weight counts were 30/32 and 29/32 respectively.

**Verification.** Every reported symbol, including every clean prediction, agreed across time steps. The equal-weight reruns reproduced the earlier prediction files byte for byte. A separate calculation applied each training word's phase features with explicit fractional coefficients and reproduced all 2,560 rebalanced output symbols across both libraries, time steps and readouts. The simulator's compile-time guards and `--check` control cover BW-01 and BW-02. They identify the complementary pair in either file order, reject libraries with zero or two pairs, and check symmetry, unit diagonal and a known off-diagonal entry under both weightings. On 2026-11-28 a complete rerun of both weightings at the simulator revision above regenerated the archived prediction files. From those files the Lean scorer reproduced the exact-word, coverage, mask, flip and clean-probe counts and the gained and lost cue IDs. A separate tally of the same files reproduced the per-target and retained-bit counts.

The test shows that the choice of weights affects *which* targets are recovered. It gives mixed evidence about improving whole-word accuracy across libraries. Both sixteen-trajectory arms have the same retrieval cost. Selecting a default and testing the project's matched-budget mission criterion require further evidence. [Baseline predictions](recall-with-queried-bit-hidden.md#results-at-t40) · [Rebalanced predictions, original library](complement-balanced-recall/original) · [Rebalanced predictions, second library](complement-balanced-recall/second) · [Mission benchmark](benchmarks.md)

## Reproduce the comparison

Build the [Lean simulator](../../scripts/experiments/first-trained-recall.lean) using the [native build commands](first-trained-recall.md#reproduce-the-measurement). The scorer exports the same visible cues to both conditions. Each prediction row records the cue ID, readout time and decoded symbols. The paired scoring command reports words gained and lost by ID.

```sh
for lib in docs/experiments/first-recall docs/experiments/queried-bit-recall/replication; do
  out="$run_dir/$(basename "$lib")"
  mkdir -p "$out"
  lean --run "$scorer" --export-cues "$lib/schedule.tsv" > "$out/cues.tsv"
  awk '{printf "word-%d\t%s\t................\n", NR, $0}' "$lib/words.txt" > "$out/clean.tsv"
  for r in 20 40; do
    "$run_dir/pilot" --compare-context "$r" "$lib/words.txt" "$out/cues.tsv" "$out/equal-$r"
    "$run_dir/pilot" --balanced-context "$r" "$lib/words.txt" "$out/cues.tsv" "$out/balanced-$r"
    for readout in direct context; do
      lean --run "$scorer" --compare-durations "$lib/schedule.tsv" \
        "$out/equal-$r/$readout.tsv" "$out/balanced-$r/$readout.tsv"
      lean --run "$scorer" "$out/clean.tsv" "$out/balanced-$r/$readout-clean.tsv"
    done
  done
done
```

The existing paired scorer labels its two inputs by training duration. In these commands the first input is equal-weight and the second is rebalanced; the held fields are constant throughout each episode.
