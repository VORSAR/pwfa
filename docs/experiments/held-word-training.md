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
