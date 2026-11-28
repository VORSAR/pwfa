# One retrieval run at the ±45° comparison alphabet

On 2026-11-28 the owner selected the first of three options for the next recall experiment: test whether bits can correct each other within a single retrieval run, using the ±45° alphabet that ADR-118 approved as a comparison. The other options were to give one run at ±90° more effective time by raising the learned gain, and to measure the present sixteen-run readout on every possible corruption. The question was put in multiple-choice form after its options had been evaluated in Lean. [Bit phases](../decisions/ADR-118.md) · [Question format](../decisions/ADR-130.md) · [Lean rule](../decisions/ADR-131.md)

At ±90° a presented bit receives nothing from the other symbols when the cue is released, and one run returned every presented bit unchanged, flips included. At ±45° two unlike presented bits pull on each other with half the difference of their symbols. The same alphabet stores no negative pair values and ties every bit to the background, so the bits may also settle onto the background together. The identities motivate the test. They do not predict its outcome. [Time-zero identities and review](../research/learned-retrieval-at-time-zero.md) · [Ordinary retrieval at ±90°](structural-coupling-at-retrieval.md#paired-results-at-t40)

## Frozen protocol

Use the two development libraries with their existing 16 corrupted cues and four clean probes each. Both libraries informed the choice of this experiment. [Original library](first-recall/schedule.tsv) · [Second library](queried-bit-recall/replication/schedule.tsv)

Run two arms. The **primary** arm uses ±90° and must reproduce the archived predictions. The **comparison** arm uses ±45° throughout. In each arm prepare training words, cues and clean probes with the arm's signed angle times the existing peak-one bump of radius 1/8, and give an omitted position no stimulus. Train one held matrix per arm from the four clamped prepared fields with equal episode weights of ¼. [Held training](held-word-training.md#protocol-fixed-before-running-the-held-arm) · [Episode weights](../decisions/ADR-124.md)

Retrieve with structural strength zero, learned gain ¼ and zero learned lag on the origin-aligned 16×8 grid. Release the cue at time zero, integrate with the existing midpoint step at 0.05 and again at 0.025, and decode at $t=40$ relative to the simultaneous origin with the existing dead band. Retrieval receives visible symbols only. [Encoder and integration settings](first-trained-recall.md#protocol-fixed-before-observing-predictions) · [Scoring rule](../decisions/ADR-122.md)

Apply two readouts in each arm. The **one-run readout** takes all sixteen symbols from a single trajectory and is the primary endpoint. The **hidden-bit readout** assembles sixteen trajectories, each with one position hidden, and is secondary. [Hidden-bit readout](recall-with-queried-bit-hidden.md#frozen-protocol)

The primary comparison is exact words of the one-run readout out of all 16 scheduled cues in each library, ±45° against ±90°, paired by cue ID. Report coverage, initially correct bits retained, flips corrected, omitted bits recovered, clean probes, per-target counts and agreement between the two step sizes. Count unresolved and failed answers as misses. Show the Hopfield and nearest-word references on the same cues. [Comparator](../decisions/ADR-133.md)

**Screen fixed in advance.** Call the comparison alphabet promising if its one-run readout recovers more exact words than the ±90° one-run readout on both libraries at both step sizes, with at least one gained cue ID per library common to both step sizes. If it is promising, replicate both one-run arms without tuning on one fresh development library. Generate that library as the earlier replication was generated, with Python Random seeds 129046 for words and 129047 for corruption and order, and freeze its inputs before running. Otherwise keep the negative result and leave those seeds unused. Make no change of angle, gain or readout time within this experiment after seeing results. The held-out benchmark stays untouched. [Earlier replication rule](recall-with-queried-bit-hidden.md#frozen-protocol)

## Bounded internal review

On 2026-11-28, against `80e7299`, the assistant, acting as internal reviewer, closed the following findings in the design before implementation. The review is internal and role-separated. No outside reviewer checked it, and independent Gate 1 remains open. [Review policy](../decisions/ADR-109.md) · [Reviewer identity](../decisions/ADR-132.md)

- **CA-01, what the comparison can show.** Moving from ±90° to ±45° changes the stimulus, the stored values and the readout margin together. Attribute any difference in recall to the alphabet as a whole. Do not present it as a measurement of the pair pull alone.
- **CA-02, one alphabet per arm.** Use the same angle for training words, cues and clean probes within an arm and train a separate matrix per arm. Check in the executable that a prepared cue still decodes at once at ±45°, that like and unlike centers store one and zero, that a center stores cos 45° with a background site, and that an isolated unlike pair pulls together at ±45° and not at all at ±90°.
- **CA-03, unchanged control.** Leave the default behaviour of every existing mode unchanged. Require the ±90° arm to reproduce the archived one-run and hidden-bit predictions byte for byte on both libraries at both step sizes.
- **CA-04, weak signals.** At ±45° the anchored signal may shrink toward zero. Keep the frozen dead band and count unresolved symbols as misses. Require every symbol to agree across step sizes before interpreting a result. Record the smallest absolute anchored score among the decoded positions of each arm, and cross-check every symbol with a separately written calculation.
- **CA-05, inputs and scoring.** Give retrieval the visible symbols only. Keep targets and corruption labels with the scorer. Count all scheduled cues and report the one-run and sixteen-run readouts separately.
- **CA-06, selection.** Both libraries have already informed this choice. Fix the screen and the fresh-library seeds before running, and treat every figure here as a development result.

This scope authorizes the comparison only. Selection of a default alphabet and any claim about the mission criterion need further evidence. [Mission criterion](../decisions/ADR-100.md)

## Results at t=40

**One run at ±45° did not correct presented bits.** On both libraries the one-run readout recovered 0/16 corrupted words, kept all 192 presented bits and corrected none of the 32 flips, exactly as at ±90°. The comparison alphabet did not meet the screen, so the fresh-library seeds stay unused. [Frozen protocol](https://github.com/VORSAR/pwfa/commit/92ae673) · [Simulator revision](https://github.com/VORSAR/pwfa/commit/dabb510)

| Library | Alphabet | Readout | Exact corrupted words | Initially correct bits retained | Flips corrected | Omitted bits recovered | Exact clean probes |
|---|---|---|---:|---:|---:|---:|---:|
| Original | ±90° | One run | 0/16 | 192/192 | 0/32 | 30/32 | 4/4 |
| Original | ±45° | One run | 0/16 | 192/192 | 0/32 | 30/32 | 4/4 |
| Original | ±90° | Hidden bit | 8/16 | 168/192 | 27/32 | 30/32 | 2/4 |
| Original | ±45° | Hidden bit | 8/16 | 168/192 | 27/32 | 30/32 | 2/4 |
| Second | ±90° | One run | 0/16 | 192/192 | 0/32 | 29/32 | 4/4 |
| Second | ±45° | One run | 0/16 | 192/192 | 0/32 | 27/32 | 4/4 |
| Second | ±90° | Hidden bit | 8/16 | 173/192 | 31/32 | 29/32 | 4/4 |
| Second | ±45° | Hidden bit | 8/16 | 177/192 | 32/32 | 27/32 | 2/4 |

The table uses step 0.05, and every symbol in it repeated at step 0.025. Every one-run answer was complete. The hidden-bit readout at ±45° left one symbol unresolved, position 2 of cue 008 on the second library, so its coverage there was 15/16. In both arms the hidden-bit readout recovered all four cues of each complementary word and none of the other eight on each library. No cue was gained or lost between the alphabets in either readout. On the same cues the Hopfield reference recovers 9/16 and 12/16 words and nearest-word lookup 16/16 and 16/16. [Primary-step predictions, original library](comparison-alphabet-recall/original/steps-20) · [Second library](comparison-alphabet-recall/second/steps-20) · [Static references](../research/learned-retrieval-at-time-zero.md#static-references-on-the-two-development-libraries)

**The signal shrinks at ±45°.** The weakest anchored score among all decoded one-run positions was 0.112 and 0.056 at ±90°. At ±45° it was 0.000107 and 0.000014, against a dead band of 0.000001. The ±45° answers therefore rest on signals about a hundred times the dead band on the original library and about fourteen times on the second. [Recorded scores](comparison-alphabet-recall/original/steps-20/weakest-score.txt)

### Diagnostic selected after the measurement

A separate calculation, not reproduced in Lean, looked at the anchored scores behind the one-run symbols. At ±45° a presented bit starts at ±0.707. At $t=40$ correctly presented bits averaged 0.0017 toward their target on the original library and 0.0016 on the second. Flipped bits averaged 0.0008 on the wrong side on both. At ±90° flipped bits stayed at 0.93 and 0.98 on the wrong side. So at ±45° the wrong bits lost ground about twice as fast as the right ones, which agrees with the pull between unlike bits that Lean identified. Every bit was also drawn onto the background, the whole pattern shrank by a factor of several hundred, and no flipped bit reached the correct side by the deadline. This diagnostic uses the frozen runs after their results were known. It selects nothing.

**Verification.** The ±90° arm reproduced the archived one-run and hidden-bit predictions byte for byte on both libraries at both step sizes. Every symbol in both arms agreed between the two step sizes. A separately written calculation, which applies each word's phase features and never forms the matrix, reproduced all 5,120 symbols of both arms and the four weakest scores. The Lean scorer reproduced the exact-word, coverage, flip and omitted-bit counts from the archived files, and a separate tally reproduced the retained-bit and per-target counts. The simulator's `--check` control covers CA-02. These are development results on two libraries that informed the choice of experiment. The held-out benchmark and independent Gate 1 remain open.

## Reproduce the comparison

Build the [Lean simulator](../../scripts/experiments/first-trained-recall.lean) with the [native build commands](first-trained-recall.md#reproduce-the-measurement). Each output directory holds one folder per arm with the two readouts, their clean probes and the weakest anchored score.

```sh
for lib in docs/experiments/first-recall docs/experiments/queried-bit-recall/replication; do
  out="$run_dir/$(basename "$lib")"
  mkdir -p "$out"
  lean --run "$scorer" --export-cues "$lib/schedule.tsv" > "$out/cues.tsv"
  awk '{printf "word-%d\t%s\t................\n", NR, $0}' "$lib/words.txt" > "$out/clean.tsv"
  for r in 20 40; do
    "$run_dir/pilot" --compare-alphabets "$r" "$lib/words.txt" "$out/cues.tsv" "$out/steps-$r"
    for readout in direct context; do
      lean --run "$scorer" --compare-durations "$lib/schedule.tsv" \
        "$out/steps-$r/primary/$readout.tsv" "$out/steps-$r/comparison/$readout.tsv"
      lean --run "$scorer" "$out/clean.tsv" "$out/steps-$r/comparison/$readout-clean.tsv"
    done
  done
  lean --run scripts/experiments/pair-memory-reference.lean --roster "$lib/words.txt" "$lib/schedule.tsv"
done
```

The paired scorer labels its two inputs by training duration. Here the first input is the ±90° arm and the second the ±45° arm.
