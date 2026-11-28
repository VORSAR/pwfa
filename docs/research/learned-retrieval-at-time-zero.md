# What learned retrieval does at the first instant

Two archived results needed an explanation. With structural coupling off, one retrieval run kept every presented bit, including all 32 flips on each library. Hiding one bit at a time corrected most flips and recovered 8/16 words. This note checks what the learned interaction does to each bit at the moment the cue is released. It covers the held memory, zero learned lag and zero structural strength. [Ordinary retrieval](../experiments/structural-coupling-at-retrieval.md#paired-results-at-t40) · [Queried-bit readout](../experiments/recall-with-queried-bit-hidden.md#results-at-t40)

## What Lean checks about the prepared cue

Write each presented symbol as $x=+1$ for a 1 and $x=-1$ for a 0. The learned pull of one site on another is the stored pair value times the sine of their phase difference. [Learned field](../decisions/ADR-128.md) · [Learned lag](../decisions/ADR-129.md)

**A presented bit receives nothing from the other symbols.** At the primary ±90° alphabet two presented centers are zero or half a turn apart, so the sine vanishes for every stored value. A neighbouring shoulder site, a site of an omitted bit and a background site each pull a presented center by an amount fixed by that center's own symbol. No site carries the value of another bit to it. This holds for any memory.

**A hidden bit receives the memory applied to the visible symbols.** An omitted center stays at the background angle. Each presented center then acts on it with its full signed symbol, and each shoulder acts with the same sign.

**The comparison alphabet differs in three ways.** At ±45° two unlike presented centers are a quarter turn apart and exert a pull of half the difference of their symbols. The stored value for a pair of centers becomes $(1+st)/2$, which is never negative. Each center also stores an alignment of $\sqrt2/2$ with every background site, where the primary alphabet stores zero. [Lean identities](../../scripts/experiments/presented-bit-torque.lean) · [Bit phases](../decisions/ADR-118.md)

## The time-zero formula for a hidden bit

Let $C_{ja}$ be the stored signed agreement between bit positions $j$ and $a$ under the episode weights, let $\alpha=(\pi/2)e^{-1/3}$ be the prepared angle of a shoulder site, and sum over the visible positions other than $j$. With learned gain $g$ and $N$ sites, the angular velocity of the hidden center relative to the origin at time zero is

$$
\frac{g}{N}\left[(1+2\sin^2\alpha)\sum_{a}C_{ja}x_a-\sin(2\alpha)\sum_{a}x_a\right].
$$

The first sum is the memory row applied to the cue. This is the quantity a Hopfield network thresholds in one update. The second term comes from the origin anchor. The shoulders of the presented bits move the background, so the origin drifts with the surplus of ones over zeros in the cue. Lean checks each stored value and each sine that enters the two coefficients. A separate finite-difference calculation on the full 128-site model agreed with the formula to $2\times10^{-7}$. That calculation is not reproduced in Lean. [Origin anchor](../decisions/ADR-116.md)

The sign of this expression equals the archived oscillator symbol at $t=40$ in **1,244 of 1,280** positions, with one position unresolved. The comparison covers both development libraries, equal and rebalanced weights, and corrupted and clean probes. Whole words agree less often. All 16 clean probes are identical. Among the 64 corrupted cues, 41 are. The readout at $t=40$ therefore follows the time-zero sign closely per bit and departs from it where the expression is small. [Archived predictions](../experiments/complement-balanced-training.md#exact-words-at-t40)

## Static references on the two development libraries

The executable enumerates every target, every unordered pair of omissions and every unordered pair of flips outside them. That gives 43,680 cases per library. Ties and unresolved positions count as misses. The Hopfield rows use the same pair matrix with zero self-coupling and asynchronous sign updates in index order until nothing changes. Omitted positions start at zero and a zero field leaves a position unchanged.

| Decoder | Original library | Second library |
|---|---:|---:|
| Nearest stored word on visible positions | 41,958 (96.06%) | 43,320 (99.18%) |
| Hopfield network, equal weights | 27,105 (62.05%) | 33,431 (76.54%) |
| Hopfield network, rebalanced weights | 27,084 (62.01%) | 38,377 (87.86%) |
| Time-zero hidden-bit sign, equal weights | 25,289 (57.90%) | 27,526 (63.02%) |
| Time-zero hidden-bit sign, rebalanced weights | 19,702 (45.11%) | 26,880 (61.54%) |
| Same without the origin term, equal weights | 25,300 (57.92%) | 28,224 (64.62%) |
| Same without the origin term, rebalanced weights | 21,464 (49.14%) | 31,356 (71.79%) |

The nearest-word count for the original library equals the earlier enumeration. On the 16 scheduled cues of each library the Hopfield network recovers 9/16 and 12/16 words with equal weights and 9/16 and 13/16 with rebalanced weights. Nearest-word lookup recovers 16/16 on both. [Earlier enumeration](error-correction-and-recall.md#what-the-four-pwfa-words-actually-allow) · [Lean executable](../../scripts/experiments/pair-memory-reference.lean)

The four time-zero rows are predictions from the formula. They are not measurements of the oscillator, and whole-word agreement with the archive is partial. Read them for structure. Equal weights favour the complementary pair almost completely. Rebalancing moves recall to the other two words at the pair's expense with no overall gain on either library. The origin term costs about ten points under rebalanced weights on the second library.

## What this supports and what it leaves open

- **One run copies the cue.** The identities explain why the other symbols cannot reach a presented bit at first. In the archived runs flipped centers start 90° on the wrong side of the origin. A separate calculation, not reproduced in Lean, places them at 79° and 91° on the wrong side on average at $t=40$.
- **The hidden-bit readout is close to one Hopfield update,** taken sixteen times per cue with an added origin drift.
- **Sixteen cues cannot rank small changes.** One word is 6.25 points of a sixteen-cue score. The measured rebalancing differences were one word down on the original library and two words up on the second.
- **Lookup leaves little room.** Its exhaustive rates leave at most 3.94 and 0.82 points of headroom for any decoder on these two libraries under this corruption rule.
- **Open.** Whether presented bits correct each other in one run at the comparison alphabet needs measurement. So does the oscillator's own exhaustive rate, which the time-zero rows only approximate. [Mission criterion](../decisions/ADR-100.md) · [Roadmap](../roadmap.md)

## Bounded internal review

On 2026-11-28, against `80e7299`, the assistant, acting as internal reviewer, reviewed the two Lean files below as an experimental slice. The review is internal and role-separated. No outside reviewer checked it, and independent Gate 1 remains open. The identities file was drafted earlier the same day, before the wording for reviewer identity had been decided. The review was carried out against that draft, and the committed files reflect its findings. [Review policy](../decisions/ADR-109.md) · [Reviewer identity](../decisions/ADR-132.md)

- **PT-01, coverage.** The draft treated presented centers and shoulders acting on a presented center. Sites of omitted bits and background sites act on it too. Add the zero-angle case so that the claim about every site is complete. Closed by `zero_site_on_presented`.
- **PT-02, both sides of the comparison alphabet.** Stating the pair pull at ±45° alone would present that alphabet as a pure gain. State the stored pair values and the stored alignment with the background at both alphabets. Closed by `stored_pair_values` and `stored_background_values`.
- **PT-03, scope.** Every identity concerns the prepared cue at time zero with zero learned lag and no structural coupling. None predicts the readout at $t=40$. The module comment and this note say so.
- **PM-01, same memory.** The pair matrix must be the learned memory between bit centers. Lean shows the stored value at ±90° is the signed product of the two bits. Use integer numerators for the episode weights and zero self-coupling. Check known entries on a one-pair library.
- **PM-02, enumeration.** Count each target, pair of omissions and pair of flips outside the omissions once. The nearest-word row must reproduce the earlier count of 41,958 on the original library. Count ties and unresolved positions as misses.
- **PM-03, labelling.** Report the time-zero rows as predictions and print their agreement with archived oscillator output beside them. Describe the Hopfield schedule as one reference schedule. The matched budget for the mission comparison is a separate specification.

**Post-implementation check.** Both files compile with warnings treated as errors and contain no admitted proof. The eleven identities depend only on the three standard axioms. The executable's controls pass, its nearest-word row equals the earlier count, and the figures above were reproduced from it on both libraries.

## Reproduce

From the repository root, the first command checks the identities and the second runs the controls. The remaining commands print the table rows, the roster scores and one agreement count. Repeat the last command for each library, weighting and probe set. Export visible cues with the [scoring command](../experiments/benchmarks.md#score-a-recall-export).

```sh
lake lean scripts/experiments/presented-bit-torque.lean -- -DwarningAsError=true
reference=scripts/experiments/pair-memory-reference.lean
lean --run "$reference" --check
for lib in docs/experiments/first-recall docs/experiments/queried-bit-recall/replication; do
  lean --run "$reference" --enumerate "$lib/words.txt"
  lean --run "$reference" --roster "$lib/words.txt" "$lib/schedule.tsv"
done
cues=$(mktemp)
lean --run scripts/experiments/recall-scoring.lean --export-cues docs/experiments/first-recall/schedule.tsv > "$cues"
lean --run "$reference" --agreement equal docs/experiments/first-recall/words.txt "$cues" \
  docs/experiments/queried-bit-recall/primary/steps-20/context.tsv
```
