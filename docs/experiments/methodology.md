# Experimental methodology

**Status:** recovered settings only; protocol not yet preregistered or independently reviewed.

Training from [ADR-096](../decisions/ADR-096.md): patterns presented sequentially, learned memory and homeostasis carried, oscillator/trace reset, deterministic order, reverse-order ablation.

Broad sweeps from [ADR-076b](../decisions/ADR-076b.md): grid sizes 128/256/512, 16/32-bit patterns, loads up to 16, and 100 libraries.

Before running a benchmark, define: generator and seeds, held-out cue formation, bit-corruption algorithm, no-overlap rounding, across-library aggregation, resource budget, confidence interval, statistical cluster, and decoder ambiguity threshold. [ADR-122](../decisions/ADR-122.md) defines the exact-word denominator and reporting of abstentions and failed retrievals.

Keep preregistered protocols distinct from post-hoc analysis. Never replace a preregistered protocol silently; record amendments.

[Primary benchmark](benchmarks.md) · [Baselines](baselines.md) · [Evidence register](../research/evidence-register.md).
