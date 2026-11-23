# Flat torus oscillator baseline

**Status:** The owner selected the phase law and finite-range kernel for the written baseline. Internal review of the oscillator contract and independent Gate 1 are pending. [ADR-110](../../decisions/ADR-110.md) · [ADR-111](../../decisions/ADR-111.md)

## State and phase equation

Let $D=(\mathbb R/\mathbb Z)^2$, let $d_T$ be the shortest periodic Euclidean distance, and use uniform area measure $\mu(D)=1$. Take any continuous unit-complex initial field $z_0:D\to S^1$, where $S^1=\{w\in\mathbb C:|w|=1\}$. The phase-only baseline uses constant natural frequency $\omega$, coupling strength $\kappa$, and phase lag $\alpha$. Input, learned coupling, homeostasis, encoding, and recall are outside this contract.

For a nonnegative radial profile $k$, set $G(x,y)=k(d_T(x,y))$ and require $\int_D G(x,y)\,d\mu(y)=1$ for each $x$. The selected phase law is

$$
\begin{aligned}
Z(x,t)&=\int_D G(x,y)z(y,t)\,d\mu(y),\\
A(z)(x)&=\omega+\kappa\operatorname{Im}\!\left(
e^{-i\alpha}\overline{z(x,t)}Z(x,t)\right),\\
\partial_t z(x,t)&=iz(x,t)A(z)(x),\qquad z(x,0)=z_0(x).
\end{aligned}
$$

The recovered ring settings $\kappa=1,\ \alpha=\pi/2-0.1,\ \omega=0$ give a proposed starting point for comparing the two models. The normalization makes $\kappa$ the total structural coupling strength. The sign convention is the one in the recovered ring law and in the phase equation of Panaggio and Abrams. The latter paper uses a sum of coordinate cosines for its kernel. [Historical ring reference](../../mathematics/ring-oscillator-reference.md) · [Panaggio and Abrams (2013), Eq. 1 and the kernel following Eq. 4](https://arxiv.org/pdf/1211.2021)

## Finite range and comparison kernels

Use $0<R<\tfrac12$ for the smooth and disk kernels. Each supported disk then lies in a region with unambiguous Euclidean displacement. Its area is $\pi R^2$.

### Published disk comparator

$$
G_R^{\mathrm{disk}}(x,y)=
\frac{\mathbf{1}_{\{d_T(x,y)<R\}}}{\pi R^2}.
$$

Omel’chenko and colleagues use circular periodic neighborhoods with equal weights and give the normalized continuum disk average. Their continuum variable describes local coherence, with the disk geometry supplying the comparator here. The sharp support edge gives a comparison at the same radius and total weight as a smooth kernel. [Omel’chenko et al. (2012), Eqs. 1 and 6](https://webdoc.sub.gwdg.de/ebook/serien/e/wias/2012/wias_preprints_1682.pdf)

### Smooth primary kernel

For $s\ge0$, let $b(s)=\exp[-1/(1-s)]$ for $s<1$ and $b(s)=0$ for $s\ge1$. The primary kernel is

$$
G_R^{\mathrm{smooth}}(x,y)=
C_R\,b\!\left(\frac{d_T(x,y)^2}{R^2}\right),
\qquad
C_R^{-1}=\pi R^2\int_0^1 b(s)\,ds .
$$

Translation invariance makes the normalizer independent of $x$. Within the support the squared distance is squared Euclidean displacement, including at zero separation. The bump and all its derivatives vanish at the support edge, and the profile is zero near the torus cut locus. A nominal radius and any sweep require an experimental decision. [Metric remediation](spatial-metric-remediation.md) · [ADR-111](../../decisions/ADR-111.md)

### Uniform control

Use $G_{\mathrm{uniform}}(x,y)=1$ as the separate all-to-all control at equal total coupling strength. The historical $a$-sweep belongs to the ring reference. The disk and smooth profiles differ in how they distribute weight even at the same radius. [Historical ring reference](../../mathematics/ring-oscillator-reference.md) · [ADR-111](../../decisions/ADR-111.md)

## Analytic checks

Write $g(u)=G(0,u)$ and $(T_gz)(x)=\int_D g(u)z(x+u)\,d\mu(u)$. All three comparison kernels have nonnegative unit mass. Hence $T_g$ maps continuous fields to continuous fields by uniform continuity of $z$, with $\|T_gz\|_\infty\le\|z\|_\infty$. This also covers the disk comparator at its support edge.

For the proposed phase law, differentiable solutions preserve $|z(x,t)|$ pointwise. In the ambient real Banach space $C(D,\mathbb C)$, multiplication, conjugation, and $T_g$ give a locally Lipschitz vector field, with Lipschitz constant at most $|\omega|+3|\kappa|M^2$ on the ball $\|z\|_\infty\le M$. Local existence and uniqueness follow by Picard–Lindelöf. Unit modulus keeps the solution at sup norm one, allowing continuation by the uniform local bounds. Along each coordinate loop, continuity in time gives a homotopy through circle-valued maps and preserves that loop's winding number. These are the proposed analytical arguments for the review.

Uniform initial phase rotates with angular velocity $\omega-\kappa\sin\alpha$ for all three kernels. To check spatial weighting, take $z_q(x,0)=e^{2\pi i q\cdot x}$ with $q\in\mathbb Z^2$. The even kernel gives a real coefficient

$$
\lambda_q=\int_D g(u)\cos(2\pi q\cdot u)\,d\mu(u),
\qquad
\Omega_q=\omega-\kappa\lambda_q\sin\alpha .
$$

Test $q=0,(\pm1,0),(0,\pm1),(1,1)$. The equal axis rates and equality under reversal follow from kernel symmetry. For uniform coupling $\lambda_q=0$ for $q\ne0$. For the disk and $q\ne0$, the explicit reference is

$$
\lambda_q^{\mathrm{disk}}=
\frac{4}{\pi R^2}\int_0^R\sqrt{R^2-s^2}\cos(2\pi\lVert q\rVert_2s)\,ds .
$$

To obtain this formula, integrate a Euclidean disk of radius $R$ along the direction of $q$, use the chord length $2\sqrt{R^2-s^2}$, and use evenness to double the integral over $s\ge0$. These rotating solutions specify checks on the equation and kernel.

## Review and decisions

1. Review the normalized measure, phase law, and admissible initial fields. Check the sign, placement of $\kappa$, and preservation of unit modulus and two-dimensional winding.
2. Verify the primary and comparison kernels and their expected rotation rates. Track the earlier Batch 4 provenance separately from the explicit owner choice in ADR-111.
3. Check the written torus metric remediation and the kernel arguments, including normalization, representative independence, smoothness at zero separation and at the support edge, and the continuation argument.
4. Freeze the chosen contract and close every applicable internal adversarial finding before experimental Lean. Independent Gate 1 remains pending. [ADR-109](../../decisions/ADR-109.md) · [Review gates](../review-gates.md)

## Bounded review of the oscillator definitions

On 2026-11-23 the assistant reviewed the following experimental scope as the author acting in the internal review role. The scope consists of the Haar probability measure, the three kernel formulas, the integral mean field for continuous complex fields, and the pointwise phase velocity. The associated proofs may establish bump normalization-factor positivity, finite support, and the pointwise angular-velocity checks.

| Question | Disposition |
|---|---|
| Does a radius at zero make the profile undefined? | Encode the selected interval $0<R<1/2$ in the radius type. The normalized smooth coefficient is positive since the bump is continuous, nonnegative, and positive on $0\le s<1$. |
| Could a kernel use the library's product distance? | Both finite-range kernels use the named Euclidean torus distance. The independent uniform control is constant one. |
| Could the phase term count the coupling strength twice or reverse the lag? | The mean field uses kernel weights only. The phase velocity applies $\kappa$ once and uses a lag factor $\cos\alpha-i\sin\alpha$. When the mean equals a unit phase, the angular velocity is $\omega-\kappa\sin\alpha$. |
| Does a pointwise formula establish an oscillator flow? | The checked scope is the definitions and local properties. The disk and smooth kernel row integrals, regularity of the mean field, full solution existence and winding preservation, and discretization each require further proofs. |

The dispositions clear this smaller scope for experimental Lean under ADR-109. The larger oscillator flow remains in written review.

## Compiled scope

[PWFA.TorusOscillator](../../../PWFA/TorusOscillator.lean) defines normalized torus area, the smooth and disk kernels, the uniform control, and the pointwise right-hand side. Its theorems check area mass one, positivity of the bump integral, nonnegative finite-range kernels and their cutoff, the constant-field rotation law under uniform coupling, and pointwise tangency. The [extension audit](../../../scripts/audit-extensions.lean) checks the public statements and their axiom dependencies.

The next proof obligations are the disk and smooth kernel row integrals, regularity of the integral operator, and existence and uniqueness of the resulting continuous flow. The radius stays configurable.

## Internal review of the continuous mean field

On 2026-11-23 the assistant reviewed the following extension in the internal review role. The reviewer is also the author. This scope covers Euclidean distance continuity, translation invariance and integrability of the three selected kernels, and the passage from the pointwise formula to a continuous vector field.

| Question | Disposition |
|---|---|
| Can continuity of the disk mean be inferred from continuity of the kernel? | The disk kernel has a sharp boundary. Translate the integration variable with Haar invariance to write its mean as $\int g(u)z(x+u)\,d\mu(u)$, where $g(u)=G(0,u)$. Then continuity in $x$ follows by dominated convergence with integrable bound $\lvert g(u)\rvert\lVert z\rVert_\infty$. |
| Could a mean be formed from a nonintegrable row? | The generic operator requires an integrable centered row and exact translation invariance. The smooth row is continuous on the compact torus. The disk row is measurable and bounded, and the uniform row is constant. |
| Which estimate can the flow proof rely on? | The mean has sup norm bounded by the centered row's absolute integral times the field's sup norm. For a nonnegative row of mass one this is a contraction. The mass condition remains explicit until it is proved for the individual kernels. |

This clears the continuous mean field and its norm bound for experimental Lean under ADR-109. It leaves the radial row-mass calculations and continuous-time solution theorem as separate proof obligations.

[PWFA.TorusMeanField](../../../PWFA/TorusMeanField.lean) verifies those statements for all three selected kernels. It also represents the mean as a bounded complex-linear operator. The extension audit checks the disk-driven field's continuity, the uniform mean's norm bound, and axiom dependencies. [Extension audit](../../../scripts/audit-extensions.lean)

## Internal review of the velocity bound

On 2026-11-23 the assistant reviewed the Lipschitz estimate in the internal review role. The reviewer is also the author. Let $L$ be the integral of the absolute centered kernel row. The mean operator is linear and has norm at most $L$. For two fields $z,w$ in the sup norm ball of radius $M$, the mean difference is therefore at most $L\lVert z-w\rVert_\infty$. The phase lag has unit norm and taking the imaginary component is contractive. Expanding the difference of the two products in the angular velocity gives a speed difference bound of $2|\kappa|LM\lVert z-w\rVert_\infty$. Each speed has absolute value at most $|\omega|+|\kappa|LM^2$. Expanding the velocity difference gives the final Lipschitz constant $|\omega|+3|\kappa|LM^2$.

The internal review checked three failure cases. The estimate uses absolute row mass, so signed comparison kernels cannot cancel the bound. Disk continuity comes from the established mean-field operator. The ball controls both input fields, including the case $M=0$. This clears formalization of the bound under ADR-109. The bound supports a local existence proof and leaves the solution theorem as a separate obligation.

[PWFA.TorusVelocityBound](../../../PWFA/TorusVelocityBound.lean) proves the estimate and a Lipschitz bound on every closed sup norm ball.

## Internal review of local solutions

On 2026-11-23 the assistant reviewed a local existence and uniqueness scope as the author in the internal review role. The state space is the real Banach space of continuous complex-valued fields on the torus. The Lipschitz estimate on the zero-centered ball of radius $\lVert z_0\rVert_\infty+1$ applies on the unit ball about the initial field. The velocity at zero is zero, so on the larger ball its norm is bounded by the Lipschitz constant times the radius. A time half-width $1/(1+B)$ for any such bound $B$ is positive and keeps the Picard iteration within the unit ball. In particular the construction also works when $B=0$.

For two differentiable solutions with the same initial field, continuity places both in a common bounded ball for a sufficiently small time interval. The local uniqueness theorem applies there with the same Lipschitz constant. The review clears local existence and uniqueness under ADR-109. Pointwise phase preservation along the flow and global continuation remain distinct statements.
