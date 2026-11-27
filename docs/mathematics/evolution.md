# Evolution and coupling

**Historical phase evolution:** The recovered unit-ring reference uses a normalized cosine kernel and a unit-complex phase law with lag. [Historical ring reference](ring-oscillator-reference.md)

Recovered parameter choices under [ADR-076a](../decisions/ADR-076a.md):

- Baseline `κ=1`, `a=0.8`, `α=π/2−0.1`, `ω=0`.
- Controls `a=0/0.4` and winding `0/±1` on the ring. The coefficient `a` varies the spatial cosine modulation. The total structural coupling stays fixed across this sweep.

Recovered learned scalar gain under [ADR-093](../decisions/ADR-093.md):

`K_eff = K0 + 0.25*m/(1+h)`

## Flat torus coupling geometry

- [ADR-104](../decisions/ADR-104.md) selects an **isotropic distance-based baseline**, expressible as `K0(x,y)=k(d_T(x,y))`. [ADR-111](../decisions/ADR-111.md) selects the normalized smooth bump and its controls.
- [ADR-105](../decisions/ADR-105.md) defines `d_T` as shortest periodic Euclidean distance on the unit square flat torus. A radial profile in this metric does **not** imply arbitrary global rotational symmetry of the square torus.
- The learned pairwise memory term may remain spatially heterogeneous. No radial constraint on learned memory is implied.

For retrieval, sum the signed contributions from every stored pair with weight $1/N$ per site. This includes the self-entry and permits direct contributions from distant sites. Use zero phase lag for this field in the pilot. Its contribution per unit learned gain is $\operatorname{Im}(\overline{z_i} L_i)$. The learned gain still needs a contract. [Learned lag](../decisions/ADR-129.md) [Retrieval decision](../decisions/ADR-128.md) [Learned-mean experiment](../research/recall-pilot-checks.md#which-stored-pairs-reach-the-retrieval-field)

For the sine interaction driven by that learned field, an isolated two-site calculation gives an exact relative phase at $t=40$. It compares zero learned lag and the recovered structural reference lag at identical positive learned gain. [Phase-lag control](../research/recall-pilot-checks.md#two-site-phase-correction-at-t40)

The [torus oscillator baseline](../verification/slices/torus-oscillator-baseline.md) records the transfer of the ring phase law under [ADR-110](../decisions/ADR-110.md). It specifies the smooth primary profile, a published disk comparator, a separate uniform control, and analytic checks for review.

Negative effective kernels were described as allowed; do not assume positive definiteness or stability. Require explicit existence, uniqueness, regularity, and stability claims with assumptions.

[State space](state-space.md) · [Memory](memory.md) · [Numerical methods](numerical-methods.md).
