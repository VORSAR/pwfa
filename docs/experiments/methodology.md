# Experimental methodology

**Status:** recovered settings only; protocol not yet preregistered or independently reviewed.

Training from [ADR-096](../decisions/ADR-096.md): patterns presented sequentially, learned memory and homeostasis carried, oscillator/trace reset, deterministic order, reverse-order ablation.

Broad sweeps from [ADR-076b](../decisions/ADR-076b.md): grid sizes 128/256/512, 16/32-bit patterns, loads up to 16, and 100 libraries.

Before running a benchmark, define: generator and seeds, held-out cue formation, bit-corruption algorithm, no-overlap rounding, exact recall measure, resource budget, confidence interval, statistical cluster, and treatment of failed/ambiguous retrievals.

Keep preregistered protocols distinct from post-hoc analysis. Never replace a preregistered protocol silently; record amendments.

[Primary benchmark](benchmarks.md) · [Baselines](baselines.md) · [Evidence register](../research/evidence-register.md).
