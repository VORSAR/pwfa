# Memory dynamics and homeostasis

**Recoverable choices:**

- [ADR-093](../decisions/ADR-093.md): `K_eff = K0 + 0.25*m/(1+h)`.
- [ADR-094](../decisions/ADR-094.md): `τ_h=50`; `dh/dt=(Q-h)/50`; branch-local or carried stimulated `h`, with standardized recall.
- [ADR-096](../decisions/ADR-096.md): deterministic sequential training; `m/h` carried between episodes; oscillator/trace reset; reverse-order ablation.

**Not recovered:** full pairwise learned memory evolution, meaning of `Q`, memory and homeostat domains, exact initial and reset values, branch criteria, episode duration, and standardized recall formula.

Before testing or proving, specify a state transition table for each train/retrieve event.

The [pairwise training experiment](../research/recall-pilot-checks.md#pairwise-input-to-the-learning-rule) compares signed real phase alignment and its square for both approved input alphabets. The owner chose signed real alignment as the first training input. The temporal update and its use in the learned interaction remain open. The global scalar gain and its parameters have a separate role. [Pairwise decision](../decisions/ADR-123.md)

[Architecture components](../architecture/components.md) · [Training protocol](../experiments/methodology.md) · [Proof obligations](../verification/proof-obligations.md).
