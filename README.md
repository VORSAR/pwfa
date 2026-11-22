# PWFA

PWFA is a research architecture exploring persistent internal memory, external knowledge, and spatially distributed coupled oscillators.

**Status:** partially recovered research architecture. The canonical specification is this Git repository; earlier chat material is not authoritative unless reconciled and committed. [ADR-109](docs/decisions/ADR-109.md) permits *explicitly experimental*, role-separated internally reviewed Lean for bounded finding-closed slices. **Independent Gate 1 and certification remain unfulfilled.** The [phase-only algebra experiment](docs/verification/slices/phase-algebra-experiment.md) has Lean source and a CI workflow; compilation is **NOT VERIFIED** here. [Torus metric proofs](docs/verification/slices/spatial-metric-remediation.md) remain blocked by open findings.

Experimental Lean: `lean-toolchain` selects Lean v4.35.0, `lakefile.toml` selects mathlib v4.35.0, and `lake build` is the intended build check. Do not infer compilation or mathematical certification from the presence of source files.

Start with the [documentation index](docs/index.md). See [contributing and change control](CONTRIBUTING.md), the [decision index](docs/decisions/index.md), and [recovery status](docs/history/recovery-status.md).

Current releases and versions are tracked with Git tags, commits, and the [changelog](CHANGELOG.md), never document filename suffixes.
