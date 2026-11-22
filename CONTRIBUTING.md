# Contributing and change control

GitHub `main` is the single source of truth. Chat conversations, local drafts, and generated summaries are not authoritative until committed to `main`.

## Workflow (owner directive, 2026-11-22)

1. Commit coherent changes **directly to `main`**, using Conventional Commit-style subjects: `docs:`, `adr:`, `research:`, `spec:`, `proof:`, `test:`, `fix:`, or `ci:`. Include rationale in the commit body when needed.
2. For an architectural choice, present ranked alternatives, pros, cons, original-project alignment, feasibility and a recommendation. Record the owner's explicit selection in a stable ADR, with decision date and provenance. Never silently decide on behalf of the owner.
3. Keep requirements, ADRs, mathematical contracts, proof obligations, tests and evidence cross-linked. Verify local checks when possible, and record any checks not run.
4. Issues, feature branches and pull requests are **optional** tools for coordination or isolated experiments, not mandatory for changes. Do not create them routinely.
5. Direct commits **do not** constitute independent technical review or satisfy Gate 1. External independent reviewer evidence and every finding's closure remain mandatory before executable Lean implementation.
6. Preserve append-only historical and decision provenance. Never silently rewrite the immutable recovery snapshot or previously approved decision meaning.

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

## Repository protection and verification

The owner currently permits direct commits to `main`. Do not configure a pull-request-required ruleset without a new owner decision. Prefer automated documentation checks on every push. CODEOWNERS does not establish independent scientific review.
