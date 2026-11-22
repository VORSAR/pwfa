# SLICE-001 role-separated hostile review (internal)

- **Date:** 2026-11-22
- **Reviewer:** ChatGPT, explicitly acting in a hostile reviewer role; **SAME assistant system that authored the contract**
- **Independence:** **NO.** Role separation is a review technique, not a distinct independent reviewer, mathematical certification, or ADR-108 Gate-1 approval.
- **Reviewed target:** [SLICE-001 frozen at commit 16a913ab5bfee18870c5d24535124055bca671fb](https://github.com/VORSAR/pwfa/blob/16a913ab5bfee18870c5d24535124055bca671fb/docs/verification/slices/spatial-phase-foundation.md).
- **Review decision:** **CHANGES REQUIRED**. Not authorized for executable Lean under current ADR-108.
- **Method:** Adversarial mathematical/specification inspection and current mathlib documentation comparison. No executable Lean, proof compilation, external independent reviewer, or formal proof was performed.

## Findings

| ID | Severity | Finding | Precise failure mode | Required remediation | Status |
|---|---|---|---|---|---|
| IR-001 | **High / blocking** | **Default product metric can silently be wrong.** | mathlib's `UnitAddTorus (Fin 2)` is a function-space product of circles. Standard `Fin 2 → UnitAddCircle` product distance uses an L-infinity/sup metric. Its torus diameter is 1/2, not the Euclidean L2 diameter √2/2 required by ADR-105 and S1-P05. | Specify an explicit L2 quotient metric or a separately defined distance, prove its metric properties and equivalence to selected ADR-105 formula; ensure all distance lemmas refer to this metric, not the default product metric. Add regression counterexample `(0,0)` versus `(1/2,1/2)`: Euclidean result √2/2, sup result 1/2. | OPEN |
| IR-002 | **High / blocking** | **Distance construction is only an assertion.** | S1-P02/P03 invoke a minimum over the infinite lattice but do not prove attainment, well-definedness on representatives, or the quotient metric law. Lean interfaces can accidentally prove statements about a related distance rather than ADR-105. | Provide finite minimum-coordinate formula or proof of lattice-minimum attainment, explicitly identify the distance's type and theorem statements, and prove representative independence, identity and triangle inequality. | OPEN |
| IR-003 | **Medium / blocking** | **Phase-field type underspecified for spatial claims.** | Arbitrary `T² → Circle` maps can be discontinuous. The original slice excludes winding but uses the term “phase field” and later integration may silently assume continuity. | Make the slice's admissible field type explicitly *arbitrary maps* (algebraic lemmas only), or select `ContinuousMap` and record the extra proof commitments. Do not infer winding or nonlocal integrability without subsequent definitions. | OPEN |
| IR-004 | **Medium / blocking** | **Proof obligations lack formal theorem interfaces and trusted-library policy.** | S1-P01–P09 are English descriptions, not signatures or executable contracts; no Lean/mathlib version is pinned, and missing axioms/`sorry` policy is not recorded per theorem. | Add typed pseudo-signatures or exact quantifier-level mathematical statements for each property; choose suitable mathlib structures by explicit review and pin versions before code. No custom axioms, `sorry`, or unproved opaque assumptions in implementation claims. | OPEN |
| IR-005 | **Medium / blocking** | **Scope conformance is not review-testable yet.** | “First relevant time instant” and phase multiplication preserve norm, but no rule states what the implementer may import, call, or claim about dynamics or physically meaningful memory. The next slice could incorrectly use a foundation proof as evidence of oscillator behavior. | List allowed module/API surface and excluded claims; require tests tying approved theorem statements to their corresponding ADRs; keep evolution, encoding, memory and numerical convergence outside. | OPEN |
| IR-006 | **Medium / blocking** | **Independence policy incompatible with a two-person author/reviewer team as currently staffed.** | The assistant drafted SLICE-001 and is performing this hostile review; simply changing roles does not meet ADR-108's author-independent reviewer rule. User is the approving owner and was assigned issue #8 as coordinator, not an independent reviewer. | Owner must explicitly revise governance if self-review is to authorize *experimental* Lean, with risk acceptance and no claim of independent Gate-1 passage; otherwise obtain a distinct reviewer. | OPEN |

## Counterexample: product-metric mismatch

For torus points represented by `p=(0,0)` and `q=(1/2,1/2)`:

- Each wrapped coordinate distance is `1/2`.
- ADR-105-selected Euclidean distance: `sqrt((1/2)^2+(1/2)^2)=sqrt(2)/2 ≈ 0.70710678`.
- Default product (sup) metric: `max(1/2,1/2)=1/2`.

Both are valid metrics for the same topology. **Only the first conforms to ADR-105**. This invalidates any implicit claim that mathlib's default `UnitAddTorus (Fin 2)` metric directly implements the approved distance.

## What is *not* a finding

- Equivalence x~y iff x-y belongs to Z² is a valid equivalence relation.
- The exact formula for periodic Euclidean distance on the square torus is mathematically coherent; it is not known to be false.
- The claimed diameter √2/2 is correct **for the selected L2 metric**, not the default product/sup metric.
- Unit-modulus complex values are closed under multiplication and inversion; `Circle` is already supported by mathlib.
- A missing physical phase-evolution law is excluded by this slice; it remains a system-level issue, not necessarily a reason to reject the foundation scope.

## Reviewable remedy proposal

1. Document the distinction between topology and metric. Prefer the existing mathlib `UnitAddTorus (Fin 2)` for topology **only if** an explicit L2 metric implementation/equivalence is established; otherwise construct a fit-for-purpose quotient with the Euclidean metric.
2. Present exact claims in a language-neutral typed mathematical interface before writing Lean.
3. Specify foundation phase maps as unrestricted maps only; later introduce a continuous field type in an independently reviewed extension.
4. Keep proof obligations and a statement of which mathlib definitions are reused, with pinned revisions once implementation is authorized.
5. Amend governance by explicit owner choice before treating this *internal* hostile review as an executable-work gate.
6. Re-review amended contract, track all findings, and record an explicit, honest authorization status.

## Reviewed library evidence (public primary documentation)

- [mathlib: UnitAddTorus](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Topology/Instances/AddCircle/Real.html) — defined as a product of copies of `UnitAddCircle` indexed by a type, here `Fin 2`.
- [mathlib: AddCircle norm](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Normed/Group/AddCircle.html) — coordinate wrapped-distance norm.
- [mathlib: Circle](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Complex/Circle.html) — the unit complex circle has group, topology, and exponential map.
- [mathlib: Common Lean Pitfalls](https://leanprover-community.github.io/extras/pitfalls.html) — generic finite function types default to sup (L-infinity) norm, not Euclidean L2; Euclidean spaces require explicit L2 handling.

**Evidence limitations:** Consulted public library documentation rather than a pinned mathlib commit or a compiled proof. Compatibility with the eventual pinned revision remains unverified.

## Governance

This is an internal finding register, **not an independent finding ledger**, and must not be represented as an independent reviewer signoff. No implementation is authorized under the current ADR-108. [External-review issue #8](https://github.com/VORSAR/pwfa/issues/8) remains open pending governance choice.

[SLICE-001 contract](spatial-phase-foundation.md) · [Gate-1 ledger](spatial-phase-foundation-review.md) · [ADR-108](../../decisions/ADR-108.md) · [ADR-105](../../decisions/ADR-105.md)

## Owner Decision 9 and bounded experimental dispositions (2026-11-22)

The owner approved Option A under [ADR-109](../../decisions/ADR-109.md). This changes the experimental authorization policy, **not the mathematical truth or independence status** of the review. The original six findings above remain preserved.

[SLICE-001-PHASE](phase-algebra-experiment.md) explicitly excludes metric and quotient definitions, so IR-001/IR-002 remain **OPEN** and block only [SLICE-001-METRIC](spatial-metric-remediation.md). The algebraic subset addresses IR-003 (arbitrary phase maps), IR-004 (explicit PH-P01–P06 and pinned toolchain), IR-005 (bounded proof/claim surface), and IR-006 (honest self-review governance). These are **internal, scope-limited remediations**, not external review closures.

[Internal source audit](phase-algebra-internal-review.md) found the six theorem declarations and no simple proof holes; it did **not** compile the Lean code. No independent or system-level approval exists.
