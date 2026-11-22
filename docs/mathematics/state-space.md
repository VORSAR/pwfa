# Continuous state space

**Original mathematical specification: NOT RECOVERED.**

[SLICE-001](../verification/slices/spatial-phase-foundation.md) drafts the independently reviewable quotient torus, shortest periodic Euclidean distance, and unit-complex foundation. Its review is **NOT STARTED**; no executable Lean is authorized.

Recovered conceptual elements: a spatially distributed coupled oscillator model, a continuous circle-valued phase field, learned memory and homeostasis, observation, and a periodic numerical grid.

## Newly approved partial state-space contracts (2026-11-22)

- [ADR-102](../decisions/ADR-102.md): spatial **topology** is the continuous two-dimensional periodic torus T²=(R/Z)×(R/Z).
- [ADR-103](../decisions/ADR-103.md): phase **representation** is z:T²×time→S¹, with S¹={w∈C:|w|=1}. A globally continuous real angle lift is not assumed.
- [ADR-105](../decisions/ADR-105.md): use the shortest periodic Euclidean distance on the normalized unit square flat torus: `d_T([x],[y]) = min_{n∈Z²} ||x-y+n||₂`.
- These are **new owner decisions**, not recovered original equations. Normalized integration measure, state regularity, initial data, evolution law and memory state remain **UNDECIDED**. The metric can be nonsmooth at cut loci.
- The historical 1D encoder and N-grid conventions remain recovered choices needing an explicit 2D reconciliation decision, not automatic replacement.

Required to complete a normative mathematical contract:

- Normalized integration measure, state regularity and differentiation assumptions on the selected flat periodic torus.
- Precise phase-field function space, winding sectors and admissible initial data.
- Function spaces, continuity/regularity and boundary conditions.
- Memory/trace variables, scalar gain and homeostat domains.
- Initial conditions and admissible control parameters.
- Explicit definitions and units for `κ`, `a`, `α`, `ω`, `N`, `K0`, `m`, `h`, `Q`.

Do not infer these definitions from conventional oscillator models.

[ADR-102](../decisions/ADR-102.md) · [ADR-103](../decisions/ADR-103.md) · [ADR-105](../decisions/ADR-105.md) · [ADR-076a](../decisions/ADR-076a.md) · [ADR-093](../decisions/ADR-093.md) · [ADR-094](../decisions/ADR-094.md) · [Verification obligations](../verification/proof-obligations.md).
