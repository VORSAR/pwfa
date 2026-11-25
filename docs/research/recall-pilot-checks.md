# Checks for the first trained recall pilot

## Bounded internal review

At revision `dc039d470d92664523fd8a64b157227c82b3cc99`, Codex (GPT-6), the author acting in the internal reviewer role, reviewed two proposed experiments under ADR-109. The first tests scoring of already decoded words. The second tests what information a proposed pairwise training statistic can retain at the two approved phase alphabets. Both use artificial examples. [Pilot endpoint](../experiments/benchmarks.md#first-trained-recall-measurement) · [Memory contract](../mathematics/memory.md) · [Research process](../decisions/ADR-117.md)

| Finding | Severity | Remedy specified before experimental Lean |
|---|---|---|
| SC-01 | High | Index the target and decoded word by the same sixteen positions. Require all positions to match the original target for an exact hit. Represent an abstaining bit and a failed run explicitly. Check a cue with a flipped bit and an omitted bit, copying, exact recovery, a wrong masked bit and a tie. |
| SC-02 | High | Test the effect of excluding failures or abstentions from the denominator on identical synthetic outcomes. Keep the owner’s choice of scoring policy open. Report counts even when no trials ran. Predictions come from the model; the target and corruption labels enter scoring only. |
| PM-01 | High | Treat signed real phase alignment and its square as candidate statistics. Verify symmetry, common-rotation invariance on unit phases, and the exact same/opposite symbol values at both alphabets. Check the ambiguity under simultaneous reversal of an entire word of primary symbols. |
| PM-02 | High | Keep the dense pairwise statistic separate from the recovered global scalar gain. State what a pair contributes before temporal averaging. Include a configuration where magnitude discards a distinction. Training updates, interaction with other sites and the origin, storage capacity, and recall accuracy require separate evidence. |

The remedies freeze and internally clear these two experiments only. The model has no trained output in this revision. Gate 1 remains open. [Review policy](../verification/review-gates.md)

## Counting exact words

At the frozen review revision `0e42e37`, SC-01 and SC-02 were checked against the [Lean scoring experiment](../../scripts/experiments/recall-scoring.lean). Its exact-word predicate on a decoded word is equivalent to every one of its sixteen positions being resolved and equal to its original target. A synthetic cue with one flip and one mask illustrates this test. Copying the cue gets 14 of 14 unchanged bits right, zero of one flipped bit corrected, and zero of one masked bit recovered. Correcting only the flip or only the mask can still leave a wrong word. The one-of-each fixture tests the scorer independently of the benchmark’s pending 10% rounding rule.

| Artificial outcomes | Exact words | Denominator | Fraction |
|---|---:|---:|---:|
| One exact, one wrong, one abstention, one failed run | 1 | 4 scheduled cues | 1/4 |
| Same records, conditional on a complete prediction | 1 | 2 complete predictions | 1/2 |

The scorer keeps numerator and denominator counts. An empty denominator gives an undefined rate. Recording both rates with coverage (complete predictions divided by scheduled cues) exposes the change of denominator. It also keeps failures visible. The strict all-cue rate is the recommendation for the primary endpoint. Classifying an outcome with both a wrong bit and a tie as abstained is an experiment convention. The definitive policy and the phase threshold still need owner decisions. None of the artificial outcomes are measured PWFA predictions.
