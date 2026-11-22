# Evolution and coupling

**Governing phase-evolution equation: NOT RECOVERED.**

Recovered parameter choices under [ADR-076a](../decisions/ADR-076a.md):

- Baseline `κ=1`, `a=0.8`, `α=π/2−0.1`, `ω=0`.
- Controls `a=0/0.4`; winding `0/±1`.

Recovered learned scalar gain under [ADR-093](../decisions/ADR-093.md):

`K_eff = K0 + 0.25*m/(1+h)`

## Newly selected coupling geometry (2026-11-22)

- [ADR-104](../decisions/ADR-104.md) selects an **isotropic distance-based baseline**, provisionally `K0(x,y)=k(d_T(x,y))`, with no specified profile `k`.
- [ADR-105](../decisions/ADR-105.md) defines `d_T` as shortest periodic Euclidean distance on the unit square flat torus. A radial profile in this metric does **not** imply arbitrary global rotational symmetry of the square torus.
- The learned pairwise memory term may remain spatially heterogeneous. No radial constraint on learned memory is implied.

This expression does **not** define the entire nonlocal coupling kernel. The complete nonlocal operator, orientation/sign conventions, ranges, units, initial conditions, and regularity are **NOT RECOVERED**.

Negative effective kernels were described as allowed; do not assume positive definiteness or stability. Require explicit existence, uniqueness, regularity, and stability claims with assumptions.

[State space](state-space.md) · [Memory](memory.md) · [Numerical methods](numerical-methods.md).
