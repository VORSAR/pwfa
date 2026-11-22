# SLICE-001: Spatial and phase foundations

- **Status:** DRAFT CONTRACT; independent Gate 1 **NOT STARTED**; executable Lean **NOT AUTHORIZED**
- **Policy:** [ADR-108](../../decisions/ADR-108.md)
- **Source decisions:** [ADR-102](../../decisions/ADR-102.md), [ADR-103](../../decisions/ADR-103.md), [ADR-105](../../decisions/ADR-105.md)
- **Author/review independence:** Drafted by assistant; must obtain an external independent hostile reviewer.
- **Freeze commit:** NOT YET RECORDED. Freeze SHA and dependency identifiers when sending the review package.

## 1. Scope

Formalize the periodic 2D spatial domain, periodic Euclidean metric and unit-complex phase validity. This is a mathematical *foundation* slice, not a working oscillator, memory mechanism or benchmark.

### Included definitions

Let Z denote integers, R real numbers, and C complex numbers.

1. **Periodic domain:** T² = R² / Z², under x ~ y iff x-y belongs to Z². Points are equivalence classes [x].
2. **Periodic distance:** d_T([x],[y]) = min_{n∈Z²} ||x-y+n||₂. This is well-defined on representatives.
3. **Phase circle:** S¹ = {w∈C : |w|=1}.
4. **Phase field:** z : T² → S¹ for each relevant time instant. Temporal regularity, physical evolution and topology of the field space are outside this first slice.
5. **Concrete periodic coordinates for later numerical work:** [x₁],[x₂] in R/Z; implementation representation and quotient API remain a review design task, not a final Lean encoding choice.

These definitions derive from **new owner-approved ADRs**, not purportedly recovered original equations. Definitions are proposed mathematical contracts requiring independent review.

## 2. Proposed theorem and test obligations

| ID | Claim or task | Acceptance evidence |
|---|---|---|
| S1-P01 | Coordinate-equivalence relation on R² is reflexive, symmetric, transitive | Independently checked proof and later Lean theorem |
| S1-P02 | d_T does not depend on chosen representatives | Direct mathematical argument, Lean theorem |
| S1-P03 | d_T ≥ 0, symmetry, triangle inequality and zero iff same torus point | Independently checked proof, Lean metric instance or equivalent |
| S1-P04 | d_T is invariant under torus translation | Mathematical argument and Lean theorem |
| S1-P05 | Torus diameter under chosen metric is √2/2 | Bound and equality witness under unit-period convention |
| S1-P06 | Admissible phases have |z(x)|=1 by construction | Type-level invariant and Lean theorem |
| S1-P07 | Phase multiplication preserves the unit circle; conjugation and inverse stay on S¹ | Independent proof and Lean theorem |
| S1-P08 | Phase-update hypotheses: multiplying by exp(iφ), for real φ, preserves unit magnitude | Proof of generic algebraic preservation only; **not** an approved oscillator step rule |
| S1-P09 | Review and provenance: all outside-scope terms rejected from theorem and release claims | Reviewer checklist, traceable dependency list, Gate-1 closure ledger |

## 3. Proof-sketch checks (not verified)

- A representative shift by integer vectors can be absorbed by relabeling the minimizing lattice translate.
- The shortest periodic distance is induced by the Euclidean norm on the flat quotient; triangle inequality follows by combining near-minimizing translates.
- In a coordinate difference confined to [-1/2,1/2]², Euclidean norm is at most √2/2; opposite corners of the periodic cell supply the maximum.
- Unit complex numbers form a multiplicative group; exp(iφ) has norm 1 for real φ.

These are ordinary mathematical observations, **not completed formal proofs**, and are subject to external review.

## 4. Specific hostile-review questions

1. Is the quotient representation and periodic distance sufficient to support subsequent nonlocal integration, or are more topology/measure structures needed?
2. Are all theorem assumptions explicit, including coordinate choice, mathematical regularity and potential non-unique shortest displacement?
3. Is the diameter claim exactly correct for the selected unit square flat torus?
4. Can Lean/mathlib represent the quotient and metric without importing unproved custom axioms or `sorry`?
5. Is the slice truly independent from undefined oscillator, memory, Q, encoding, and benchmark contracts?
6. Could claims about local rotational symmetry be mistaken for global continuous rotational symmetry?
7. Are remaining integration findings explicitly carried forward without misleading status claims?

## 5. Explicit exclusions

**Not part of SLICE-001:** phase evolution equation, nonlocal kernel profile/radius, learned pairwise memory, homeostat Q, training/recall schedules, encoder and decoder, grid N, quadrature, numerical integrator, two-direction winding computation, benchmark success, biological validity, or system-level stability.

## 6. Gate-1 evidence checklist

- [ ] Reviewed scope fixed at a Git commit SHA
- [ ] Named independent reviewer(s) and independence statement
- [ ] Full review report with findings and severity
- [ ] Each finding linked to remediation commit or justified no-change decision
- [ ] Independent reviewer closes **every** finding, even documentation issues
- [ ] Final authorized contract SHA and review approval recorded
- [ ] Lean/mathlib versions selected and pinned only for authorized executable implementation
- [ ] Gate 2 plan defined for first reference implementation

**No checkbox is currently asserted complete.**

## 7. Independent review ledger

The dedicated [SLICE-001 reviewer findings and closure ledger](spatial-phase-foundation-review.md) is **NOT STARTED**. No implementation authorization exists.

## 8. Next step

Obtain independent review of this frozen slice. In parallel, continue only non-executable mathematical contract drafting for the oscillator and memory slices. Once SLICE-001 Gate 1 closes, create a Lean 4 implementation limited to these foundations and separately schedule Gate 2.

[Review gates](../review-gates.md) · [Proof obligations](../proof-obligations.md) · [Requirements matrix](../requirements-matrix.md) · [Preliminary findings](../preliminary-hostile-review.md)
