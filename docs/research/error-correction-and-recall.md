# Error correction and whole-word recall

The first PWFA library contains four 16-bit words. Each evaluation cue supplies twelve correct bits, two flipped bits and two visible omissions. The retriever sees the presented bits and the omissions; only the evaluator knows which presented bits were flipped. At $t=40$ all sixteen answers for one cue must match its original word. [Frozen library and experiment](../experiments/first-trained-recall.md) · [Strength sweep](../experiments/structural-coupling-at-retrieval.md#intermediate-strength-results)

## Scope of the Lean check

On 2026-11-27, against `4cca557`, Codex (GPT-6), the author in the internal reviewer role, closed three findings for an experimental coding-theory check under ADR-109. Its inputs are binary words, visible positions and designated erasures. Its conclusions concern information available to a decoder.

- **EC-01.** Start from the pinned mathlib Hamming metric. Bound the loss of distance when erasing positions, apply the triangle inequality on the visible coordinates and use a strict separation inequality for unique nearest decoding. A tie must remain possible at the boundary.
- **EC-02.** Check the six distances between the actual four words and a concrete ambiguous cue with exactly two disjoint flips and two masks from either of two words. Compare these worst-case examples with the scores on the frozen roster.
- **EC-03.** Enumerate each target, unordered pair of masks and unordered pair of flips outside the masks exactly once. Separate a unique nearest correct word, a nearest-distance tie and a wrong unique nearest word. Also count how many target-labelled cases are compatible with multiple sources given the *exact* corruption counts. These counts describe an exhaustive static decoding check on one library; they do not estimate PWFA performance.

These remedies cover only the distance proof and finite examples. The phase solver, experiment inputs and recall policy retain the previously recorded experimental scope. [Research process](../../CONTRIBUTING.md#lean-experiments-for-research-decisions)
