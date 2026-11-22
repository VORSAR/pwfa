# Design invariants and guardrails

These are **design constraints and candidate obligations**, not all formally proved invariants.

1. State/observation definitions must preserve the explicitly specified periodic domain and phase topology.
2. Numerical integration must not silently cross scheduled event boundaries; observe winding and convergence.
3. Training must respect deterministic ordering and documented reset/carry semantics.
4. Pairwise learning must not be sparsified as a consequence of diagnostic top-k selection.
5. Negative effective kernel values are not automatically excluded; do not assert stability without explicit assumptions.
6. Engineering success thresholds are not empirical findings.
7. Independent pre-implementation review Gate 1 blocks executable Lean development until **every** finding closes.

[ADR-093](../decisions/ADR-093.md) · [ADR-096](../decisions/ADR-096.md) · [ADR-097](../decisions/ADR-097.md) · [ADR-098](../decisions/ADR-098.md) · [Proof obligations](../verification/proof-obligations.md).
