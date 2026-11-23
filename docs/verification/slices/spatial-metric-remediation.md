# SLICE-001-METRIC: Euclidean torus metric remediation plan

- **Status:** Written metric contract and internal remediation for the bounded experimental distance module. Independent Gate 1 is pending.
- **Findings reviewed:** [IR-001 and IR-002](spatial-phase-foundation-internal-review.md)
- **Controlling decisions:** [ADR-102](../../decisions/ADR-102.md), [ADR-105](../../decisions/ADR-105.md), [ADR-109](../../decisions/ADR-109.md)
- **Independent claim:** None. This document is an author-side proposal to resolve findings, not a completed review.

## Explicit distance definitions

Let spatial positions be classes in `T²=(R/Z)²` with unit coordinate periods. For a real representative `a`, define `frac(a)=a-floor(a)`, so `0 ≤ frac(a) < 1`.

For classes `[a],[b]∈R/Z`, define the circular distance

`δ([a],[b])=min(|frac(a)-frac(b)|, 1-|frac(a)-frac(b)|)`.

For torus points `p=([p₁],[p₂])`, `q=([q₁],[q₂])`, define the **chosen Euclidean** metric

`d₂(p,q)=sqrt(δ(p₁,q₁)^2 + δ(p₂,q₂)^2)`.

## Lattice minimum and metric laws

For a real displacement $s$, choose $n=-\lfloor s+1/2\rfloor$ and write $r=s+n$. Then $-1/2\le r<1/2$. Any other integer shift gives $r+m$ with $m\in\mathbb Z\setminus\{0\}$, so $|r+m|\ge |m|-|r|\ge 1-|r|\ge|r|$. This proves attainment, including the half-period tie. For fractional representatives the absolute displacement lies in $[0,1)$, and comparison of the direct shift with the one crossing the seam gives exactly the stated $\delta$. The shift set is unchanged by an integer change of either representative.

Minimize each coordinate independently and take the Euclidean length. Any other lattice vector has each absolute residual at least as large, so

$$
d_2(p,q)=\min_{n\in\mathbb Z^2}\|\tilde p-\tilde q+n\|_2
$$

for any representatives $\tilde p,\tilde q$. Negating every shift gives symmetry. The minimum is zero exactly when the representative difference is an integer vector. Translating both points by the same class leaves their difference unchanged. For the triangle inequality use minimizing shifts $n,m$ for the pairs $(p,q)$ and $(q,r)$. The shift $n+m$ is available for $(p,r)$, whose minimum is therefore at most $\|(\tilde p-\tilde q+n)+(\tilde q-\tilde r+m)\|_2\le d_2(p,q)+d_2(q,r)$. The same argument with absolute value proves the circular triangle inequality.

Each coordinate distance is at most $1/2$, giving $d_2\le\sqrt2/2$. The diagonal pair below attains the bound. The sup and Euclidean distances satisfy $d_\infty\le d_2\le\sqrt2\,d_\infty$, so they induce the same topology.

## Required explicit counterexample test

For `p=(0,0)` and `q=(1/2,1/2)`:

- `d₂(p,q)=sqrt(2)/2`.
- `d∞(p,q)=max(δ(p₁,q₁),δ(p₂,q₂))=1/2`.

A library product `MetricSpace` instance using a sup metric **must not** be reused unmodified as the PWFA `d₂` instance. Mathematical topology may be shared, but metrics cannot be conflated.

## Lean interface and verification

1. Prove that `frac(a)` respects integer shifts and hence `δ` is well-defined on quotient classes.
2. Prove `0≤δ≤1/2`, symmetry, identity of indiscernibles, and circular triangle inequality.
3. Prove `d₂` satisfies the metric axioms; for the triangle inequality combine coordinate differences with the Euclidean/Minkowski inequality.
4. Prove `d₂` equals the original lattice minimum and the minimum is achieved.
5. Prove translation invariance of `d₂`.
6. Prove diameter `sqrt(2)/2` and that opposite half-period coordinates attain it.
7. On `UnitAddTorus (Fin 2)`, define a named `euclideanDist` from the two coordinate distances. Mathlib's coordinate wrapped norm uses the nearest integer. The generic `dist` on this torus is the product sup distance. Every spatial kernel uses the named distance. [Pinned torus type](https://github.com/leanprover-community/mathlib4/blob/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/Topology/Instances/AddCircle/Real.lean) · [Pinned coordinate norm](https://github.com/leanprover-community/mathlib4/blob/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/Analysis/Normed/Group/AddCircle.lean) · [Pinned product distance](https://github.com/leanprover-community/mathlib4/blob/56a005855ea17e0b0958f73ec801ae140b0a1679/Mathlib/Topology/MetricSpace/Pseudo/Pi.lean)
8. Compile the stated properties and audit their axiom dependencies. Report each compiled claim at its proved scope.

## Internal review before implementation

The assistant checked the proposed mathematical remedies on 2026-11-23, acting in the internal review role after drafting them. The reviewer is also the author. For IR-001, the named Euclidean distance, diagonal witness, and explicit bounds against the sup distance resolve the representation ambiguity. For IR-002, the nearest-integer bound handles ties, representative changes, and the infinite-lattice minimum. The metric proof uses interchangeable representatives and carries the minimizing shifts through the triangle inequality. The exact statements and pinned library references address the specification requirements for this metric-only scope.

The bounded experimental authorization under ADR-109 covers the named distance, its quotient and metric properties above, and the diagonal witness. This internal closure applies to the written metric scope. Independent Gate 1, the oscillator contract review, and proof compilation are separate obligations.
