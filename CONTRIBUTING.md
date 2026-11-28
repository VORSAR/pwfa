# Contributing and change control

GitHub `main` is the single source of truth. Chat conversations, local drafts, and generated summaries are not authoritative until committed to `main`.

## Workflow (owner directive, 2026-11-22)

1. Commit coherent changes **directly to `main`**, using Conventional Commit-style subjects: `docs:`, `adr:`, `research:`, `spec:`, `proof:`, `test:`, `fix:`, or `ci:`. Include rationale in the commit body when needed.
2. For an architectural choice, present ranked alternatives, pros, cons, original-project alignment, feasibility and a recommendation. Ask the owner in the [multiple-choice form](#asking-the-owner-for-a-decision). Record the owner's explicit selection in a stable ADR, with decision date and provenance. Never silently decide on behalf of the owner.
3. Keep requirements, ADRs, mathematical contracts, proof obligations, tests and evidence cross-linked. Verify local checks when possible, and record any checks not run.
4. Issues, feature branches and pull requests are **optional** tools for coordination or isolated experiments, not mandatory for changes. Do not create them routinely.
5. Direct commits **do not** constitute independent technical review or satisfy Gate 1. For **experimental** Lean, ADR-109 permits role-separated internal hostile review with closure of every applicable finding. This is not independent certification.
6. Preserve append-only historical and decision provenance. Never silently rewrite the immutable recovery snapshot or previously approved decision meaning.

## Asking the owner for a decision

Put every choice that belongs to the owner as a multiple-choice question. Use plain, non-technical language as far as possible, and word the question so it can be answered on its own. For each option give a short description with its pros and cons. Rank the options by alignment with the original vision, feasibility and accuracy, list them best first, and mark the recommended one with the reason. Keep formulas and evidence in linked documents. [Owner decision](docs/decisions/ADR-130.md) · [Vision statement](docs/vision/vision-statement.md)

## Lean experiments for research decisions

When comparing approaches, identify a mathematical assumption that could change the ranking. After the bounded internal review under ADR-109, test it in Lean before presenting the options. Include a boundary or counterexample when it distinguishes candidates. Put the evidence beside the recommendation and say what still needs numerical simulation or held-out data. Record the owner's choice separately. [Research decision](docs/decisions/ADR-117.md) · [First worked example](docs/research/bit-to-phase-map.md)

Keep each reproducible check in a standalone file directly under `scripts/experiments/`. Link its module comment to the governing specification or research note; link the note back to the check. Use the repository's pinned toolchain. Run the same collection locally and in CI with:

```sh
bash scripts/check-lean-experiments.sh
```

The runner builds each file's imports and treats warnings as errors. Include the hypotheses and the exact checked conclusion in the note. The phase-readout check illustrates the repository's axiom-dependency audit. [Example Lean file](scripts/experiments/bit-phase-readout.lean)

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
- **ADR-109 governs experimental Lean** in the two-person project. A bounded slice must receive role-separated internal hostile review and closure of **every in-scope finding**, including documentation findings, before its experimental implementation.
- Independent Gate 1/2 certification remains **UNACHIEVED** unless a distinct reviewer independently verifies it. Self-review does not qualify. An approved experimental slice cannot authorize unreviewed dependencies or system-level claims.
- Experimental Lean follows a frozen authorized contract with pinned Lean/mathlib versions, build checks and post-implementation audit. Failing or unrun checks must be labeled explicitly.

## Repository protection and verification

The owner currently permits direct commits to `main`. Do not configure a pull-request-required ruleset without a new owner decision. Prefer automated documentation checks on every push. CODEOWNERS does not establish independent scientific review.
