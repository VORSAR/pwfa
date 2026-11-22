# SLICE-001-PHASE: Internal experimental authorization and source audit

- **Date:** 2026-11-22
- **Reviewer:** ChatGPT in explicitly hostile role; also the contract/source author
- **Independence:** **NO**; no claim of independent Gate 1 or mathematical certification
- **Policy:** Owner-selected [ADR-109](../../decisions/ADR-109.md)
- **Authorized experimental contract:** [Phase algebra specification](phase-algebra-experiment.md), committed at [bb097d31a8d402e3746d013bfb3b0fc903d04fae](https://github.com/VORSAR/pwfa/commit/bb097d31a8d402e3746d013bfb3b0fc903d04fae)
- **Source:** [PWFA/Phase.lean](../../../PWFA/Phase.lean), updated at [6268f65fe35579d1e91b6d96c70db179ed57cef3](https://github.com/VORSAR/pwfa/commit/6268f65fe35579d1e91b6d96c70db179ed57cef3)
- **Assessment:** Scope-cleared for **experimental proof development**; source static review complete, compilation **NOT VERIFIED**.
- **External review:** NOT PERFORMED.

## Applicable hostile finding dispositions

| Finding | Disposition for phase-only code | Evidence / limitations |
|---|---|---|
| IR-001 | OUTSIDE PHASE SCOPE — OPEN for geometry | Source has no spatial distance, product-metric instance or quotient construction |
| IR-002 | OUTSIDE PHASE SCOPE — OPEN for geometry | Source contains no quotient metric or lattice minimization |
| IR-003 | REMEDIATED for phase-only scope | `PhaseField X = X → UnitPhase` permits arbitrary maps; continuity and winding explicitly excluded |
| IR-004 | REMEDIATED for phase-only contract; compilation outstanding | Exact PH-P01–P06 statement table, pinned Lean/mathlib v4.35.0; no claim of type-checked success |
| IR-005 | REMEDIATED for phase-only scope | Strict algebraic source boundary and explicit excluded physical claims |
| IR-006 | GOVERNANCE-ADDRESSED by owner | [ADR-109](../../decisions/ADR-109.md) authorizes internal review for **experiments**, not independent certification |

These are **author-side dispositions**, not independent closure attestations. All six findings remain visible in the [original hostile review](spatial-phase-foundation-internal-review.md).

## Post-implementation static audit

Source inspection checks performed using the GitHub connector on 2026-11-22:

- **6 of 6** expected theorem declarations are present: `phaseOne_norm`, `phaseMul_norm`, `phaseMul_assoc`, `phaseMul_one_left`, `phaseMul_one_right`, `pointwiseMul_norm`.
- The source contains **zero detected declarations** matching the anchored `sorry`, `admit`, or `axiom` search. This is not a kernel-level axiom audit.
- `UnitPhase` uses a complex norm-one subtype; `PhaseField X` is unrestricted. These are intentionally different from the full torus-valued continuous oscillator specification.
- There are no statements about periodic distance, winding numbers, oscillator dynamics, memory training or recall.
- The pinned Lean toolchain is **v4.35.0**, and mathlib is configured at **tag v4.35.0**. The exact resolved Git SHA and Lake manifest are not yet checked in.

## Build and proof status

- **Lean binary in this assistant environment:** not installed.
- **Local `lake build`:** NOT RUN.
- **GitHub Actions workflow:** [Experimental Lean proofs](../../../.github/workflows/lean.yml) committed; outcome **NOT VERIFIED** at the time of this record.
- **Compilation success:** NOT VERIFIED.
- **Kernel-checked theorem status:** NOT VERIFIED.
- **Independent review:** NOT PERFORMED.
- **Metric subset:** BLOCKED by IR-001/IR-002.

## Follow-up acceptance conditions

1. Obtain a passing GitHub Actions or local `lake build` record against the exact source revision.
2. If compilation fails, record the logs and fix the theorem/proof without modifying their mathematical meaning.
3. Check for proof holes/custom axioms with a compiler-aware audit before describing results as kernel-checked.
4. Generate and commit a resolved `lake-manifest.json` for reproducible mathlib revision pinning.
5. Keep further metric work isolated until [SLICE-001-METRIC](spatial-metric-remediation.md) passes its own internal hostile review.

**Internal review conclusion:** The bounded experimental phase work is permitted under ADR-109. No proposition has been independently certified; compiler success remains to be established.
