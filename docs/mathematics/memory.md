# Memory dynamics and homeostasis

**Recoverable choices:**

- [ADR-093](../decisions/ADR-093.md): `K_eff = K0 + 0.25*m/(1+h)`.
- [ADR-094](../decisions/ADR-094.md): `τ_h=50`; `dh/dt=(Q-h)/50`; branch-local or carried stimulated `h`, with standardized recall.
- [ADR-096](../decisions/ADR-096.md): deterministic sequential training; `m/h` carried between episodes; oscillator/trace reset; reverse-order ablation.

**Not recovered:** full pairwise learned memory evolution, meaning of `Q`, memory and homeostat domains, exact initial and reset values, branch criteria, episode duration, and standardized recall formula.

Before testing or proving, specify a state transition table for each train/retrieve event.

The [pairwise training experiment](../research/recall-pilot-checks.md#pairwise-input-to-the-learning-rule) compares signed real phase alignment and its square for both approved input alphabets. The owner chose signed real alignment as the first training input. The temporal update and its use in the learned interaction remain open. The global scalar gain and its parameters have a separate role. [Pairwise decision](../decisions/ADR-123.md)

## Training and recall transitions

| Event | Specified behavior | Still to specify |
|---|---|---|
| Start an independently trained library | Start a new accumulated pairwise mean with zero completed episodes. | Initial oscillator, trace, scalar $m$ and homeostat $h$. |
| Present each of the four words | Present words sequentially. Reset oscillator and trace between episodes. Collect signed pair alignment. | Reset values, stimulus timing and strength, within-episode summary window, feedback from already stored memory. |
| Complete an episode | Include its pairwise summary exactly once in the running mean. Carry the learned state and homeostasis between episodes. | Update of the separate scalar $m$, definition of homeostatic drive $Q$, and exact branch handling. |
| Present a held-out cue and retrieve | Use the corrupted cue. Keep its original target with the evaluator. Read relative to the simultaneous origin phase at the recall endpoint. | Clock origin, cue release, exposure duration, read-only or adaptive retrieval state, and observation threshold. |

The pairwise mean after four episodes is the sum of their four summaries divided by four. Recording the completed count makes the update well-defined at the first presentation. [Episode weighting](../decisions/ADR-124.md) · [Sequential training](../decisions/ADR-096.md) · [Recall scoring](../decisions/ADR-122.md)

For the recovered homeostat with $Q$ held constant during one integration stage, the exact solution stays between its start value and $Q$. Nonnegative initial $h$ and nonnegative stage drives therefore suffice for the scalar gain denominator $1+h$ to stay at least one. The definition and admissible range of $Q$ remain open. [Exact stage and trace comparison](../research/recall-pilot-checks.md#what-the-trace-retains-within-one-episode)

[Architecture components](../architecture/components.md) · [Training protocol](../experiments/methodology.md) · [Proof obligations](../verification/proof-obligations.md).
