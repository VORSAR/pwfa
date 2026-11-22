# Contributing and change control

GitHub is the single source of truth. Chat conversations, local drafts, and generated summaries are not authoritative until merged.

## Workflow

1. Open a GitHub issue describing motivation, scope, affected decisions/specifications, risks, and acceptance criteria.
2. Work on a feature branch. Prefer `docs/<topic>`, `adr/<id>-<topic>`, `spec/<topic>`, or `ci/<topic>`.
3. Commit coherent changes using a Conventional Commit-style subject: `docs:`, `adr:`, `research:`, `spec:`, `proof:`, `test:`, `fix:`, or `ci:`. Explain **why** in the commit body when the reasoning is not obvious.
4. Open a pull request (PR) with links to issue, affected ADRs, evidence, proof obligations, and an impact summary.
5. Pass automated checks, obtain appropriate review, and record unresolved concerns before merge. Do not self-certify an independent review.
6. Merge with a traceable commit/PR history; avoid direct pushes to `main`. Squash routine PRs; preserve separate commits when provenance matters.

## Architecture decision records (ADRs)

Use [the ADR template](docs/decisions/template.md). A new decision receives a stable ID. Accepted decisions are historically immutable in *meaning*; supersede through a new ADR. Documentation corrections must cite evidence and retain an amendment trail. Unknown historical choices must remain **NOT RECOVERED**. Preserve the contemporaneous recommendation separately from retrospective commentary.

## Traceability

Link requirements ↔ ADRs ↔ mathematical contracts ↔ proof obligations ↔ verification and evidence. A change in a mathematical contract must identify affected tests and claims. Use links to stable paths and anchors.

## Naming and versions

Document filenames are stable, lower-kebab-case where possible. **Never encode specification release/version numbers in filenames**, including archives. ADR numbers are identities, not versions. Git commits, release tags, and the changelog identify revisions.

## Verification rules

- Research citations must distinguish directly verified primary sources, secondary interpretations, and missing evidence. Do not manufacture bibliographic entries.
- Separate hypotheses, engineering choices, mathematical theorems, numerical test results, and empirical evidence.
- Results and independent review artifacts are append-only or corrected with explicit provenance, never silently overwritten.
- **ADR-046 and ADR-055 remain mandatory**: no executable Lean implementation before an independent Gate 1 has closed **all** findings, including documentation findings. This does not block documentation, review preparation, or non-executable specification work.
- Only after Gate 1 may executable Lean work proceed in small slices with pinned Lean/mathlib toolchains and continuous integration.

## Repository policy gap

The initial repository had no branch protection or rulesets. Configure a main-branch ruleset requiring PRs, review, and passing documentation checks. The presence of CODEOWNERS alone does not enforce approvals.
