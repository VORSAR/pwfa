# Numerical methods and diagnostics

## Recovered integrator settings

[ADR-097](../decisions/ADR-097.md) records a multiplicative phase-midpoint numerical solver, exponential stages for traces/homeostasis, time steps `dt = 0.1, 0.05, 0.025`, exact handling of event boundaries, and winding/convergence tracking.

## Recovered quadrature settings

[ADR-098](../decisions/ADR-098.md) records a uniform periodic grid, normalized trapezoidal quadrature, normalized observation rows, residual reporting, and diagnostic top-k selection with `k=ceil(0.1*N)`. A contrast threshold of `0.05` is **proposed**, not calibrated. **Pairwise learning remains unsparsified.**

The exact integrator maps, stage ordering, numerical operators, residual/contrast definitions, error norms, stability conditions, and convergence guarantees are **NOT RECOVERED**.

## New topology and representation implications

The continuum domain is a unit square torus with unit-complex phase. For the first numerical baseline, $N$ counts all sites. The 128-, 256-, and 512-site grids are 16×8, 16×16, and 32×16 respectively. Their adjacent refinements alternate axes. Compare the two axial waves separately against their exact continuum rates, with both spacings recorded. The discrete winding diagnostic and unit-magnitude tolerance still need definitions. [Grid decision](../decisions/ADR-112.md) · [State space](state-space.md) · [Wave checks](../verification/slices/torus-oscillator-baseline.md#analytic-checks)

## Obligations before execution

Recover formulas and establish tests for event alignment, phase topology/winding, grid/time-step convergence, conservation where applicable, and reported quadrature residuals.

[State space](state-space.md) · [Evolution](evolution.md) · [ADR-097](../decisions/ADR-097.md) · [ADR-098](../decisions/ADR-098.md).
