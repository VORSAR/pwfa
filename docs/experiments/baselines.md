# Controls, baselines and ablations

Recovered experiment controls:

- [ADR-076a](../decisions/ADR-076a.md): compare the historical ring's primary spatial contrast `a=0.8` with `a=0` and `a=0.4` for winding values `0/±1`. The [ring reference](../mathematics/ring-oscillator-reference.md) gives exact expected rotation rates.
- [ADR-096](../decisions/ADR-096.md): reverse-order ablation of sequential memory training.
- [ADR-099](../decisions/ADR-099.md): antipodal, phase, radius, orientation, load, resolution and bit-length sensitivities.

The external comparator for exact recall is a classical Hopfield network on the same pair memory, with nearest-word lookup reported beside it. Its **matched resource budget and schedule remain unspecified**, and without them the [ADR-100](../decisions/ADR-100.md) success threshold cannot be evaluated. The [vision statement](../vision/vision-statement.md) asks for measurable advantages against established computational baselines, and this comparator is one. [Comparator decision](../decisions/ADR-133.md) · [Reference rates](../research/learned-retrieval-at-time-zero.md#static-references-on-the-two-development-libraries)

The [torus oscillator draft](../verification/slices/torus-oscillator-baseline.md) uses same-radius disk coupling and a separate uniform control to compare structural phase dynamics before learning.

No results have been recovered.

[Benchmark](benchmarks.md) · [Methodology](methodology.md) · [Evidence register](../research/evidence-register.md).
