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
