# Phase algebra independent review packet

**Status:** Internal adversarial review and remediation prepared on 2026-11-23. Independent Gate 1 is pending. The assistant performed this follow-up review and made the fixes.

## Frozen scope

Review PH-P01 through PH-P06 from the [original frozen phase contract](https://github.com/VORSAR/pwfa/blob/bb097d31a8d402e3746d013bfb3b0fc903d04fae/docs/verification/slices/phase-algebra-experiment.md). The implementation and evidence target is the Git commit of the packet supplied to the reviewer. Record both commits in the review report.

- `UnitPhase` is the subtype of complex numbers of norm one. `PhaseField X` is the type of all maps from any `X : Type u` into that subtype.
- `phaseOne`, `phaseMul`, and `pointwiseMul` represent complex one, complex multiplication, and its pointwise lift. The six obligations cover norm preservation, associativity, and left and right identity.
- Review the [phase source](../../../PWFA/Phase.lean), [public entry point](../../../PWFA.lean), and [compiler audit](../../../scripts/audit-phase.lean). The [Lean toolchain](../../../lean-toolchain) specifies v4.35.0. The [Lake manifest](../../../lake-manifest.json) pins mathlib v4.35.0 at `56a005855ea17e0b0958f73ec801ae140b0a1679` and locks its transitive dependencies.
- The scope excludes inverse and conjugation theorems, topology and continuity, the periodic torus metric, oscillator dynamics, winding, memory, and empirical recall. The [metric findings](spatial-metric-remediation.md) belong to a separate review target.

## Internal adversarial findings and fixes

The initial pass examined `ea776d0f4fe101c4a09db5f0e0f7f14e752c70ca`. The mathematical checks followed the implementations through the complex norm and multiplication laws and checked how the subtype equality proofs transfer those laws to phases.

| Finding | Severity | Evidence and remediation |
|---|---|---|
| PH-REVIEW-01 | Medium | The old CI expression required whitespace after `sorry` or `admit`, so it missed a bare token at end of line. A scratch declaration emitted Lean's incomplete-proof warning and exited successfully while the old search returned no match. The new [workflow](../../../.github/workflows/lean.yml) checks complete words in `PWFA.lean` and the `PWFA/` source tree. The compiler audit also checks transitive axiom dependencies on the scoped declarations. |
| PH-REVIEW-02 | Medium | A successful build and source search alone left no repeatable check of the public statements or their assumptions. The compiler audit checks the underlying meanings, elaborates each of PH-P01–PH-P06 at its stated type through `import PWFA`, and fails if a scoped declaration depends on an axiom outside `propext`, `Classical.choice`, and `Quot.sound`. |
| PH-REVIEW-03 | Low | The [previous CI build](https://github.com/VORSAR/pwfa/actions/runs/45003571679/job/137150133548) compiled both modules but warned about importing Mathlib from a legacy Lean file. The source now uses Lean modules and imports `Mathlib.Analysis.Complex.Norm` directly. The audit checks that the public definitions still reduce to the specified operations. |
| PH-REVIEW-04 | Low | The README and verification records still called compilation unverified after CI succeeded. The current status now records the result and the historical audit keeps the earlier failure and pending observation with a dated follow-up. The frozen contract supplies the original requirements for outside review. |
| PH-REVIEW-05 | Low | The documentation checker scanned Markdown inside the fetched `.lake` dependencies and failed on upstream files. It now checks the repository's tracked and unignored Markdown, including local drafts. |

## Reproduce the build and audit

From the repository root at the assigned implementation commit:

```sh
lean --version
lake exe cache get Mathlib.Analysis.Complex.Norm
lake --wfail build
lake env lean scripts/audit-phase.lean
```

The cache command is optional and uses the manifest's pinned dependencies. The compiler audit prints the axiom dependencies of the five definitions and six theorems. For independent confirmation, run `#print axioms` for the declarations in a separate Lean file importing `PWFA` and compare each theorem's full type against PH-P01–PH-P06. Pay particular attention to the generic universe in PH-P06 and to subtype equality in the identity and associativity laws. See the [Lean proof validation guide](https://lean-lang.org/doc/reference/latest/ValidatingProofs/).

On 2026-11-23, `lake --wfail build` passed on macOS arm64. The audit elaborated the contract checks and reported only `propext`, `Classical.choice`, and `Quot.sound` for each of the eleven declarations. Scratch regression checks detected a bare end-of-line proof hole in both the root module and the phase module. Replacing `phaseOne_norm` temporarily with an admitted proof also made the compiler audit fail on its `sorryAx` dependency. The restored source passed the build, and the documentation checker passed with the dependencies present.

## Independent review record

Please provide your name, independence declaration, review date, contract and implementation SHAs, and tooling results. For every finding, give a stable ID, severity, exact statement or location, evidence, and closure criterion. Record the resulting remediation commits and independent closure of every finding before signing off on the final contract revision. Under [ADR-108](../../decisions/ADR-108.md), Gate 1 covers the scoped mathematical contract. The implementation evidence is available for the separate Gate 2 conformance review.
