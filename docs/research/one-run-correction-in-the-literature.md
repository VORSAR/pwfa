# One-run correction in the oscillator-memory literature

On 2026-11-28 the owner asked for a check of the research literature for a possible approach. One retrieval run had just returned every presented bit unchanged at both bit alphabets. This note records a targeted check of primary sources on phase-oscillator memories, and a Lean evaluation of what each approach would do to a single bit in the PWFA learned interaction. [One-run results](../experiments/one-run-recall-at-the-comparison-alphabet.md#results-at-t40) · [Time-zero identities](learned-retrieval-at-time-zero.md)

## What the sources say

**1. The present learned interaction is a known design with a documented weakness.** With structural coupling off, PWFA retrieval is a network of identical phase oscillators with Hebbian first-harmonic coupling. Heger and Krischer describe that design as having no well-separated fixed points for the memorized patterns. They describe one global attractor made of lines of neutrally stable fixed points that connect every memorized pattern with every other. In their account recognition "still works" on short timescales, because the state first relaxes onto that attractor close to the most similar pattern. It then drifts under perturbations, and recognition cannot be guaranteed. A 2026 survey states that exact memory patterns in the Hebbian Kuramoto memory are unstable when more than two are stored. [Heger & Krischer (2016), introduction](https://arxiv.org/abs/1604.02085) · [Allibhoy & Pasqualetti (2026), §5.2](https://arxiv.org/abs/2610.39703)

**2. The standard remedy is a second-harmonic term.** Nishikawa, Lai and Hoppensteadt add a second-order Fourier mode to the coupling function. Their abstract reports that it controls the stability of solutions for all patterns, separates memory patterns from other states, and gives a capacity that scales with the number of neurons as in the Hopfield model, with a prefactor set by the strength of the added mode. The survey gives the capacity as $2\epsilon^2N/\log N$ and attributes it to the same authors. It also warns that a coefficient that is too large makes corrupted memories stable as well. [Nishikawa, Lai & Hoppensteadt (2004)](https://doi.org/10.1103/PhysRevLett.92.108101) · [Allibhoy & Pasqualetti (2026), §5.3](https://arxiv.org/abs/2610.39703)

Li, Zhao and Zhou analyse this model for binary patterns. With two memories and a coefficient below a stated threshold, the two memories and their mirror images are the only stable binary patterns. The authors show that this result does not extend to three memories. Their basin estimate is conservative: they note that a pattern obtained by flipping some components of a memory lies outside it. For a general set of patterns they store two candidates at a time and repeat rounds of pairwise runs from the defective pattern. [Li, Zhao & Zhou, §2–§4](https://arxiv.org/abs/2505.12223)

**3. A design with isolated resting states and a basin bound exists.** Heger and Krischer propose two mirrored oscillator networks whose global coupling is modulated in time by signals from the other network. Its possible outputs are isolated attractors, and a lower bound on their basins gives a criterion for guaranteed recognition. The coupling matrix need not be wired pair by pair. In their example with 49 pixels and three non-orthogonal memories, a pattern with six wrong pixels is recognised and one with eleven is not. The design builds on Hoppensteadt and Izhikevich, who connect oscillators of different frequencies weakly through a common medium and let an external input impose the effective connectivity. [Heger & Krischer (2016), §II–§III](https://arxiv.org/abs/1604.02085) · [Hoppensteadt & Izhikevich (1999)](https://doi.org/10.1103/PhysRevLett.82.2983)

**4. Oscillator Ising machines use the same two-position idea.** Wang and Roychowdhury report that under sub-harmonic injection locking the phase dynamics follow a Lyapunov function closely related to the Ising Hamiltonian of the coupling graph. The survey writes that locking term as a second harmonic of each oscillator's own phase. [Wang & Roychowdhury (2019)](https://arxiv.org/abs/1903.07163)

**5. Spatial media.** Houben derives amplitude equations for associative memory patterns in spatially distributed systems with non-local interactions. The abstract describes pattern completion and selection unfolding in space and time, and propagating patterning fronts sustained by short-range connections. This was the closest match found to memory recall in a wave-like medium. The search found no source that combines an extended oscillatory medium, learned non-local coupling and pattern completion in one model. [Houben (2025)](https://arxiv.org/abs/2506.13576)

**6. Capacity beyond the Hopfield scaling.** Guo and colleagues report a Kuramoto-based memory whose capacity grows exponentially with network size and which has no spurious memories. Only the abstract was checked. [Guo et al. (2025)](https://arxiv.org/abs/2504.03102)

## What Lean checks in the PWFA setting

The check frees one bit at angle $\theta$ from the origin and holds every other bit center at ±90°. Shoulder and background sites are left out, and no trajectory is followed. Write $h$ for the memory row applied to the neighbours' symbols, which is the evidence a Hopfield update uses.

- **First harmonic.** The pull on the free bit is $h\cos\theta$. It vanishes at ±90°. Displaced from its position, a bit that agrees with its evidence returns, and a bit that opposes its evidence moves away. A wrong bit is therefore on a tipping point. This agrees with the report that recognition works on short timescales.
- **Gain as a clock.** The learned gain multiplies the whole learned velocity. With no structural coupling a larger gain acts as a faster clock.
- **Second harmonic.** A second-harmonic pull from a held neighbour does not depend on that neighbour's symbol. It draws the free bit toward +90° or −90°. With total strength $c$, a bit displaced by $u$ from a wrong position still returns to it whenever its evidence is weaker than $2c\cos u$. A term that is too strong freezes mistakes, as the survey warns.
- **Mirrored design.** For one free bit, the effective rate in Heger and Krischer's equation (5) equals the first-harmonic pull plus a second-harmonic term of strength $M/4$ for $M$ stored words. At the level of a single bit it is the second-harmonic remedy with a built-in strength.

[Lean statements](../../scripts/experiments/bit-among-fixed-neighbours.lean)

## Reading for the next step

The present design should let a wrong bit roll over if the run lasts long enough. At learned gain ¼ the archived runs stop at $t=40$ with flipped bits close to where they started. The gain law recovered in ADR-093 carries the factor ¼, so a larger gain needs an owner decision. If one run then behaves like asynchronous Hopfield recall, the static reference on the same cues is 9/16 and 12/16 words, against 0/16 measured. That reference is a classical calculation and no prediction of the oscillator. The sources also say what to expect afterwards: with first-harmonic coupling alone the finished word has no isolated resting state. The second-harmonic term and the mirrored design address that, at the cost of a new strength to choose or a larger redesign. [Static references](learned-retrieval-at-time-zero.md#static-references-on-the-two-development-libraries) · [Gain law](../decisions/ADR-093.md)

## How each source was checked

| Source | Checked on 2026-11-28 | Used for |
|---|---|---|
| Heger & Krischer, *A robust autoassociative memory with coupled networks of Kuramoto-type oscillators*, arXiv:1604.02085, Phys. Rev. E 94, 022309 | Author manuscript, pages 1–4 read | Weakness of the Hebbian design, mirrored design, equation (5), examples |
| Nishikawa, Lai & Hoppensteadt, Phys. Rev. Lett. 92, 108101 (2004) | Abstract and bibliographic record | Second-order mode and capacity scaling |
| Li, Zhao & Zhou, arXiv:2505.12223 | Author manuscript, sections 1–4 and conclusion | Model equation, two-memory threshold, three-memory limit, basin remark, pairwise procedure |
| Allibhoy & Pasqualetti, arXiv:2610.39703 | Author manuscript, sections 5.2–5.3 | Secondary account of instability, capacity formula and its attribution |
| Hoppensteadt & Izhikevich, Phys. Rev. Lett. 82, 2983 (1999) | Abstract | Common medium and dynamic connectivity |
| Wang & Roychowdhury, arXiv:1903.07163 | Abstract | Sub-harmonic injection locking and Lyapunov function |
| Houben, arXiv:2506.13576 | Abstract | Memory patterns in spatially distributed systems |
| Guo et al., arXiv:2504.03102 | Abstract | Exponential-capacity claim |

The capacity formula is quoted from the survey, which cites a second 2004 paper by Nishikawa, Hoppensteadt and Lai that was not opened. The search covered English-language sources reachable on that day and makes no claim of completeness. [Evidence register](evidence-register.md)

## Bounded internal review

On 2026-11-28, against `553849b`, the assistant, acting as internal reviewer, closed the following findings for the Lean file before it was written. The review is internal and role-separated. No outside reviewer checked it, and independent Gate 1 remains open. [Review policy](../decisions/ADR-109.md) · [Reviewer identity](../decisions/ADR-132.md)

- **OB-01, idealisation.** One bit is free and every other bit center is held at ±90°. Shoulder sites, background sites and the motion of the other bits are left out. State this in the module comment and claim nothing about a trajectory or a time to correct.
- **OB-02, meaning of return.** Define return to a position by the sign of the velocity toward it for a displacement between 0° and 90°, and state the result as an exact identity. Show both consequences: first harmonic alone follows the evidence, and a second-harmonic term can hold a wrong bit.
- **OB-03, the published equation.** Use equation (5) of Heger and Krischer with the other bits held at their two values and the self term equal to the number of stored words. State the change of angle from their phase difference to the PWFA angle and drop only the positive prefactor. Claim nothing about their basin bound.
- **OB-04, sources.** Cite only sources opened on the day. Mark each as abstract or manuscript, mark secondary attributions, and keep quotations short.

**Post-implementation check.** The file compiles with warnings treated as errors and contains no admitted proof. Its eight statements depend only on the three standard axioms.

## Reproduce

```sh
lake lean scripts/experiments/bit-among-fixed-neighbours.lean -- -DwarningAsError=true
```
