# Preliminary hostile architecture review

- **Date:** 2026-11-22
- **Reviewer:** ChatGPT assistant, acting as an internal adversarial critic
- **Status:** Preliminary review / NOT independent / NOT Gate 1
- **Baseline:** Current documented decisions [ADR-101](../decisions/ADR-101.md) through [ADR-105](../decisions/ADR-105.md), recovered historical ADRs, and incomplete core mathematics
- **Authority:** Findings inform architecture prioritization only. They do not approve executable Lean implementation or satisfy [ADR-046](../decisions/ADR-046.md) and [ADR-055](../decisions/ADR-055.md).

## Findings

| ID | Severity | Finding | Direct evidence | Closure requirements |
|---|---|---|---|---|
| PRE-001 | Critical | Governing phase evolution missing; topology/kernel choices do not specify dynamics | [Evolution](../mathematics/evolution.md) | Candidate equation, domain, kernel, regularity, initial conditions, mathematical proof obligations, independent review |
| PRE-002 | Critical | Complete pairwise learned-memory evolution missing; persistence and recall are not specified | [Memory](../mathematics/memory.md), [ADR-093](../decisions/ADR-093.md) | Exact memory and trace dynamics, training and recall events, counterexamples and testable retention/recall hypothesis |
| PRE-003 | High | Historical 1D encoder, sample-size and winding conventions are incompatible with unqualified reuse under new 2D domain | [ADR-102](../decisions/ADR-102.md), [Encoding](../mathematics/encoding-decoding.md), [Numerics](../mathematics/numerical-methods.md) | Explicit 2D map or distinguished 1D experiment; specify N per-axis/total, spatial supports, winding vector and benchmark comparability |
| PRE-004 | High | Dense pairwise memory on per-axis N×N grid requires O(N^4) entries | [ADR-102](../decisions/ADR-102.md), [ADR-098](../decisions/ADR-098.md), [ADR-076b](../decisions/ADR-076b.md) | Choose numerical representation that does not silently sparsify required pairwise learning; resource and fidelity constraints |
| PRE-005 | High | Homeostatic driving signal Q and admissible h domain undefined; gain denominator 1+h may vanish | [Memory](../mathematics/memory.md), [ADR-093](../decisions/ADR-093.md), [ADR-094](../decisions/ADR-094.md) | Define Q and h domain, initial values, invariants and hypotheses preventing singularity |
| PRE-006 | High | Exact reproducible train-to-recall evaluation and comparator not specified | [Methodology](../experiments/methodology.md), [ADR-099](../decisions/ADR-099.md), [ADR-100](../decisions/ADR-100.md) | End-to-end deterministic experiment contract with predefined success/failure and matched comparator |
| PRE-007 | High | Smooth compact kernel profile and normalization have owner selections from Batch 4 but were not yet registered as ADRs at audit baseline | [Decision index](../decisions/index.md), [Evolution](../mathematics/evolution.md) | Record user selections with contemporaneous provenance; choose support radius and exact formula separately |
| PRE-008 | Governance | Current Gate-1 policy forbids executable Lean before all independent Gate-1 findings close; a pre-gate formal sandbox requires an explicit policy decision | [Review gates](review-gates.md), [ADR-046](../decisions/ADR-046.md), [ADR-055](../decisions/ADR-055.md), [Contributing](../../CONTRIBUTING.md) | Either comply with existing gate and restrict work to non-executable specifications, or owner explicitly chooses and documents a new superseding ADR and revised review regime |

## Numeric scale check

For **N samples per spatial axis**, a 2D field has N² oscillator locations and a dense pairwise memory has (N²)²=N⁴ scalar entries. At 8 bytes per entry:

| Per-axis N | Oscillators | Entries | Raw storage |
|---:|---:|---:|---:|
| 128 | 16,384 | 268,435,456 | 2 GiB |
| 256 | 65,536 | 4,294,967,296 | 32 GiB |
| 512 | 262,144 | 68,719,476,736 | 512 GiB |

The calculation assumes one 64-bit scalar per pair, no additional allocation, and N interpreted **per axis**. This N interpretation has **not** been approved; the figures are risk scenarios, not current implementation requirements. No conclusion about computational feasibility of factorized, convolutional, low-rank or operator-form representations follows without proof of intended semantics.

## Suggested iterative route (not yet approved)

1. Complete one **bounded** mathematically closed vertical-slice contract and its falsifiable property.
2. Submit that narrow contract to an **independent** pre-implementation hostile review; resolve every finding within that review scope.
3. If the owner **formally supersedes** conflicting Gate-1 policy, permit only executable formalization covered by that independently closed scope; maintain Gate 2 and all unreleased system claims as open.
4. Iterate: new contract → independent hostile review → closure → Lean formalization → empirical evaluation, with version-controlled evidence.
5. Never claim that a narrow slice closes Gate 1 for the entire PWFA model or that a toy proof establishes associative recall.

## Open governance decision

Options for owner:
- **A — Scope-limited independent Gate 1 per vertical slice:** explicitly supersede current monolithic preimplementation gate, preserve mandatory independent review and closure for each slice before its implementation.
- **B — Original global Gate 1 unchanged:** no executable Lean until entire architecture passes.
- **C — Pre-gate executable sandbox:** explicitly change policy to permit isolated provisional Lean investigations before review; higher validation and provenance risk.

**Review conclusion:** Provisional vertical-slice development is technically feasible, but current governance blocks executable Lean. No such policy change has been approved in this document.

## References

[Review gates](review-gates.md) · [Proof obligations](proof-obligations.md) · [Core gap register](../research/core-gap-register.md) · [State space](../mathematics/state-space.md) · [Memory](../mathematics/memory.md) · [Evolution](../mathematics/evolution.md).
