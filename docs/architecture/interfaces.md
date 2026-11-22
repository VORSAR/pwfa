# Interface and contract inventory

**Status: INCOMPLETE — no concrete typed interfaces recovered.**

Before implementation, recover or decide:

- State type: phase field domain, spatial topology, units, and regularity.
- Encoder input/output and deterministic parameters.
- Evolution operator and event boundary handling.
- Memory and homeostatic state ownership, reset and carry.
- Observation/decoder input/output, normalization and confidence diagnostics.
- External knowledge input, provenance, consistency and reinjection behavior.
- Numerical error reporting, diagnostic quality, and failure modes.

Each interface must cite a mathematical specification and governing ADR. The interface inventory does not authorize placeholder interfaces to be implemented as if chosen.

[State-space specification](../mathematics/state-space.md) · [Evolution](../mathematics/evolution.md) · [Encoding](../mathematics/encoding-decoding.md) · [Outstanding questions](../research/open-questions.md).
