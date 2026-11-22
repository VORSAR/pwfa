# SLICE-001-METRIC: Euclidean torus metric remediation plan

- **Status:** MATHEMATICAL CANDIDATE / NOT AUTHORIZED FOR EXPERIMENTAL LEAN
- **Blocked findings:** [IR-001 and IR-002](spatial-phase-foundation-internal-review.md)
- **Controlling decisions:** [ADR-102](../../decisions/ADR-102.md), [ADR-105](../../decisions/ADR-105.md), [ADR-109](../../decisions/ADR-109.md)
- **Independent claim:** None. This document is an author-side proposal to resolve findings, not a completed review.

## Explicit distance definitions

Let spatial positions be classes in `T²=(R/Z)²` with unit coordinate periods. For a real representative `a`, define `frac(a)=a-floor(a)`, so `0 ≤ frac(a) < 1`.

For classes `[a],[b]∈R/Z`, define the circular distance

`δ([a],[b])=min(|frac(a)-frac(b)|, 1-|frac(a)-frac(b)|)`.

For torus points `p=([p₁],[p₂])`, `q=([q₁],[q₂])`, define the **chosen Euclidean** metric

`d₂(p,q)=sqrt(δ(p₁,q₁)^2 + δ(p₂,q₂)^2)`.

This equals `min_{n∈Z²} ‖p̃-q̃+n‖₂` for any representatives `p̃,q̃∈R²`, because the independent minimizers of the two nonnegative square summands can be selected separately. The minimum is attained by a suitable integer nearest to each coordinate displacement. The equality must be proved before using it in Lean.

## Required explicit counterexample test

For `p=(0,0)` and `q=(1/2,1/2)`:

- `d₂(p,q)=sqrt(2)/2`.
- `d∞(p,q)=max(δ(p₁,q₁),δ(p₂,q₂))=1/2`.

A library product `MetricSpace` instance using a sup metric **must not** be reused unmodified as the PWFA `d₂` instance. Mathematical topology may be shared, but metrics cannot be conflated.

## Proof obligations and verification

1. Prove that `frac(a)` respects integer shifts and hence `δ` is well-defined on quotient classes.
2. Prove `0≤δ≤1/2`, symmetry, identity of indiscernibles, and circular triangle inequality.
3. Prove `d₂` satisfies the metric axioms; for the triangle inequality combine coordinate differences with the Euclidean/Minkowski inequality.
4. Prove `d₂` equals the original lattice minimum and the minimum is achieved.
5. Prove translation invariance of `d₂`.
6. Prove diameter `sqrt(2)/2` and that opposite half-period coordinates attain it.
7. Document exact mathlib types used, comparing their actual metric instances. If reusing the product space, expose a **named d₂** operation rather than silently relying on its default `dist`.
8. Compile property proofs without `sorry`, `admit`, custom axioms, or hidden metric coercions, only after a separate explicit internal hostile-review finding closure.

## Remaining blocker

IR-001 and IR-002 remain **OPEN**. This written finite-distance candidate and argument do not constitute completed, independently verified proofs or an experimental Lean implementation authorization for the metric.

The phase-algebra experiment is isolated at [SLICE-001-PHASE](phase-algebra-experiment.md). No metric theorem may be cited from that phase experiment.
