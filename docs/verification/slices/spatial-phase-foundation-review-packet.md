# SLICE-001 review packet: frozen contract and hostile-review assignment

**Status:** READY TO ASSIGN; not independently reviewed; implementation blocked.  
**Initial scope baseline:** [commit 16a913ab5bfee18870c5d24535124055bca671fb](https://github.com/VORSAR/pwfa/commit/16a913ab5bfee18870c5d24535124055bca671fb) (2026-11-22).  
**Frozen review target:** [SLICE-001 at the baseline commit](https://github.com/VORSAR/pwfa/blob/16a913ab5bfee18870c5d24535124055bca671fb/docs/verification/slices/spatial-phase-foundation.md). This fixes the original target contract even if current main advances.  
**Review protocol:** [ADR-108](../../decisions/ADR-108.md).  
**Decision inputs:** [ADR-102](../../decisions/ADR-102.md), [ADR-103](../../decisions/ADR-103.md), [ADR-105](../../decisions/ADR-105.md).  
**Review ledger:** [SLICE-001 findings and closure](spatial-phase-foundation-review.md).

## Intended independent reviewer

The reviewer must be independent of the assistant that drafted the mathematical contract and not the approving project owner acting as sole author/reviewer. A numerical analyst or mathematical formalization specialist conversant with quotient metric spaces and Lean/mathlib is suitable. **No reviewer has yet been appointed, notified, or attested.**

## Scope to attack

1. **Underlying mathematical object:** quotient T² = R²/Z² and valid implementation representations, avoiding accidental identification of non-equivalent points.
2. **Shortest periodic Euclidean metric:** well-definedness on quotient classes; existence of a minimizer; nonnegativity, symmetry, identity of indiscernibles, triangle inequality, translation invariance.
3. **Diameter:** √2/2 under unit-square period and precise equality witnesses.
4. **Phase circle:** S¹ as unit-modulus complex numbers; algebraic closure under multiplication, inverse and conjugation; generic norm-preserving exponential multipliers.
5. **Formalization obstacles:** reliance on mathlib library structures and any hidden axioms, proof holes, Lean imports or inconsistent representation types.
6. **Scope isolation:** whether the claimed results can be proved without assuming phase evolution, memory learning, homeostasis, encoded stimuli, winding, quadrature or numerical dynamics.
7. **Boundary assumptions:** unit lattice scale, torus geometry versus embedded doughnut, cut loci, unsmoothed distance and global rotational symmetries.

## Required response format

For each issue: stable reviewer finding ID, severity, precise file/section, counterexample or proof gap, actionable correction and impacted obligations. At the end: full finding count, independence declaration, dates, and one of **BLOCKED**, **CHANGES REQUIRED**, **APPROVED FOR REMEDIATION REVIEW**, or **AUTHORIZED**. Only the independent reviewer may issue an authorization, and only after the full closure ledger is independently verified.

Approval covers **SLICE-001 only**, not the complete PWFA architecture, any oscillator or memory equation, any numerical solver, or claimed associative recall.

## Internal author-side preflight (not independent)

- **PF-001:** The metric's minimization over an infinite lattice needs a proof of attainment or an equivalent finite-coordinate construction. It must not be silently replaced with an unproved infimum.
- **PF-002:** The word *phase field* does not yet impose spatial continuity. Continuous-field topology, winding invariants and existence results must not be inferred from S¹-valued functions alone.
- **PF-003:** The precise Lean representation of T², distance, and unit circle is not yet selected. A proof about one encoding cannot imply conformance to a second encoding without an isomorphism/equivalence proof.
- **PF-004:** There are no Lean proofs, compiled tests, independent review signatures, or closed findings. This packet does not assert any.

The preflight is advisory and not a complete independent finding ledger.

## Sequencing

1. Assign an independent reviewer and capture the independence declaration.
2. Have the reviewer evaluate the *frozen baseline*, record every finding and severity.
3. Remedy findings in direct, traceable Git commits to main, then update the authorized target commit.
4. Obtain independent confirmation of **every** closure, including documentation issues.
5. Authorize executable Lean for this bounded slice; pin toolchain and mathlib revisions. After a first implementation, schedule independent Gate 2.

The existing preliminary architecture review remains open and is not a substitute for this specialized mathematical review.
