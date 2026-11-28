# PWFA

PWFA (Persistent Wave-Field Architecture) is a research architecture exploring persistent internal memory, external knowledge, and spatially distributed coupled oscillators.

## Vision

The original vision of **Persistent Wave-Field Architecture (PWFA)** is to explore a fundamentally different foundation for artificial intelligence, inspired by the brain's continuous, distributed, and persistent information processing. Rather than treating intelligence as a sequence of discrete computations, PWFA investigates whether interacting, multidimensional wave fields can simultaneously represent information, perform computation, form associative memories, and retrieve knowledge. Its central hypothesis is that information can exist as evolving spatial and temporal patterns, with learning emerging through changes in the relationships between those patterns. The ultimate ambition is an architecture with persistent internal state, capable of integrating external knowledge, adapting through experience, and developing increasingly complex computational behavior without requiring every operation to be explicitly orchestrated.

**PWFA is not intended to be another large language model, transformer architecture, conventional neural network, or simulation of biological neurons.** It does not aim to reproduce the brain's anatomy, imitate consciousness, or claim biological equivalence. Nor is it simply a wave-based implementation of existing neural-network algorithms, a conventional database with a different retrieval mechanism, or a collection of oscillators producing interesting mathematical behavior. Those mechanisms may serve as research tools, but they are not the objective. PWFA seeks to determine whether persistent wave dynamics constitute a genuinely useful computational primitive, with learning, memory, and information processing arising from the architecture's underlying dynamics. Its validity must come from mathematical consistency, reproducible experiments, and measurable advantages against established computational baselines—not biological analogies or theoretical elegance alone.

Owner statement, recorded on 2026-11-28. [Provenance and how the repository relates to it](docs/vision/vision-statement.md)

## Current state

**Status:** partially recovered research architecture. This repository is the canonical specification. Experimental Lean under [ADR-109](docs/decisions/ADR-109.md) covers phase algebra, periodic Euclidean geometry, global unit-phase solutions and their windings, normalized torus kernels, exact rotating waves, and the historical ring controls. **Independent Gate 1 is pending.** [Phase review packet](docs/verification/slices/phase-algebra-review-packet.md) · [Torus metric proofs](docs/verification/slices/spatial-metric-remediation.md) · [Oscillator baseline](docs/verification/slices/torus-oscillator-baseline.md).

Experimental Lean: `lean-toolchain` selects Lean v4.35.0, `lakefile.toml` selects mathlib v4.35.0, and `lake build` is the intended build check. Do not infer compilation or mathematical certification from the presence of source files.

Research and architecture recommendations use small Lean experiments to check mathematical assumptions. [Research workflow](CONTRIBUTING.md#lean-experiments-for-research-decisions) · [Worked phase-readout example](docs/research/bit-to-phase-map.md)

Start with the [project roadmap](docs/roadmap.md) and [documentation index](docs/index.md). See [contributing and change control](CONTRIBUTING.md), the [decision index](docs/decisions/index.md), and [recovery status](docs/history/recovery-status.md).

Current releases and versions are tracked with Git tags, commits, and the [changelog](CHANGELOG.md), never document filename suffixes.
