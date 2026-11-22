# Recovery status and limitations

**Snapshot date:** 2026-11-22. The archived [original recovery snapshot](recovery-original.md) is preserved byte-for-byte from its initial repository commit. Its filename is stable; the historical revision identifier appears inside the document and in Git history.

The previous ChatGPT master WritingBlock ID **57318** was not accessible as a complete source during recovery. The current summary therefore represents **partial context**, not a complete audited specification.

## Known recoverable material

The snapshot records choices for ADR-046, 055, 057–059, 076a/b and 093–100. The meanings of ADR-057/058/059 are not recovered. Most original choice matrices, contemporary recommendations, exact equations, scientific sources, numerical protocols, and independent reviews are absent.

## Recovery constraints

1. Never invent missing original ADR alternatives, assistant recommendations, mathematical formulas, citations, or results.
2. Preserve the archived snapshot unchanged. Make corrections in current docs or dated supplements with explicit provenance.
3. Recover exact source wording when available, then compare and reconcile by pull request.
4. Keep **Gate 1 open/unverified** until independent reviewers document closure of every finding; do not start executable Lean code.
5. Track subsequent discoveries through GitHub issues/PRs and evidence-register entries.

## Historical reconciliation

Previous summaries reported different accepted ADR totals (79 and 83). Neither is verified. Do not assert an authoritative count until the primary source is recovered.

The historical identifier *v0.26* denotes the missing master revision, **not** an approved release or document filename convention.
