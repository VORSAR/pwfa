# PWFA

PWFA is a research architecture exploring persistent internal memory, external knowledge, and spatially distributed coupled oscillators.

**Status:** partially recovered research architecture. This repository is the canonical specification. Experimental Lean under [ADR-109](docs/decisions/ADR-109.md) covers phase algebra and conjugation, Euclidean torus distance, local phase solutions, and exact disk-kernel normalization. **Independent Gate 1 is pending.** [Phase review packet](docs/verification/slices/phase-algebra-review-packet.md) · [Torus metric proofs](docs/verification/slices/spatial-metric-remediation.md) · [Oscillator baseline](docs/verification/slices/torus-oscillator-baseline.md).

Experimental Lean: `lean-toolchain` selects Lean v4.35.0, `lakefile.toml` selects mathlib v4.35.0, and `lake build` is the intended build check. Do not infer compilation or mathematical certification from the presence of source files.

Start with the [project roadmap](docs/roadmap.md) and [documentation index](docs/index.md). See [contributing and change control](CONTRIBUTING.md), the [decision index](docs/decisions/index.md), and [recovery status](docs/history/recovery-status.md).

Current releases and versions are tracked with Git tags, commits, and the [changelog](CHANGELOG.md), never document filename suffixes.
