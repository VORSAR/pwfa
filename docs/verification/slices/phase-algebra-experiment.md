# SLICE-001-PHASE: Experimental unit-complex phase algebra

- **Status:** **Experimental Lean authorized under ADR-109.** PH-P01–PH-P06 compiled in CI. Independent review is pending. [Review packet](phase-algebra-review-packet.md).
- **Decision authority:** [ADR-109](../../decisions/ADR-109.md) (owner-selected two-person role-separated review).
- **Parent:** [SLICE-001](spatial-phase-foundation.md).
- **Adversarial source:** [SLICE-001 internal hostile review](spatial-phase-foundation-internal-review.md).
- **Metric work:** [SLICE-001-METRIC](spatial-metric-remediation.md) remains separately blocked by IR-001 and IR-002.

## Mathematical contract — bounded to algebra

Define `UnitPhase = {z : ℂ | ‖z‖ = 1}`, where ℂ denotes complex numbers and `‖·‖` the standard complex modulus.

For **any type X** of spatial locations, define `PhaseField X = X → UnitPhase`. These fields are **arbitrary maps**, not necessarily continuous. This makes **no claim** about spatial topology, integration, winding number, coupling, or physical time dynamics.

Define `phaseOne = 1` as a unit phase; `phaseMul(u,v)` as ordinary complex multiplication with an attached unit-modulus certificate; `pointwiseMul(f,g)(x) = phaseMul(f(x),g(x))`.

## Formal theorem interfaces required in Lean

| ID | Intended Lean theorem | Fully quantified meaning |
|---|---|---|
| PH-P01 | `phaseOne_norm` | `‖(phaseOne : ℂ)‖ = 1` |
| PH-P02 | `phaseMul_norm` | For all `u v : UnitPhase`, `‖(phaseMul u v : ℂ)‖=1` |
| PH-P03 | `phaseMul_assoc` | For all `u v w : UnitPhase`, `phaseMul (phaseMul u v) w = phaseMul u (phaseMul v w)` |
| PH-P04 | `phaseMul_one_left` | For all `u : UnitPhase`, `phaseMul phaseOne u = u` |
| PH-P05 | `phaseMul_one_right` | For all `u : UnitPhase`, `phaseMul u phaseOne = u` |
| PH-P06 | `pointwiseMul_norm` | For all types `X`, fields `f g : PhaseField X` and positions `x : X`, `‖(pointwiseMul f g x : ℂ)‖ = 1` |

Each statement follows from the underlying complex-field norm and multiplication identities; it is **not** a theorem about oscillator evolution.

## Formalization constraints

- The [Lean toolchain](../../../lean-toolchain) and [Lake manifest](../../../lake-manifest.json) pin Lean v4.35.0, mathlib v4.35.0, and mathlib's transitive dependencies.
- Allowed mathematical dependencies: Lean core and kernel, mathlib complex arithmetic, subtype equality, and norm identities. The source imports `Mathlib.Analysis.Complex.Norm`.
- Forbidden in claimed proofs: `sorry`, `admit`, custom axioms, unreviewed postulates, unsafe proof shortcuts or unstated assumptions.
- `PhaseField X` is generic in `X`, avoiding any claim about the unresolved periodic Euclidean metric.
- No implementation of `T²` distance, topology, winding, homeostatic variables, phase evolution or learned memory within this release.
- A successful compiler run would establish only the stated Lean propositions relative to kernel and dependencies. It would not establish empirical physical or cognitive behavior.

## Internal review finding dispositions before experimental implementation

| Original finding | This bounded phase-only slice |
|---|---|
| IR-001 (wrong product metric) | **OPEN for metric scope**; no metric type or distance imported as a theorem premise, not applicable to phase-only statements |
| IR-002 (metric minimum and quotient) | **OPEN for metric scope**; this slice defines no quotient nor metric |
| IR-003 (field continuity) | **REMEDIED in this scope**: `PhaseField X` is arbitrary, and continuity/winding explicitly excluded |
| IR-004 (formal interfaces and toolchain) | **REMEDIED in this scope** by PH-P01–PH-P06, pinned dependencies, and the passing build recorded in the review packet |
| IR-005 (scope conformance) | **REMEDIED in this scope** by permitted dependencies and explicit forbidden claims |
| IR-006 (two-person independence conflict) | **GOVERNANCE-ADDRESSED** by owner-selected ADR-109; no independent review claim |

**Authorization classification:** Internal and experimental only, not independent Gate 1. This authorizes drafting/executing Lean for PH-P01–P06 and assessing build output. The underlying IR-001/002 are not closed, and the metric portion remains blocked.

## Post-implementation checks

1. Run `lake build` and record exact outcome. Do not assert success from writing source code.
2. Inspect Lean files for `sorry`, `admit`, `axiom` and broader unsound definitions.
3. Verify the compiled theorems match PH-P01–P06 without hidden extra premises.
4. Record any failed proof as failed and remediate through a dated revision.
5. Revisit geometric slice only after IR-001 and IR-002 receive explicit remedies.

## Research limitation

This is infrastructure for a continuous phase model, not evidence that PWFA stores or recalls patterns.

[Phase theorem source](../../../PWFA/Phase.lean) · [Internal adversarial report](spatial-phase-foundation-internal-review.md) · [Review gates](../review-gates.md)
