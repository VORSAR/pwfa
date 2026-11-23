# Requirements and verification traceability

This is an initial **mapping of recovered constraints**, not a verified original requirements list. The local identifiers `REC-...` are tracking identifiers newly introduced for this migration, not recovered historical IDs.

| Requirement | Decision | Current specification | Verification status |
|---|---|---|---|
| NEW-SPACE-01: 2D periodic spatial torus | [102](../decisions/ADR-102.md) | [State space](../mathematics/state-space.md) | Topology selected; metric, grid, and encoder reconciliation open |
| NEW-PHASE-01: Unit-complex phase | [103](../decisions/ADR-103.md), [109](../decisions/ADR-109.md) | [State space](../mathematics/state-space.md), [Experimental phase algebra](slices/phase-algebra-experiment.md) | All six algebraic theorems compiled in CI. Independent review pending. [Review packet](slices/phase-algebra-review-packet.md) |
| NEW-COUPLING-01: Distance-based isotropic baseline | [104](../decisions/ADR-104.md) | [Evolution](../mathematics/evolution.md) | Geometry selected; kernel profile and proof missing |
| NEW-METRIC-01: Shortest periodic Euclidean distance | [105](../decisions/ADR-105.md) | [Metric remediation](slices/spatial-metric-remediation.md) | IR-001/002 open; executable metric formalization blocked |
| NEW-VERIFY-02: Internal role-separated review for experimental Lean only | [109](../decisions/ADR-109.md) | [Review gates](review-gates.md), [Phase-only slice](slices/phase-algebra-experiment.md) | Phase experiment internally cleared and compiled in CI. Independent review pending. |
| NEW-VERIFY-01: Independent review and full closure per frozen slice | [108](../decisions/ADR-108.md), [109](../decisions/ADR-109.md) | [Review gates](review-gates.md), [SLICE-001](slices/spatial-phase-foundation.md) | Independent certification not started; experiment policy separate |
| REC-GATE-01: Two independent review gates | [046](../decisions/ADR-046.md), [108](../decisions/ADR-108.md) | [Review gates](review-gates.md) | Each slice Gate 1/2 NOT VERIFIED |
| REC-GATE-02: Close all findings within authorized review scope | [055](../decisions/ADR-055.md), [108](../decisions/ADR-108.md) | [Review gates](review-gates.md) | **NOT VERIFIED** |
| REC-MEM-01: Gain and homeostasis | [093](../decisions/ADR-093.md), [094](../decisions/ADR-094.md) | [Memory](../mathematics/memory.md) | Formula summaries only |
| REC-ENC-01: Spatial encoding and decoder | [095](../decisions/ADR-095.md) | [Encoding](../mathematics/encoding-decoding.md) | Exact formula missing |
| REC-NUM-01: Convergence and quadrature | [097](../decisions/ADR-097.md), [098](../decisions/ADR-098.md) | [Numerics](../mathematics/numerical-methods.md) | Solver details missing |
| REC-EXP-01: Deterministic benchmark | [099](../decisions/ADR-099.md) | [Benchmark](../experiments/benchmarks.md) | Protocol incomplete |
| REC-EXP-02: Matched recall target | [100](../decisions/ADR-100.md) | [Hypotheses](../vision/hypotheses.md) | No results |

Future requirements must link forward and back to controlling ADRs, mathematical contracts, proof/test artifacts, and [evidence](../research/evidence-register.md). An unset verification status cannot be treated as a pass.

[Proof obligations](proof-obligations.md) · [Recovery status](../history/recovery-status.md).
