# Adversarial review gates and experimental authorization

## Current governance — [ADR-109](../decisions/ADR-109.md)

The owner selected a **two-person role-separated internal hostile review** for experimental Lean development. Within each tightly bounded slice, the assistant may design, switch to an adversarial-review role, record every finding, remediate all *applicable* findings, and explicitly authorize **experimental** formalization.

This is **not independent external review** and must never be described as such.

The historical [ADR-046](../decisions/ADR-046.md) and [ADR-055](../decisions/ADR-055.md) remain unchanged as historical decisions. [ADR-108](../decisions/ADR-108.md) first introduced slice-level independent reviews; ADR-109 supersedes its external independence requirement **only for experimental authorization**, not for independent certification.

## Experimental implementation requirements

1. Freeze a narrow mathematical contract and enumerate precisely stated theorem obligations.
2. Document adversarial findings and their dispositions. Resolve **every in-scope finding**, including documentation problems, before experimental Lean work.
3. Keep out-of-scope findings visible and their respective slices blocked. **No scope leakage.**
4. Record the assistant-reviewer identity, review limits, owner governance authorization, contract SHA and experimental approval.
5. Pin Lean and mathlib, run compilation and check for `sorry`, `admit`, unsupported axioms and mismatches. Declare unexecuted checks **UNVERIFIED**.
6. After the first code, re-review the actual statements against the contract.
7. Require a distinct outside reviewer or a separately documented external audit before claiming **independent mathematical certification**. A tool-generated proof is not evidence of physical memory or recall.

## Slice statuses

- [SLICE-001-PHASE](slices/phase-algebra-experiment.md): internal review scope-cleared for **experimental algebraic Lean**, build status UNVERIFIED.
- [SLICE-001-METRIC](slices/spatial-metric-remediation.md): IR-001 and IR-002 OPEN; **metric executable Lean BLOCKED**.
- [Parent SLICE-001](slices/spatial-phase-foundation.md): full mathematical scope NOT independently reviewed or closed.
- [Review request #8](https://github.com/VORSAR/pwfa/issues/8): retained as a record of the unmet external-review option; the owner coordinates the two-person project.
- Whole PWFA: no independent certification, no validated memory/learning behavior, no system-level performance claims.

## Independent certification and Gate 2

A role-separated hostile review is not independent Gate 1. After each first reference implementation, perform an adversarial code-conformance review (internal). Independent certification and full-system claims require their own documented external scrutiny. The original independent Gate-2 objective cannot be claimed by assistant self-review.

[ADR-109](../decisions/ADR-109.md) · [Internal hostile findings](slices/spatial-phase-foundation-internal-review.md) · [Requirements](requirements-matrix.md) · [Proof obligations](proof-obligations.md).
