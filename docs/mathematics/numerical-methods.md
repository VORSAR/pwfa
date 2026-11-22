# Numerical methods and diagnostics

## Recovered integrator settings

[ADR-097](../decisions/ADR-097.md) records a multiplicative phase-midpoint numerical solver, exponential stages for traces/homeostasis, time steps `dt = 0.1, 0.05, 0.025`, exact handling of event boundaries, and winding/convergence tracking.

## Recovered quadrature settings

[ADR-098](../decisions/ADR-098.md) records a uniform periodic grid, normalized trapezoidal quadrature, normalized observation rows, residual reporting, and diagnostic top-k selection with `k=ceil(0.1*N)`. A contrast threshold of `0.05` is **proposed**, not calibrated. **Pairwise learning remains unsparsified.**

The exact integrator maps, stage ordering, numerical operators, residual/contrast definitions, error norms, stability conditions, and convergence guarantees are **NOT RECOVERED**.

## New topology and representation implications

[ADR-102](../decisions/ADR-102.md) selects a continuous two-dimensional periodic torus; [ADR-103](../decisions/ADR-103.md) selects an S¹-valued unit-complex phase field. The recovered periodic grid size `N` is not yet assigned a two-dimensional meaning (per axis versus total sites). Historical winding `0/±1` likewise needs two-direction topology conventions. The eventual integrator must maintain unit magnitude, subject to clearly defined numerical tolerances and proof conditions. **No 2D solver or quadrature is approved by these choices alone.**

## Obligations before execution

Recover formulas and establish tests for event alignment, phase topology/winding, grid/time-step convergence, conservation where applicable, and reported quadrature residuals.

[State space](state-space.md) · [Evolution](evolution.md) · [ADR-097](../decisions/ADR-097.md) · [ADR-098](../decisions/ADR-098.md).
