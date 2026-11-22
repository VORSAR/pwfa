# PWFA documentation index

This repository is the authoritative, version-controlled source for PWFA. No monolithic master document is maintained.

## Research scope
- [Problem statement](vision/problem-statement.md)
- [Research objectives](vision/objectives.md)
- [Testable hypotheses](vision/hypotheses.md)

## System architecture
- [Overview](architecture/overview.md)
- [Components](architecture/components.md)
- [Interfaces and contracts](architecture/interfaces.md)
- [Data flow](architecture/data-flow.md)
- [Design invariants](architecture/design-invariants.md)

## Mathematical specification
- [State space](mathematics/state-space.md)
- [Evolution and coupling](mathematics/evolution.md)
- [Memory and homeostasis](mathematics/memory.md)
- [Encoding and decoding](mathematics/encoding-decoding.md)
- [Numerical methods](mathematics/numerical-methods.md)

## Experiments
- [Experimental methodology](experiments/methodology.md)
- [Primary benchmark](experiments/benchmarks.md)
- [Controls and baselines](experiments/baselines.md)

## Decisions, evidence, and verification
- [ADR index](decisions/index.md)
- [ADR policy](decisions/README.md)
- [Evidence register](research/evidence-register.md)
- [Outstanding research questions](research/open-questions.md)
- [Proof obligations](verification/proof-obligations.md)
- [Requirements traceability](verification/requirements-matrix.md)
- [Current experimental and independent review policy](verification/review-gates.md)
- [Experimental phase algebra slice](verification/slices/phase-algebra-experiment.md)
- [Phase source audit](verification/slices/phase-algebra-internal-review.md)
- [Blocked metric remediation](verification/slices/spatial-metric-remediation.md)
- [Role-separated hostile findings](verification/slices/spatial-phase-foundation-internal-review.md)

## Project history and governance
- [Glossary](glossary.md)
- [Recovery status](history/recovery-status.md)
- [Immutable original recovery snapshot](history/recovery-original.md)
- [Change policy](../CONTRIBUTING.md)
- [Changelog](../CHANGELOG.md)

**Evidence caveat:** Most original mathematical definitions and research references have **NOT BEEN RECOVERED**. These documents separate recovered choices from implementation-ready specifications.
