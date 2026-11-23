# Candidate flat torus oscillator baseline

**Status:** Written candidate for review. The flat torus, unit-complex phase, radial coupling geometry, and periodic Euclidean distance are owner decisions. The phase law, measure, and kernel details below are proposed for the 2D baseline. [ADR-102](../../decisions/ADR-102.md) · [ADR-103](../../decisions/ADR-103.md) · [ADR-104](../../decisions/ADR-104.md) · [ADR-105](../../decisions/ADR-105.md)

## State and phase equation

Let $D=(\mathbb R/\mathbb Z)^2$, let $d_T$ be the shortest periodic Euclidean distance, and use uniform area measure $\mu(D)=1$. Take any continuous unit-complex initial field $z_0:D\to S^1$, where $S^1=\{w\in\mathbb C:|w|=1\}$. The phase-only baseline uses constant natural frequency $\omega$, coupling strength $\kappa$, and phase lag $\alpha$. Input, learned coupling, homeostasis, encoding, and recall are outside this contract.

For a nonnegative radial profile $k$, set $G(x,y)=k(d_T(x,y))$ and require $\int_D G(x,y)\,d\mu(y)=1$ for each $x$. The candidate phase law is

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

Use $0<R<\tfrac12$ for the finite-range candidates. Each supported disk then lies in a region with unambiguous Euclidean displacement. Its area is $\pi R^2$.

### Published disk comparator

$$
G_R^{\mathrm{disk}}(x,y)=
\frac{\mathbf{1}_{\{d_T(x,y)<R\}}}{\pi R^2}.
$$

Omel’chenko and colleagues use circular periodic neighborhoods with equal weights and give the normalized continuum disk average. Their continuum variable describes local coherence, with the disk geometry supplying the comparator here. The sharp support edge gives a comparison at the same radius and total weight as a smooth kernel. [Omel’chenko et al. (2012), Eqs. 1 and 6](https://webdoc.sub.gwdg.de/ebook/serien/e/wias/2012/wias_preprints_1682.pdf)

### Proposed smooth profile

For $s\ge0$, let $b(s)=\exp[-1/(1-s)]$ for $s<1$ and $b(s)=0$ for $s\ge1$. One explicit candidate is

$$
G_R^{\mathrm{smooth}}(x,y)=
C_R\,b\!\left(\frac{d_T(x,y)^2}{R^2}\right),
\qquad
C_R^{-1}=\pi R^2\int_0^1 b(s)\,ds .
$$

Translation invariance makes the normalizer independent of $x$. Within the support the squared distance is squared Euclidean displacement, including at zero separation. The bump and all its derivatives vanish at the support edge, and the profile is zero near the torus cut locus. The displayed profile and any nominal radius require a 2D model decision. [Metric remediation](spatial-metric-remediation.md) · [Batch 4 evidence gap](../preliminary-hostile-review.md#findings)

### Uniform control

Use $G_{\mathrm{uniform}}(x,y)=1$ as the proposed all-to-all control. The historical $a$-sweep belongs to the ring reference. A 2D mixture $(1-a)+aG_R^{\mathrm{smooth}}$ would preserve the uniform endpoint and give all pairs positive background weight when $0\le a<1$. The finite-range candidate and separate uniform control let us test the effect of removing distant interactions. [Historical ring reference](../../mathematics/ring-oscillator-reference.md)

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

1. Confirm the proposed normalized measure, transfer of the phase law, and admissible initial fields. Check the sign, placement of $\kappa$, and preservation of unit modulus and two-dimensional winding.
2. Reconcile the exact profile and normalization with the unverified Batch 4 record. Select the smooth formula and radius policy, then confirm the same-radius disk and independent uniform controls.
3. Verify the two outstanding torus metric findings and the kernel arguments, including normalization, representative independence, smoothness at zero separation and at the support edge, and the continuation argument.
4. Freeze the chosen contract and close every applicable internal adversarial finding before experimental Lean. Independent Gate 1 remains pending. [ADR-109](../../decisions/ADR-109.md) · [Review gates](../review-gates.md)
