# Bit-to-phase encoding with a moving origin anchor

Research note, 2026-11-24. The first experiment assigns sixteen bits to the centers of a 4×4 tiling. At recall time $t=40$, the score of a complex bit observation $u_j$ is the imaginary part of its value relative to the unit phase $a=z((0,0),t)$ at the origin. The owner has selected the layout and reference. The alphabet, mask semantics, observation operator, and thresholds are open. [Input geometry](../decisions/ADR-115.md) · [Recall anchor](../decisions/ADR-116.md) · [Benchmark](../experiments/benchmarks.md)

## What the research establishes

| Primary study | Result and relevance to PWFA |
|---|---|
| Zhao and Li, *European Journal of Applied Mathematics*, April 2025, online May 2024 | Equal bits have zero phase difference and unequal bits differ by half a turn in their finite oscillator model. Absolute orientation is free. They analyze stability with Hebbian coupling, a second harmonic, and an orthogonal extension of patterns. The antipodal geometry transfers to the symbol comparison. Applying the retrieval result would require their dynamical and pattern assumptions. [Introduction and three-pattern construction](https://doi.org/10.1017/S0956792524000238) |
| Fu, Li, Lin and Zhao, *SIAM Journal on Applied Mathematics*, 2025 | Adding higher-order self-dynamics changes the attraction basins and breaks the symmetry under a common phase rotation. This supplies an example where deciding how to represent a phase also changes the recovery problem. PWFA's origin-referenced score explicitly cancels a common rotation. [Model and abstract](https://doi.org/10.1137/24M1702477) |
| Hashimoto et al., *IEICE Transactions on Fundamentals*, May 2026 | Their memory uses one unit circle per feature and a softmax energy. Their simulations compare noise robustness and capacity for discrete and continuous phase patterns. Circular comparison is relevant to the sixteen observed phases. The model has a finite product of circles as its state space; PWFA also has a continuous spatial field between bit sites. [Model and numerical results](https://doi.org/10.1587/transfun.2025MAP0008) |
| Liu and Li, September 2026, arXiv preprint | In their higher-order Winfree models, every binary phase vector is a stationary state. Distinguishing stored patterns from other binary vectors requires a stability analysis; the authors also study auxiliary fields. This is a concrete reason to test discrimination at encoding and attraction under evolution separately. [Introduction and model](https://arxiv.org/abs/2609.14389) |
| Frady and Sommer, *PNAS*, 2019 | Their threshold phasor associative memory explicitly allows both unit-magnitude active states and zero-amplitude inactive states. This gives a precedent for missing activity in a larger state space. PWFA requires a unit phase everywhere, so an erasure can instead be represented in the cue or applied stimulus. [Threshold phasor model, equations 1–4](https://redwood.berkeley.edu/wp-content/uploads/2020/08/frady-sommer-tpam.pdf) |

## What follows from the PWFA readout

These calculations use the agreed decoder directly. Write $u_j=\rho a e^{i\delta}$, where $\rho=|u_j|$ and $\delta$ is the phase relative to the anchor when $\rho>0$. Then $s_j=\operatorname{Im}(\overline a u_j)=\rho\sin\delta$. A unit point observation gives $\rho=1$. A normalized, nonnegative spatial average of unit phases can have any magnitude from zero to one. [Decoder definition](../decisions/ADR-116.md)

For illustration, let bit zero use the negative offset and bit one the positive offset. Reversing those labels is an equivalent convention if the decoder reverses them too. The last column uses ideal point observations and a zero decision threshold.

| Relative phases for bits 0 and 1 | Ideal scores | Smallest relative angular perturbation reaching a tie |
|---|---|---|
| $0,\pi$ | $0,0$ | Already tied |
| $-\pi/4,+\pi/4$ | $-1/\sqrt{2},+1/\sqrt{2}$ | $45^\circ$ |
| $-\pi/2,+\pi/2$ | $-1,+1$ | $90^\circ$ |

The last pair maximizes the smaller absolute score and the angular distance to a sign boundary. For a relative phase error bounded by $\varepsilon<\pi/2$, its correct signed score has magnitude at least $\rho\cos\varepsilon$. With an abstention threshold $\tau$, a sufficient condition for confident decoding is $\rho\cos\varepsilon>\tau$. Differential error includes motion of the anchor relative to a bit. A common rotation cancels. At $\rho=0$ the score is zero and the phase angle is undefined.

A second check concerns the benchmark's antipodal patterns. With ideal symbols $v_j\in\{-i,+i\}$, the real part of the mean product $\overline{v_j}w_j$ for two encoded words is $1-2d/16$, where $d$ is their Hamming distance. Each agreeing bit contributes $+1$ and each disagreement contributes $-1$. A word and its complement thus score $+1$ and $-1$ against the original. Taking the absolute value of that overlap would give both a perfect match. The signed bit decoder preserves this distinction at the ideal codewords.

## From sixteen symbols to a continuous cue

A candidate construction uses a real smooth bump $b_j$ with peak one at each bit center. Start with a constant unit background $a_0$ and set

$$
z_{\mathrm{cue}}(x)=a_0\exp\!\left(i\theta\sum_{j=1}^{16}m_j\sigma_j b_j(x)\right).
$$

Here $\sigma_j\in\{-1,+1\}$ gives polarity and $m_j\in\{0,1\}$ is the input availability flag. With disjoint bump interiors and all bumps zero at the anchor, a present bit has the stated center phase and an omitted bit leaves the background there. Encoding into the real angle and then exponentiating preserves unit magnitude throughout the field. Peak normalization makes the angle at a bit center equal to the selected symbol angle. An encoder bump scaled to unit integral may have a much larger peak and can wrap that phase around the circle. The normalization used for coupling weights solves a different problem. For the fixed 4×4 tiling, neighboring centers are $1/4$ period apart, so a smooth radial bump supported within radius $1/8$ suffices for disjoint interiors. On an origin-aligned 16×8 grid the coarse-direction spacing is also $1/8$; a bump of that radius that vanishes at the edge contributes at only one sampled row through its center. This makes center sampling, cell averaging, and spatially pooled readout materially different tests. [Input centers](../decisions/ADR-115.md) · [Grid choices](../decisions/ADR-112.md)

The formula illustrates an initial cue. A driven stimulus over a finite interval would need its own time contract. A missing input has no bit-specific stimulus in this example. It still has an evolving unit phase, and its eventual decoded bit must be scored against the held-out target. A score of zero at recall can also arise from cancellation, independently of which inputs were masked. The candidate leaves the original winding of a constant background at zero because its angle has a globally defined real lift.

## Comparisons that would settle the design question

1. Run an encode/decode round trip before evolution, with the same bump sampling and observation operator intended for recall. Check clean patterns, complements, common rotations, and a perturbation at the origin alone. Score the full sixteen-bit word as well as individual bits.
2. Compare the antipodal pair $\pm\pi/2$ with a smaller symmetric offset such as $\pm\pi/4$ under the same mask, grid, bump, and observation rule. Holding the bump fixed, a smaller offset reduces the imposed phase gradients proportionally and also reduces initial readout margin.
3. At $t=40$, measure exact-word recall, abstentions, and masked-bit recovery on the same held-out cues. Report the anchored score and observation magnitude separately so spatial cancellation can be distinguished from phase drift. The clock-time result requires the learned dynamics and the recall protocol. The literature and these readout identities establish no PWFA recall rate.

These are research candidates for the next architecture discussion. [Encoding contract](../mathematics/encoding-decoding.md) · [Evidence register](evidence-register.md)
