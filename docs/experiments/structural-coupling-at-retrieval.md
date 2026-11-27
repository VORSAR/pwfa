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
