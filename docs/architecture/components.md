# Component responsibilities (provisional)

Component boundaries listed here are **proposed documentation groupings**, not recovered exact implementation modules.

| Responsibility | Input / output needed | Relevant ADR |
|---|---|---|
| Spatial encoder | Pattern to periodic stimulation | [095](../decisions/ADR-095.md) |
| Phase evolution | Spatial phase state across time and events | [076a](../decisions/ADR-076a.md), [097](../decisions/ADR-097.md) |
| Learned coupling/memory | Pairwise memory state, global gain and homeostat | [093](../decisions/ADR-093.md), [094](../decisions/ADR-094.md) |
| Training episode coordinator | Deterministic patterns, carry/reset boundaries | [096](../decisions/ADR-096.md) |
| Observer/decoder | Signed-imaginary anchored decoder and diagnostics | [095](../decisions/ADR-095.md), [098](../decisions/ADR-098.md) |
| Benchmark harness | Held-out cues, controls, measurements | [099](../decisions/ADR-099.md), [100](../decisions/ADR-100.md) |

Any component API, serialization, persistence mechanism, or external knowledge contract remains **NOT RECOVERED**.

[Overview](overview.md) · [Interfaces](interfaces.md) · [Design invariants](design-invariants.md).
