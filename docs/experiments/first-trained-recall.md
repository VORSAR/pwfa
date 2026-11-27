# First trained recall development run

The endpoint is the number of complete 16-bit target words recovered at retrieval time 40, divided by all 16 scheduled cues. This first development library tests whether turning on a genuinely trained pair matrix helps under one explicit set of assumptions. The mission benchmark targets a five-percentage-point advantage on independent libraries over a matched comparator. [Benchmark](benchmarks.md) · [Mission criterion](../decisions/ADR-100.md)

## Protocol fixed before observing predictions

Use the [four training words](first-recall/words.txt) in file order and the [frozen evaluation schedule](first-recall/schedule.tsv). The second word complements the first as required by ADR-123. The remaining words were drawn without inspecting the model. Four different cues per word each flip two positions and mask two other positions, a per-cue rounding of 1.6 to 2. Shuffle the 16 rows before assigning opaque IDs. Python’s Random with seed 129040 supplied 16-bit words, and seed 129041 supplied four positions sampled without replacement per cue and the shuffle. The files fix the exact inputs. Only the evaluation command reads target and corruption columns. [Signed training input](../decisions/ADR-123.md) · [All-cue denominator](../decisions/ADR-122.md)

Use the approved origin-aligned 16×8 periodic grid and primary ±90° mapping. For this development control, number bits across x first, then y, in the 4×4 tiling. Prepare a uniform zero-angle field, adding the signed bit angle times the peak-one smooth bump of radius 1/8 at each presented center. Omit masked positions. Start each word and cue afresh with this instantaneous presentation, release it at time zero, and evolve freely. [Geometry](../decisions/ADR-115.md) · [Width checks](../research/bit-to-phase-map.md#internal-review-of-the-provisional-18-stimulus-width)

Use the smooth structural kernel at radius 1/4, normalized by its sampled row mass, with structural strength one, lag π/2−0.1 and intrinsic frequency zero. This is one of the approved structural arms. In training, evolve each clean prepared word with structural coupling alone. At every midpoint accumulate the dense matrix of signed pair alignments. Average over all steps in each word and equally over the four words. Train separate matrices for 25 and 50 time units per word. At retrieval freeze the respective matrix and apply the dense 1/128 mean with learned lag zero and a constant gain of 1/4. Holding the scalar gain fixed isolates pairwise learning for this first run. The adaptive scalar and homeostat, alternate radii, and stimulus variants belong to later comparisons. [Training mean](../decisions/ADR-125.md) · [Durations](../decisions/ADR-127.md) · [Learned field](../decisions/ADR-128.md) · [Learned lag](../decisions/ADR-129.md)

Use explicit midpoint in angle coordinates, equivalent to rotating the unit phase by the midpoint angular increment. Run at step 0.05 and repeat at 0.025. At time 40, sample each bit center relative to the simultaneous origin, taking the sign of the sine of their angle difference. Abstain at absolute score ≤0.000001. This provisional dead band is fixed before scoring. Count every missing, failed or abstaining cue in the primary denominator. Report flipped and masked recovery. Compare individual predictions across refinements. Report any changed symbols before interpreting close accuracy differences. [Numerics](../mathematics/numerical-methods.md) · [Readout](../mathematics/encoding-decoding.md)

Run the same cues with learned gain zero at each step size. The disabled calculation has identical equations for both training durations and can be shared. It measures the contribution of the learned interaction under this protocol. A matched external comparator and untouched multi-library evaluation are required for the mission-level claim. The provisional choices in this development run have no standing as permanent architecture decisions.

## Internal review and scope

On 2026-11-27, against `b9006f7`, Codex (GPT-6), the author in the internal reviewer role, closed the following findings for an experimental development measurement under ADR-109.

- **RUN-01, input leakage.** Separate training words, visible cues, and evaluator data. Confirm each bit center and origin on the grid, and the exact prepared signs, masks and anchor. Retrieval receives only visible symbols and a frozen trained matrix.
- **RUN-02, dynamics.** Check synchronized structural speed and the sign and area factor of a learned pair torque. Verify memory symmetry, unit diagonal and finite entries before use. Count the exact steps to each event. Use actual evolving midpoint phase snapshots for the learned matrix.
- **RUN-03, measurement.** Keep both duration arms and the learned-off control on identical cues. Preserve raw per-cue predictions at both step sizes, check with the existing Lean scorer, and disclose any refinement disagreement. Inputs and settings are frozen in Git before implementation and collection. The first library supplies a development result. Independent Gate 1 and benchmark certification remain open.

The scope covers this one diagnostic experiment and its reproducibility checks. [Experimental authorization policy](../decisions/ADR-109.md)

## Measured exact recall

On the frozen roster at `301439d`, the Lean simulator at `6c25f7c` produced the following counts at $t=40$ and step 0.05. All 16 scheduled cues in each condition returned complete words. The evaluator found 16 distinct visible cues.

| Retrieval condition | Exact words | Correct initially clean bits | Correct masked bits | Correct flipped bits |
|---|---:|---:|---:|---:|
| 25 units per word | 0/16 | 99/192 | 17/32 | 14/32 |
| 50 units per word | 0/16 | 93/192 | 18/32 | 16/32 |
| Learned interaction off | 0/16 | 99/192 | 17/32 | 17/32 |

Halving the step to 0.025 preserved all three exact-word counts and all masked and flipped counts. It changed one decoded symbol in the 25-unit run and two in the 50-unit run. All three changes were at initially clean positions. The disabled arm gave identical symbols in both runs. The learned interaction therefore showed zero percentage-point improvement in exact-word recall over the disabled control on this development library. [Predictions at step 0.05](first-recall/steps-20) · [Predictions at step 0.025](first-recall/steps-40)

### Diagnostics selected after the measurement

The first runs lost roughly half of the 192 bits that were supplied correctly. At `6c25f7c`, the author in the internal reviewer role scoped two checks to distinguish loss during retrieval from ambiguity in the corrupted inputs.

- **DI-01, closed for experiment.** Present the four clean stored words separately using the identical trained simulator, gain, clock and decoder. Count unique words once and report both time steps. The diagnostic reuses training words intentionally to test retention at $t=40$.
- **DI-02, closed for experiment.** Compare each corrupted cue to all four stored words by counting mismatches on visible positions only. Treat ties as abstentions. Join target-free predictions to the existing schedule for scoring only after inference. This diagnostic measures information in the presented cue and library. It has no time evolution or resource match.

These checks use the original library after seeing its primary results. They do not select a decoder, revise the first-run result, or test the matched-comparator mission criterion.

### Diagnostic results

**Clean retention.** The decoder correctly reads each of the four clean words immediately after preparation. After evolution to $t=40$ it retained **0/4 whole clean words** for each training duration and with learning disabled. At step 0.05, 25-unit training returned 32/64 clean bits correctly, 50-unit training returned 37/64, and the disabled interaction returned 20/64. These counts repeated at step 0.025. A separate complex-matrix calculation during verification reproduced every archived decoded bit for both the clean and corrupted inputs at each step size. [Clean predictions](first-recall/clean-retention.tsv)

**Information in the corrupted cues.** A static lookup that chooses the stored word with fewest mismatches on visible positions identified **16/16** targets with no ties. It had access to the four stored words. It read the presented bits and the locations of the omissions. It received neither the targets nor the identities of flipped bits for each cue. On this library the corruptions left enough information for exact retrieval. The next accuracy experiment should distinguish loss of the pattern during free training from loss during retrieval under structural coupling. [Lookup outputs](first-recall/visible-lookup.tsv)

The subsequent [held versus free training experiment](held-word-training.md#results-at-retrieval-time-40) tested full-episode clamping with the retrieval dynamics specified here.

## Reproduce the measurement

From the repository root, use the pinned Lean compiler to build the [simulator](../../scripts/experiments/first-trained-recall.lean) in a temporary directory. The schedule enters the evaluator; the simulator receives the same exported cues for all arms. Each output contains one decoded word per cue in the [scorer’s format](benchmarks.md#score-a-recall-export).

```sh
run_dir=$(mktemp -d)
data=docs/experiments/first-recall
scorer=scripts/experiments/recall-scoring.lean
lean -c "$run_dir/pilot.c" scripts/experiments/first-trained-recall.lean
leanc -O3 -o "$run_dir/pilot" "$run_dir/pilot.c"
"$run_dir/pilot" --check
lean --run "$scorer" --export-cues "$data/schedule.tsv" > "$run_dir/cues.tsv"
for resolution in 20 40; do
  out="$run_dir/steps-$resolution"
  "$run_dir/pilot" "$resolution" "$data/words.txt" "$run_dir/cues.tsv" "$out"
  lean --run "$scorer" --compare-durations "$data/schedule.tsv" "$out/trained-25.tsv" "$out/trained-50.tsv"
  lean --run "$scorer" "$data/schedule.tsv" "$out/off.tsv"
done
```

To reproduce the post-measurement diagnostics using the same binary and files, run:

```sh
"$run_dir/pilot" --visible-lookup "$data/words.txt" "$run_dir/cues.tsv"
for resolution in 20 40; do
  "$run_dir/pilot" --clean "$resolution" "$data/words.txt" "$run_dir/clean-$resolution"
done
```
