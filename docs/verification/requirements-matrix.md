# Requirements and verification traceability

This is an initial **mapping of recovered constraints**, not a verified original requirements list. The local identifiers `REC-...` are tracking identifiers newly introduced for this migration, not recovered historical IDs.

| Requirement | Decision | Current specification | Verification status |
|---|---|---|---|
| NEW-SPACE-01: 2D periodic spatial torus | [102](../decisions/ADR-102.md) | [State space](../mathematics/state-space.md) | Topology selected; metric, grid, and encoder reconciliation open |
| NEW-PHASE-01: Unit-complex phase | [103](../decisions/ADR-103.md) | [State space](../mathematics/state-space.md), [Numerics](../mathematics/numerical-methods.md) | Representation selected; evolution/norm preservation not proved |
| REC-GATE-01: Two independent review gates | [046](../decisions/ADR-046.md) | [Review gates](review-gates.md) | Gate 1 **NOT VERIFIED** |
| REC-GATE-02: Close all Gate-1 findings | [055](../decisions/ADR-055.md) | [Review gates](review-gates.md) | **NOT VERIFIED** |
| REC-MEM-01: Gain and homeostasis | [093](../decisions/ADR-093.md), [094](../decisions/ADR-094.md) | [Memory](../mathematics/memory.md) | Formula summaries only |
| REC-ENC-01: Spatial encoding and decoder | [095](../decisions/ADR-095.md) | [Encoding](../mathematics/encoding-decoding.md) | Exact formula missing |
| REC-NUM-01: Convergence and quadrature | [097](../decisions/ADR-097.md), [098](../decisions/ADR-098.md) | [Numerics](../mathematics/numerical-methods.md) | Solver details missing |
| REC-EXP-01: Deterministic benchmark | [099](../decisions/ADR-099.md) | [Benchmark](../experiments/benchmarks.md) | Protocol incomplete |
| REC-EXP-02: Matched recall target | [100](../decisions/ADR-100.md) | [Hypotheses](../vision/hypotheses.md) | No results |

Future requirements must link forward and back to controlling ADRs, mathematical contracts, proof/test artifacts, and [evidence](../research/evidence-register.md). An unset verification status cannot be treated as a pass.

[Proof obligations](proof-obligations.md) · [Recovery status](../history/recovery-status.md).
