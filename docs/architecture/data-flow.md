# Data flow and temporal boundaries

**Recovered:** sequential pattern training carries learned memory/homeostat state across episodes, while oscillator/trace state resets. Reverse-order training is an ablation. Numerics must respect exact event boundaries.

**Not recovered:** event timestamps, input/output representations, episode durations, values for resets, observation/reinjection schedule, external knowledge retrieval protocol, and knowledge consistency semantics.

The following is a conceptual sketch rather than a normative data flow:

`pattern → spatial encoding → oscillator evolution ↔ learned memory/homeostasis → observation/decoder → benchmark or knowledge-facing consumer`

See [ADR-096](../decisions/ADR-096.md), [ADR-097](../decisions/ADR-097.md), [architecture overview](overview.md), and [experimental methodology](../experiments/methodology.md).
