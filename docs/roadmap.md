# PWFA roadmap

**Measure progress by whole-word recall.** Use exact 16-bit recovery on every scheduled cue at $t=40$ to rank development choices. The project’s success criterion is at least a five-percentage-point advantage on held-out cues over a matched-budget comparator, with the lower bound of the clustered 95% confidence interval above zero. [Mission criterion](decisions/ADR-100.md) · [Scoring denominator](decisions/ADR-122.md)

**Next review milestone:** obtain an independent disposition on the [frozen torus oscillator packet](verification/slices/torus-oscillator-review-packet.md).

**Next empirical milestone.** Improve exact 16-bit recall at $t=40$ and evaluate on untouched libraries. Free and held training each recovered 0/16 corrupted cues and retained 0/4 clean words with the same retrieval dynamics. [Training comparison](experiments/held-word-training.md#results-at-retrieval-time-40)

## Verified starting point

At [commit `cafd238`](https://github.com/VORSAR/pwfa/commit/cafd238daa78d872977a1275dcda13623af4eb0a), Lean checks the phase algebra, shortest periodic Euclidean distance, continuous mean field, and local phase solutions for the smooth, disk, and uniform kernels. Solutions from the same initial field agree near the initial time. Each point keeps its initial modulus throughout the local interval. The disk kernel integrates to one at every center. [Oscillator baseline](verification/slices/torus-oscillator-baseline.md) · [Lean CI](https://github.com/VORSAR/pwfa/actions/runs/45375224871)

## Delivered tooling and documentation

- [x] **Pin the Lean environment.** The repository pins Lean and mathlib for reproducible builds. The Mac clone reported Lean 4.35.0 and Lake 5.0.0-src+eb6cafb. [Toolchain](../lean-toolchain) · [Dependency manifest](../lake-manifest.json)
- [x] **Document the proofs in the source.** Module comments link the seven deliverables to their governing specifications. The proof revision passed both GitHub checks. [Proof revision](https://github.com/VORSAR/pwfa/commit/3e9368636fee99cc00b5be0d024e5a95424e6875) · [Lean CI](https://github.com/VORSAR/pwfa/actions/runs/45385868482) · [Documentation CI](https://github.com/VORSAR/pwfa/actions/runs/45385868517)
- [x] **Add the Lean verification toolkit.** The repository includes review guidance, audit scripts, worked examples, and five evaluation cases. [Verification guide](../.claude/skills/lean-verify/SKILL.md) · [Evaluation cases](../.claude/skills/lean-verify/evals)
- [x] **Make Lean experiments part of research decisions.** Check formalizable assumptions before recommendations, preserve the results, and rerun the experiments in CI. [Decision](decisions/ADR-117.md) · [Research checks](../scripts/experiments)

## Seven verified Lean deliverables

Each checked item has a compiled theorem, a statement and dependency audit, and an internal review. The entries preserve the original scope and order. [Phase-law decision](decisions/ADR-110.md) · [Experimental review policy](decisions/ADR-109.md)

- [x] **1. Normalize the smooth kernel.** Integrate the chosen radial bump over its support and recover the denominator $\pi R^2\int_0^1 b(s)\,ds$. Prove the kernel row integrates to one for every center and every $0<R<1/2$. Apply the existing mean-field bound to show that smooth averaging cannot increase the supremum norm. [Smooth-kernel specification](verification/slices/torus-oscillator-baseline.md#smooth-primary-kernel) · [Mean-field bounds](../PWFA/TorusMeanField.lean)
- [x] **2. Prove the exact synchronized trajectory.** Starting from any spatially constant unit phase, prove that the trajectory rotates at angular velocity $\omega-\kappa\sin\alpha$. A single proof for a unit-mass kernel covers the disk and uniform cases now. Item 1 supplies the remaining hypothesis for the smooth case. [Analytic checks](verification/slices/torus-oscillator-baseline.md#analytic-checks)
- [x] **3. Extend solutions to all time.** Prove existence and uniqueness for every real time from any continuous unit-phase field. Use modulus preservation to keep the supremum norm bounded and obtain a uniform local restart interval. This can proceed independently of items 1 and 2. [Local flow](../PWFA/TorusLocalFlow.lean) · [Velocity bound](../PWFA/TorusVelocityBound.lean)
- [x] **4. Prove both winding numbers are preserved.** Restrict a trajectory to each of the two coordinate loops and prove its integer winding number stays constant over the local solution interval. Item 3 extends the result to all time. [Phase-law obligations](decisions/ADR-110.md) · [State space](mathematics/state-space.md)
- [x] **5. Verify spatial wave rotation rates.** For modes $(\pm1,0)$, $(0,\pm1)$, and $(1,1)$, derive $\Omega_q=\omega-\kappa\lambda_q\sin\alpha$. Check reversal and axis-exchange symmetry, the zero coupling contribution for nonzero modes under uniform weights, and the specified one-dimensional chord integral for the disk. These give exact references for a future solver. [Mode and disk formulas](verification/slices/torus-oscillator-baseline.md#analytic-checks)
- [x] **6. Prove smoothness of the primary kernel.** Show smoothness at zero separation using squared Euclidean displacement, vanishing of all derivatives at the support edge, and smoothness near the torus cut locus where the kernel vanishes. This can proceed alongside normalization. [Kernel obligations](decisions/ADR-111.md)
- [x] **7. Formalize the historical ring reference.** Verify the one-dimensional cosine kernel's row integral and the rotation rates for winding $0,+1,-1$ at contrasts $a=0,0.4,0.8$. This independently checks the sign convention and placement of the coupling strength against the recovered ring equations. [Ring equations and expected rates](mathematics/ring-oscillator-reference.md)

Item 1 verifies exact smooth row mass and the mean bound for every admissible radius and center. [Lean proof](../PWFA/TorusSmoothNormalization.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 2 verifies the explicit synchronized trajectory and its field-valued derivative for all three kernels. [Lean proof](../PWFA/TorusSynchronized.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 3 verifies a unique global solution for every continuous unit-phase initial field, with pointwise unit norm at all real times. [Lean proof](../PWFA/TorusGlobalFlow.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 4 verifies preservation of the two integer winding numbers on local intervals and throughout every global unit-phase solution. [Lean proof](../PWFA/TorusWinding.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 5 verifies the rotating trajectory at every integer frequency pair, reversal and axis exchange, and the exact disk chord integral for every admissible radius. [Lean proof](../PWFA/TorusWaveDisk.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 6 verifies joint smoothness in arbitrary periodic coordinates, zero derivatives of every order at the edge, and a neighborhood of zero kernel at each half-period coordinate tie. [Lean proof](../PWFA/TorusKernelSmoothness.lean) · [Extension audit](../scripts/audit-extensions.lean)

Item 7 verifies the historical ring kernel’s row integral, its action on Fourier modes, and the exact time-dependent solutions and rates for the three recovered contrasts. [Lean proof](../PWFA/HistoricalRing.lean) · [Extension audit](../scripts/audit-extensions.lean)

## Independent Gate 1

Independent Gate 1 is open. The oscillator packet can cover the frozen unforced torus contract while work on the encoder and learned memory proceeds. The packet fixes the claims and revision for the outside reviewer. [Review gates](verification/review-gates.md)

- [x] **Reconcile the oscillator requirements matrix.** The frozen claim table identifies assumptions and public theorems for geometry, kernels, flow, winding, waves, smoothness and the ring reference. The system-level obligations are tracked separately. [Requirements matrix](verification/requirements-matrix.md) · [Proof obligations](verification/proof-obligations.md)
- [x] **Prepare a commit-pinned torus reviewer packet.** The [packet](verification/slices/torus-oscillator-review-packet.md) pins the contract and proofs, identifies internal remedies and passed build evidence, and provides a procedure to record independent findings and closure. [Phase-algebra packet](verification/slices/phase-algebra-review-packet.md) · [Torus contract](verification/slices/torus-oscillator-baseline.md)
- [ ] **Obtain independent review and record closure.** Have the outside reviewer assess the frozen scope. Record each finding, remedy, revision, and verification outcome, then record the disposition for that scope once every finding is closed. [Earlier review request, closed as not planned](https://github.com/VORSAR/pwfa/issues/8) · [Gate policy](verification/review-gates.md)

## Decisions and contracts needed for later work

The next simulation and recall work requires the following owner decisions.

- [x] **Choose the 2D grid sizes.** Preserve 128, 256, and 512 total sites on 16×8, 16×16, and 32×16 periodic grids. [Grid decision](decisions/ADR-112.md)
- [x] **Choose the first radius comparison.** Test $R=1/4$ and $R=3/8$ at each grid size before choosing a default. [Radius comparison](decisions/ADR-113.md)
- [x] **Choose the structural quadrature comparison.** Evolve raw and row-normalized weights as coequal tests, recording raw mass errors. [Quadrature decision](decisions/ADR-114.md)
- [x] **Choose the encoder validation grid placement.** Use origin-aligned nodes, then repeat with a half-cell shift in both axes. [Grid placement](decisions/ADR-121.md)
- [ ] **Time stepping.** Specify the midpoint update and stage order, and handling of events between scheduled steps. [Numerics](mathematics/numerical-methods.md)
- [ ] **Solver diagnostics and validation.** Specify discrete winding, raw-mass and wave-rate residuals, time and space refinement, error norms and tolerances. Compare both approved radii before selecting a default. [Numerics](mathematics/numerical-methods.md) · [Radius study](decisions/ADR-113.md)
- [x] **Choose the first 16-bit encoder geometry.** Place one bit at each cell center of a 4×4 torus layout. [Encoder geometry](decisions/ADR-115.md)
- [x] **Choose the recall anchor.** Read each observed phase relative to the field at the spatial origin at the same recall time. [Anchor decision](decisions/ADR-116.md)
- [x] **Choose the bit phases and polarity.** Use negative offsets for 0 and positive for 1, with ±90° primary and ±45° for comparison. [Bit-phase decision](decisions/ADR-118.md)
- [x] **Choose the masked-cue behavior.** Omit the bit stimulus, record how the background was initialized, and score masked positions at recall. [Mask decision](decisions/ADR-119.md)
- [x] **Choose the cue backgrounds.** Use a uniform primary field and a reproducible, target-independent varied field for sensitivity testing. [Background decision](decisions/ADR-120.md)
- [ ] **Physical encoder.** Assign bit indices to centers. Specify bump profile, support radius and normalization, and how and when a presented bit sets its phase on a varied background. [Encoder contract](mathematics/encoding-decoding.md)
- [ ] **Sensitivity inputs.** Define the reproducible varied-background generator, spatial scale and amplitude, and the 32-bit layout. [Background decision](decisions/ADR-120.md) · [Benchmark](experiments/benchmarks.md)
- [ ] **Observation and decoding.** Choose point sampling or spatial pooling, weights, evaluation at the origin, confidence threshold, tie/abstention behavior and diagnostic quality rules. [Decoder contract](mathematics/encoding-decoding.md) · [Diagnostic controls](decisions/ADR-098.md)
- [ ] **Pairwise memory and homeostasis.** Define learned coupling and trace updates, the drive $Q$, allowed signs and state bounds, initial values, and how the denominator in the recovered gain law stays valid. [Memory dynamics](mathematics/memory.md)
- [x] **Choose and check the first pairwise training input.** The owner selected signed alignment. [Decision](decisions/ADR-123.md) Lean checks signed alignment, the loss of sign on squaring, and invariance under word complementation at the ideal phases. [Pairwise test](research/recall-pilot-checks.md#pairwise-input-to-the-learning-rule)
- [x] **Choose and check spatial weights for learned retrieval.** Use all stored pairs with equal cell-area weights. [Decision](decisions/ADR-128.md) Lean bounds each learned mean by its integration weight sum and shows when a distant stored pair affects instantaneous phase speed. The learned multiplier still needs a choice. [Spatial weight checks](research/recall-pilot-checks.md#which-stored-pairs-reach-the-retrieval-field)
- [x] **Choose the learned retrieval lag.** Use zero lag in both pilot conditions. The reference structural lag is $\pi/2-0.1$. [Decision](decisions/ADR-129.md)
- [x] **Check the learned lag at the recall endpoint in a solvable control.** Lean verifies the two-site relative trajectory and compares the remaining phase error at $t=40$ with zero and structural lag. [Derivation and scope](research/recall-pilot-checks.md#two-site-phase-correction-at-t40)
- [x] **Choose how completed episodes contribute.** Give each episode equal weight in each pair’s memory. [Decision and checked bounds](decisions/ADR-124.md)
- [x] **Build and read the four-word memory on exact control histories.** The executable Lean reference checks both pilot durations, the dense learned field, and matrix symmetry and diagonal entries. [Control, expected values and command](research/recall-pilot-checks.md#exact-four-word-training-and-retrieval-control)
- [x] **Choose and check the summary within a training episode.** Average signed alignment by elapsed time. Lean verifies the unit-phase bounds and correct weighting at an interior time boundary. [Within-word decision](decisions/ADR-125.md) · [Window checks](research/recall-pilot-checks.md#exact-time-averages-on-a-training-window)
- [x] **Choose the averaging window.** Use the full scheduled episode, including early transients. Cue timing within the episode remains open. [Full-window decision](decisions/ADR-126.md)
- [x] **Choose and check the pilot training durations.** Run matched conditions at 25 and 50 time units per word. [Decision](decisions/ADR-127.md) Lean verifies the exact homeostat response for constant unit drive, example alignment means, and nominal step counts for 25 and 50 time units per word. [Duration checks](research/recall-pilot-checks.md#checked-duration-candidates)
- [x] **Check the exponential stage and its effect within an episode.** Lean verifies interval preservation, a sufficient condition for the scalar gain denominator, and an order-sensitive example for the terminal trace. [Exact stage checks](research/recall-pilot-checks.md#what-the-trace-retains-within-one-episode)
- [ ] **Training and retrieval events.** Specify stimulus timing, exact reset/carry values, branch behavior and the standardized recall transition. The recovered sequential presentation and carry/reset categories already constrain these choices. [Training protocol](experiments/methodology.md) · [Training decision](decisions/ADR-096.md)
- [x] **Measure first trained recall at $t=40$.** On one development library with four stored words and 16 corrupted cues, run paired 25/50 training and a disabled-learning control at two time steps. Archive complete predictions and masked and flipped recovery. [Protocol and results](experiments/first-trained-recall.md)
- [x] **Distinguish clean-word retention from information loss in the cues.** The model retained 0/4 clean words at the endpoint, while a static lookup identified 16/16 targets from the corrupted cues. [Diagnostic results](experiments/first-trained-recall.md#diagnostic-results)
- [x] **Compare held and freely evolving training words.** Paired runs at both time steps measured exact recall and clean retention with structural retrieval active. [Results and predictions](experiments/held-word-training.md#results-at-retrieval-time-40)
- [ ] **Improve and confirm recall on untouched libraries.** Isolate the effect of structural coupling during retrieval on the existing trained memories. Evaluate changes on corrupted development cues, then freeze the chosen protocol before the held-out benchmark. [Recall endpoint](experiments/benchmarks.md#first-trained-recall-measurement)
- [x] **Choose the primary recall denominator and check the scorer.** Use all scheduled cues, with coverage and answered-only accuracy. [Decision](decisions/ADR-122.md) Lean checks flipped and masked positions, incomplete predictions, failed runs, and the effect of the reporting denominator. [Scoring checks](research/recall-pilot-checks.md#counting-exact-words)
- [x] **Score exported recall results against a predeclared schedule.** The [Lean scoring command](experiments/benchmarks.md#score-a-recall-export) counts missing cues, verifies IDs and endpoint labels, and reports all three fractions and corruption diagnostics.
- [x] **Compare paired training durations by cue.** The scorer reports each duration’s metrics, the four paired exact-word counts, IDs recovered in only one condition, and the signed accuracy difference. [Checked command](research/recall-pilot-checks.md#paired-command-check)
- [x] **Export the same visible cues for both durations.** The evaluator converts a frozen schedule into IDs and 16 presented symbols, including omitted positions. Lean checks that changing the hidden bits under masks leaves the input identical. [Cue export](research/recall-pilot-checks.md#visible-cue-export)
- [x] **Check a roster for indistinguishable retrieval inputs.** Count visible cues paired with competing targets and report a proven deterministic exact-word ceiling for a fixed library and retrieval condition. [Ambiguity check](research/recall-pilot-checks.md#identical-cues-with-different-targets)
- [ ] **Matched recall comparison.** Choose the external comparator, equal-resource budget and training/evaluation schedule. [Benchmark](experiments/benchmarks.md) · [Controls](experiments/baselines.md)
- [ ] **Preregister cues and analysis.** Specify seeds and independent splits, rounding for non-overlapping flips and masks, across-library aggregation, decoder threshold, cluster unit, confidence interval and sample-size justification. Measure the five-percentage-point target on held-out cues. [Benchmark](experiments/benchmarks.md)

## Further research and historical recovery

- [ ] Specify external knowledge payloads, provenance, retrieval/reinjection timing and error handling, or explicitly defer that component. [Interface inventory](architecture/interfaces.md)
- [ ] Recover the meanings of historical ADR-057 through ADR-059, original choice matrices, and missing primary sources where available. [Research and recovery register](research/open-questions.md)
