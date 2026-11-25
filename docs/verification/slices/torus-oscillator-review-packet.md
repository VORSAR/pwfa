# Independent Gate 1 review packet for the unforced torus oscillator

**Disposition: awaiting independent review.** The question for the reviewer is whether the written unforced oscillator on the unit square torus defines the claimed dynamics under its stated assumptions. The phase algebra and historical ring supply supporting checks. The requested verdict is limited to this continuum oscillator. Numerical convergence, learned memory and recall accuracy have separate obligations.

## Frozen materials

Use revision `35105b81d3afb829bb0d5e7978abab1456c9bfaf` for the specification, public Lean declarations, and audits. The later benchmark work is outside this freeze. The governing choices are the shortest periodic Euclidean distance, transferred phase-lag law, and smooth primary coupling with disk and uniform controls. [Frozen specification and internal findings](https://github.com/VORSAR/pwfa/blob/35105b81d3afb829bb0d5e7978abab1456c9bfaf/docs/verification/slices/torus-oscillator-baseline.md) · [Metric](../../decisions/ADR-105.md) · [Phase law](../../decisions/ADR-110.md) · [Kernels](../../decisions/ADR-111.md)

The domain is the product of two unit-period circles with Haar probability area. The initial field is continuous and pointwise unit complex. Frequency, coupling and lag are constant real numbers. Both finite-range kernels have $0<R<1/2$. The disk uses a strict Euclidean-distance cutoff. Smoothness is claimed for the smooth kernel. The governing equation and every integral convention are in the frozen specification. [Frozen proof tree](https://github.com/VORSAR/pwfa/tree/35105b81d3afb829bb0d5e7978abab1456c9bfaf/PWFA)

## Claims to check

The public declarations below are exercised through the project import. The audits also inspect their transitive dependencies. Earlier internal findings and the accepted remedies are recorded beside the relevant derivations. Each row is independently challengeable. [Frozen extension audit](https://github.com/VORSAR/pwfa/blob/35105b81d3afb829bb0d5e7978abab1456c9bfaf/scripts/audit-extensions.lean) · [Phase audit](https://github.com/VORSAR/pwfa/blob/35105b81d3afb829bb0d5e7978abab1456c9bfaf/scripts/audit-phase.lean)

| Claim | Assumptions, public statements and points to challenge |
|---|---|
| Geometry and state | Compare `euclideanDist_isLeast_latticeLength` and `euclideanDist_triangle` with the square torus metric. At the opposite diagonal point the named distance is $\sqrt{2}/2$ while the library product distance is $1/2$. Check tied representatives and `area_univ`. See the IR-001/002 remedies. [Metric record](spatial-metric-remediation.md) |
| Structural kernels and mean | Check `area_disk`, `integral_diskKernel`, `integral_smoothKernel`, and `norm_meanField_le_of_unit_mass`. For every center, both configured finite-range kernels integrate to one. The uniform control has constant value one. Translation and integrability handle the discontinuous disk in `continuous_meanField`. Inspect the open-disk change of variables and the squared-radius substitution in DISK-01–04 and SM-01–03. |
| Local and global dynamics | `lipschitzOnWith_continuousRhs` uses the absolute row mass. `exists_local_solution`, `local_solution_unique` and `norm_local_solution_eq_initial` give the local claims. For translation-invariant kernels with an integrable origin row, unit initial data give a unique solution for all real time by `existsUnique_global_phase_solution`; `global_solution_unit` gives its pointwise modulus. Check that the uniform restart covers both directions of time (TORUS-LOCAL-01–04 and GL-01–03). |
| Winding | `global_solution_coordinateWinding` preserves both integer coordinate windings for unit-phase solutions; `local_solution_coordinateWinding` gives the interval statement. Check orientation of each coordinate loop and allow its image basepoint to move (WN-01–03). |
| Synchronized and spatial wave rates | `synchronizedField_deriv` gives $\omega-\kappa\sin\alpha$ at unit row mass. `waveField_deriv` treats every integer frequency pair for the selected radial kernels. Inspect reversal, axis exchange, cancellation of nonzero modes for the uniform control, and `waveCoefficient_disk_chord` for the actual disk. Challenge the sign of the lag and the normalization of the chord integral (SY-01–03 and WV-01–04). |
| Smoothness | `contDiff_liftedSmoothKernel`, `liftedSmoothKernel_periodic`, `liftedSmoothKernel_flat_at_edge`, and `liftedSmoothKernel_zero_near_tie` refer to the lifted kernel in both points. Check coincident points, vanishing of every spatial derivative at the edge, and local zero near the cut locus (SK-01–03). |
| Ring reference | In the separate one-dimensional cosine reference `integral_kernel` gives the coupling strength, and `historical_rates` checks windings $0,±1$ at all three recovered contrasts. Verify coupling enters once. This checks the transferred convention. [Ring contract and RING-01–03](../../mathematics/ring-oscillator-reference.md) |

## Reproduce the evidence

From a checkout of the frozen revision with the pinned toolchain, run the following at the repository root. The GitHub build on this exact revision passed the build, both audits and the check for proof holes. Lean is 4.35.0 and mathlib is pinned to `56a005855ea17e0b0958f73ec801ae140b0a1679`. The audits allow only `propext`, `Classical.choice`, and `Quot.sound` as transitive axioms. [Verified CI run](https://github.com/VORSAR/pwfa/actions/runs/45400733487) · [Dependency manifest](https://github.com/VORSAR/pwfa/blob/35105b81d3afb829bb0d5e7978abab1456c9bfaf/lake-manifest.json)

```sh
git rev-parse HEAD
lean --version
lake --wfail build
lake env lean scripts/audit-phase.lean
lake env lean scripts/audit-extensions.lean
```

The Mac checkout also passed the warning-as-error build and both proof audits against identical sources and lockfiles. The audits emitted dependency reports for 11 phase declarations and 114 extension declarations. All 25 declaration names in the claim table were cross-checked against the frozen source tree.

## Record the independent disposition

Please record your name, independence from the authors, date and reviewed revision. For each finding, identify the affected claim or assumption, give a counterexample or other evidence, and specify what would close it. Record remedy revisions and the independent recheck for every finding, including documentation findings. The owner can then record the verdict for the reviewed revision and scope. A changed contract needs an identified revision for re-review. Gate 2 concerns implementation conformance. [Gate policy](../review-gates.md) · [Traceability matrix](../requirements-matrix.md)
