# Evolution and coupling

**Governing phase-evolution equation: NOT RECOVERED.**

Recovered parameter choices under [ADR-076a](../decisions/ADR-076a.md):

- Baseline `κ=1`, `a=0.8`, `α=π/2−0.1`, `ω=0`.
- Controls `a=0/0.4`; winding `0/±1`.

Recovered learned scalar gain under [ADR-093](../decisions/ADR-093.md):

`K_eff = K0 + 0.25*m/(1+h)`

This expression does **not** define the entire nonlocal coupling kernel. The complete nonlocal operator, orientation/sign conventions, ranges, units, initial conditions, and regularity are **NOT RECOVERED**.

Negative effective kernels were described as allowed; do not assume positive definiteness or stability. Require explicit existence, uniqueness, regularity, and stability claims with assumptions.

[State space](state-space.md) · [Memory](memory.md) · [Numerical methods](numerical-methods.md).
