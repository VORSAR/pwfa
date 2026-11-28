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
