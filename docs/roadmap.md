# PWFA roadmap

**Next milestone: prove smoothness of the primary torus kernel at its center, boundary, and coordinate ties.**

## Verified starting point

At [commit `cafd238`](https://github.com/VORSAR/pwfa/commit/cafd238daa78d872977a1275dcda13623af4eb0a), Lean checks the phase algebra, shortest periodic Euclidean distance, continuous mean field, and local phase solutions for the smooth, disk, and uniform kernels. Solutions from the same initial field agree near the initial time. Each point keeps its initial modulus throughout the local interval. The disk kernel integrates to one at every center. [Oscillator baseline](verification/slices/torus-oscillator-baseline.md) · [Lean CI](https://github.com/VORSAR/pwfa/actions/runs/45375224871)

## Pending Lean work under existing decisions

The order below is recommended. Each checkbox describes a result that can be verified with the selected phase law and kernels. Before implementing each bounded scope, record its internal review and close the applicable findings. Mark it complete with a link to the compiled theorem and its audit. [Phase-law decision](decisions/ADR-110.md) · [Experimental review policy](decisions/ADR-109.md)

- [x] **1. Normalize the smooth kernel.** Integrate the chosen radial bump over its support and recover the denominator $\pi R^2\int_0^1 b(s)\,ds$. Prove the kernel row integrates to one for every center and every $0<R<1/2$. Apply the existing mean-field bound to show that smooth averaging cannot increase the supremum norm. [Smooth-kernel specification](verification/slices/torus-oscillator-baseline.md#smooth-primary-kernel) · [Mean-field bounds](../PWFA/TorusMeanField.lean)
- [x] **2. Prove the exact synchronized trajectory.** Starting from any spatially constant unit phase, prove that the trajectory rotates at angular velocity $\omega-\kappa\sin\alpha$. A single proof for a unit-mass kernel covers the disk and uniform cases now. Item 1 supplies the remaining hypothesis for the smooth case. [Analytic checks](verification/slices/torus-oscillator-baseline.md#analytic-checks)
- [x] **3. Extend solutions to all time.** Prove existence and uniqueness for every real time from any continuous unit-phase field. Use modulus preservation to keep the supremum norm bounded and obtain a uniform local restart interval. This can proceed independently of items 1 and 2. [Local flow](../PWFA/TorusLocalFlow.lean) · [Velocity bound](../PWFA/TorusVelocityBound.lean)
- [x] **4. Prove both winding numbers are preserved.** Restrict a trajectory to each of the two coordinate loops and prove its integer winding number stays constant over the local solution interval. Item 3 extends the result to all time. [Phase-law obligations](decisions/ADR-110.md) · [State space](mathematics/state-space.md)
- [x] **5. Verify spatial wave rotation rates.** For modes $(\pm1,0)$, $(0,\pm1)$, and $(1,1)$, derive $\Omega_q=\omega-\kappa\lambda_q\sin\alpha$. Check reversal and axis-exchange symmetry, the zero coupling contribution for nonzero modes under uniform weights, and the specified one-dimensional chord integral for the disk. These give exact references for a future solver. [Mode and disk formulas](verification/slices/torus-oscillator-baseline.md#analytic-checks)
- [ ] **6. Prove smoothness of the primary kernel.** Show smoothness at zero separation using squared Euclidean displacement, vanishing of all derivatives at the support edge, and smoothness near the torus cut locus where the kernel vanishes. This can proceed alongside normalization. [Kernel obligations](decisions/ADR-111.md)
- [ ] **7. Formalize the historical ring reference.** Verify the one-dimensional cosine kernel's row integral and the rotation rates for winding $0,+1,-1$ at contrasts $a=0,0.4,0.8$. This independently checks the sign convention and placement of the coupling strength against the recovered ring equations. [Ring equations and expected rates](mathematics/ring-oscillator-reference.md)

Item 1 verifies exact smooth row mass and the mean bound for every admissible radius and center. [Lean proof](../PWFA/TorusSmoothNormalization.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 2 verifies the explicit synchronized trajectory and its field-valued derivative for all three kernels. [Lean proof](../PWFA/TorusSynchronized.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 3 verifies a unique global solution for every continuous unit-phase initial field, with pointwise unit norm at all real times. [Lean proof](../PWFA/TorusGlobalFlow.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 4 verifies preservation of the two integer winding numbers on local intervals and throughout every global unit-phase solution. [Lean proof](../PWFA/TorusWinding.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 5 verifies the rotating trajectory at every integer frequency pair, reversal and axis exchange, and the exact disk chord integral for every admissible radius. [Lean proof](../PWFA/TorusWaveDisk.lean) · [Extension audit](../scripts/audit-extensions.lean)

## Independent Gate 1

Independent Gate 1 is open. Review preparation can run alongside the Lean work. Each packet should identify the exact slice and revision that an outside reviewer is being asked to judge. [Review gates](verification/review-gates.md)

- [ ] **Reconcile the requirements matrix.** Link each accepted claim to its governing ADR, Lean theorem, assumptions, and audit. Update entries that predate the metric, local-flow, and disk proofs. Keep the outstanding mathematical obligations visible. [Requirements matrix](verification/requirements-matrix.md) · [Proof obligations](verification/proof-obligations.md)
- [ ] **Prepare a commit-pinned torus reviewer packet.** Include the frozen contract, theorem statements, internal findings and remedies, build and audit evidence, and the claims still open. The existing phase-algebra packet covers a narrower scope. [Phase-algebra packet](verification/slices/phase-algebra-review-packet.md) · [Torus contract](verification/slices/torus-oscillator-baseline.md)
- [ ] **Obtain independent review and record closure.** Have the outside reviewer assess the frozen scope. Record each finding, remedy, revision, and verification outcome, then record the disposition for that scope once every finding is closed. [External review request](https://github.com/VORSAR/pwfa/issues/8) · [Gate policy](verification/review-gates.md)

## Decisions and contracts needed for later work

The seven Lean items above can proceed while the owner resolves these simulation and recall questions.

- [ ] **2D simulation protocol.** Decide what grid size means per axis, select the nominal radius and sweep, and specify midpoint stages, quadrature, event alignment, and error and convergence criteria. Retain the recovered time-step and grid-refinement settings as reference points. [Numerical methods](mathematics/numerical-methods.md) · [Radius decision](decisions/ADR-111.md)
- [ ] **Encoding and decoding.** Choose the spatial layout for a 2D encoder or specify a separate 1D benchmark. Fix the pattern-to-phase map, bump normalization, anchored decoder, and handling of ambiguous outputs. [Encoding and decoding](mathematics/encoding-decoding.md)
- [ ] **Memory, homeostasis, and training.** Specify the pairwise update, the quantity driving homeostasis, state domains and initial values, and the reset or carry behavior at each training and retrieval event. Reconcile these with the recovered gain law and sequential training order. [Memory dynamics](mathematics/memory.md) · [Training protocol](experiments/methodology.md)
- [ ] **Recall benchmark.** Choose the matched comparator and resource budget. Freeze the deterministic cue generator, seeds, corruption and rounding rules, exact-recall metric, clustering unit, and treatment of failed retrievals before evaluating the five-percentage-point target. [Benchmark](experiments/benchmarks.md) · [Controls](experiments/baselines.md)

The [research and recovery register](research/open-questions.md) tracks additional open work, including external-knowledge retrieval and reinjection, missing historical decisions, and source recovery.
