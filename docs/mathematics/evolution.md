# Evolution and coupling

**Historical phase evolution:** The recovered unit-ring reference uses a normalized cosine kernel and a unit-complex phase law with lag. [Historical ring reference](ring-oscillator-reference.md)

Recovered parameter choices under [ADR-076a](../decisions/ADR-076a.md):

- Baseline `κ=1`, `a=0.8`, `α=π/2−0.1`, `ω=0`.
- Controls `a=0/0.4` and winding `0/±1` on the ring. The coefficient `a` varies the spatial cosine modulation. The total structural coupling stays fixed across this sweep.

Recovered learned scalar gain under [ADR-093](../decisions/ADR-093.md):

`K_eff = K0 + 0.25*m/(1+h)`

## Flat torus coupling geometry

- [ADR-104](../decisions/ADR-104.md) selects an **isotropic distance-based baseline**, expressible as `K0(x,y)=k(d_T(x,y))`. The exact 2D profile is pending.
- [ADR-105](../decisions/ADR-105.md) defines `d_T` as shortest periodic Euclidean distance on the unit square flat torus. A radial profile in this metric does **not** imply arbitrary global rotational symmetry of the square torus.
- The learned pairwise memory term may remain spatially heterogeneous. No radial constraint on learned memory is implied.

The [torus oscillator draft](../verification/slices/torus-oscillator-baseline.md) proposes transfer of the ring phase law to a normalized radial kernel. It specifies a published disk comparator, a candidate smooth profile, a separate uniform control, and analytic checks.

Negative effective kernels were described as allowed; do not assume positive definiteness or stability. Require explicit existence, uniqueness, regularity, and stability claims with assumptions.

[State space](state-space.md) · [Memory](memory.md) · [Numerical methods](numerical-methods.md).
