# Independent adversarial review gates

## Current governing policy

[ADR-108](../decisions/ADR-108.md) establishes **scope-limited independent Gate 1 per vertical slice**. It explicitly supersedes [ADR-055](../decisions/ADR-055.md) only concerning the former *global* preimplementation review scope. ADR-055's **every finding closes, including documentation findings** requirement remains binding for each reviewed slice.

Historical [ADR-046](../decisions/ADR-046.md) requires two independent hostile review gates; their current application is:

- **Slice Gate 1:** after a frozen mathematical/engineering contract, **before executable Lean for that slice**.
- **Slice Gate 2:** after that slice's first Lean reference implementation.
- **System integration review:** separate independent review before claiming assembled PWFA validity. A passed slice is not a passed system.

## Review prerequisites

An independent reviewer must have no responsibility for creating the subject contract. Record their identity, independence, exact frozen Git commit and scope, assumptions, dependencies, excluded claims, findings and severity. All findings, including minor documentation findings, require remediation and **independent closure**. No automatic CI result or assistant self-review qualifies as independence.

After a slice Gate 1 is independently closed, only the reviewed frozen slice may enter executable Lean implementation. Pin toolchain and mathlib versions and maintain source-to-theorem traceability. Material changes to the contract or dependencies require review impact assessment and reauthorization.

## Current status

- [SLICE-001: spatial and phase foundations](slices/spatial-phase-foundation.md): **DRAFT / NOT REVIEWED / executable Lean BLOCKED**.
- Every other slice: **NOT DEFINED / NOT REVIEWED / BLOCKED**.
- Whole PWFA: **no integration-level review or closure**.
- Preliminary internal [hostile review](preliminary-hostile-review.md) is not independent Gate 1.

A future slice closure record requires named reviewer(s), full findings ledger, closure evidence, remediation commit links, dated authorization, and verified freeze/authorized SHA.

[ADR-108](../decisions/ADR-108.md) · [Original ADR-046](../decisions/ADR-046.md) · [Original ADR-055](../decisions/ADR-055.md) · [Proof obligations](proof-obligations.md).
