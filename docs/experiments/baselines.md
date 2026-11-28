# Controls, baselines and ablations

Recovered experiment controls:

- [ADR-076a](../decisions/ADR-076a.md): compare the historical ring's primary spatial contrast `a=0.8` with `a=0` and `a=0.4` for winding values `0/±1`. The [ring reference](../mathematics/ring-oscillator-reference.md) gives exact expected rotation rates.
- [ADR-096](../decisions/ADR-096.md): reverse-order ablation of sequential memory training.
- [ADR-099](../decisions/ADR-099.md): antipodal, phase, radius, orientation, load, resolution and bit-length sensitivities.

The preregistered **external comparator for exact recall remains unspecified**, as does the matched resource budget. Without them, the [ADR-100](../decisions/ADR-100.md) success threshold cannot be evaluated. The [vision statement](../vision/vision-statement.md) sets the standard that choice must meet: measurable advantages against established computational baselines.

The [torus oscillator draft](../verification/slices/torus-oscillator-baseline.md) uses same-radius disk coupling and a separate uniform control to compare structural phase dynamics before learning.

No results have been recovered.

[Benchmark](benchmarks.md) · [Methodology](methodology.md) · [Evidence register](../research/evidence-register.md).
