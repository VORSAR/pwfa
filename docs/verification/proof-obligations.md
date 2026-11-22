# Mathematical and experimental proof obligations

**Status:** candidate recovery-derived obligations; none asserted as discharged.

| Area | Required evidence | Governing references |
|---|---|---|
| State validity | Defined continuous state space, topology, well-posedness assumptions; foundational topology/metric/phase claims scoped to SLICE-001 | [State space](../mathematics/state-space.md), [SLICE-001](slices/spatial-phase-foundation.md) |
| Evolution | Existence, uniqueness, regularity; justified stability/bounds where claimed | [Evolution](../mathematics/evolution.md), [ADR-093](../decisions/ADR-093.md) |
| Homeostasis | Domain/initial conditions and behavior of `h` under defined `Q` | [Memory](../mathematics/memory.md), [ADR-094](../decisions/ADR-094.md) |
| Encoding | Exact bump/decoder definitions, normalization, calibration and failure behavior | [Encoding](../mathematics/encoding-decoding.md), [ADR-095](../decisions/ADR-095.md) |
| Integration | Event-aligned steps, convergence/error diagnostics and winding checks | [Numerics](../mathematics/numerical-methods.md), [ADR-097](../decisions/ADR-097.md) |
| Observation | Normalization, quadrature residual, gating and full pairwise memory | [ADR-098](../decisions/ADR-098.md) |
| Benchmark | Deterministic held-out protocol, matched comparator and statistically valid interval | [ADR-099](../decisions/ADR-099.md), [ADR-100](../decisions/ADR-100.md) |
| Governance | Independent hostile Gate-1 report and **all** findings closed | [Review gates](review-gates.md) |

Formal verification requires explicit theorem statements and assumptions, pinned Lean/mathlib versions, and verifiable dependency chains. Under [ADR-109](../decisions/ADR-109.md), an internally reviewed, finding-closed subset can enter **experimental** Lean; independent Gate 1/2 certification and whole-system validation remain separate and unachieved. See the [phase-algebra experiment](slices/phase-algebra-experiment.md). No purported Lean proofs or experimental results have been recovered.

[Traceability matrix](requirements-matrix.md) · [Evidence register](../research/evidence-register.md).
