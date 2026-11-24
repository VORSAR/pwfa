# Historical ring oscillator reference

**Status:** Recovered historical reference, recorded on 2026-11-23. The equations below fix the historical one-dimensional baseline and its unforced test cases. Independent review is pending. [ADR-076a](../decisions/ADR-076a.md) · [Evidence register](../research/evidence-register.md)

## Domain and structural kernel

The domain is the unit ring $\mathbb T=\mathbb R/\mathbb Z$, with uniform measure $\mu(\mathbb T)=1$. An initial field is $z_0\in C(\mathbb T,S^1)$, where $S^1=\{w\in\mathbb C:|w|=1\}$. The recovered cosine kernel is

$$
K_{\kappa,a}(x,y)=\kappa[1+a\cos(2\pi(x-y))].
$$

The coefficient $\kappa$ sets the row integral, and $a$ sets spatial contrast. The recovered primary setting is $\kappa=1$, $a=0.8$, $\alpha=\pi/2-0.1$, and $\omega=0$. At $a=0$ all positions have equal weight. At $a=0.4$ the weights range from $0.6$ to $1.4$, and at $a=0.8$ they range from $0.2$ to $1.8$. Normalization follows from the zero integral of the cosine over one period.

The historical evidence is the PWFA master, WritingBlock 57318, v0.24 section 6, v0.25 sections 4–5, and v0.26 sections 3–4. Abrams and Strogatz give the same cosine shape in angular coordinates in Eqs. 1–2, with the corresponding change in density for the spatial measure. [Evidence register](../research/evidence-register.md) · [Abrams and Strogatz (2004)](https://arxiv.org/pdf/nlin/0407045)

## Structural phase law

The historical structural angular velocity includes natural frequency $\omega(x)$ and a prescribed input $I(x,t)$. The unforced reference sets $I=0$ and uses the recovered constant $\omega$. It has no learned contribution.

$$
\partial_t z(x,t)=i z(x,t)\left[
\omega+\int_{\mathbb T}K_{\kappa,a}(x,y)
\operatorname{Im}\!\left(e^{-i\alpha}\overline{z(x,t)}z(y,t)\right)d\mu(y)
\right].
$$

The kernel already includes $\kappa$. The real angular velocity gives $\partial_t|z(x,t)|^2=0$ for differentiable solutions. The integral uses the circle-valued field directly and accommodates nonzero winding.

## Exact winding checks

Take $z(x,0)=e^{2\pi i n x}$, using the recovered controls $n\in\{0,+1,-1\}$. Convolution with the even ring kernel multiplies this Fourier mode by $\kappa c_n$, where $c_0=1$ and $c_{\pm1}=a/2$. The field keeps its spatial phase differences and rotates at angular velocity $\Omega_n=\omega-\kappa c_n\sin\alpha$. This follows by substitution in the structural phase law. With the recovered $\kappa,\alpha,\omega$, the expected rates are:

| Spatial contrast $a$ | $\Omega_0$ | $\Omega_{+1}=\Omega_{-1}$ |
|---|---|---|
| $0$ | $-0.995004$ | $0$ |
| $0.4$ | $-0.995004$ | $-0.199001$ |
| $0.8$ | $-0.995004$ | $-0.398002$ |

These values follow from the equation and provide numerical regression targets. The [torus oscillator draft](../verification/slices/torus-oscillator-baseline.md) uses the same phase-lag convention with its own radial kernel and two-dimensional test modes.

## Internal review of the historical controls

At revision `764f30d`, Codex (GPT-6) reviewed roadmap item 7 as its author in the internal reviewer role. RING-01 requires the one-dimensional period and the actual cosine of the difference in the recovered kernel. Use Haar probability on the unit circle and check the kernel on arbitrary real representatives. RING-02 requires the row mass to equal the coupling strength for any contrast and any center. Evaluate the three Fourier terms with their exact signs and the factor of one half in the first harmonic. RING-03 requires the rotating modes to solve the historical unforced law with coupling inside the integral. Check the derivative against that integral and specialize windings zero and both first harmonics at all three historical contrasts using exact real values. These dispositions clear the experimental reference calculation under ADR-109.
