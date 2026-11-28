# Architecture overview

The recovered system is a computational reference model with continuous circle-valued phase fields, distributed coupled oscillators, internal memory, a knowledge-facing input/output path, learned coupling, and observation.

The [vision statement](../vision/vision-statement.md) describes the intended architecture: persistent internal state, integration of external knowledge, adaptation through experience, and computation arising from the dynamics. This reference model is the current instrument for testing it.

**Recovery-only conceptual flow:**

1. Encode an input into spatial/phase stimulation.
2. Evolve coupled oscillator states and memory/homeostatic variables.
3. Observe system state and calculate retrieval diagnostics.
4. Decode a retrieval output; optionally reinject knowledge-conditioned information.

This is a *conceptual sequence*, not the original recovered event schedule or an agreed concrete component protocol. Specific temporal and interface rules remain **NOT RECOVERED**.

## Governing decisions

[ADR-093](../decisions/ADR-093.md) · [ADR-094](../decisions/ADR-094.md) · [ADR-095](../decisions/ADR-095.md) · [ADR-096](../decisions/ADR-096.md).

[Components](components.md) · [Interfaces](interfaces.md) · [Data flow](data-flow.md) · [Review status](../verification/review-gates.md).
