# PWFA architecture recovery — partial v0.26 snapshot

**Recovered:** 2026-11-22. **Status:** PARTIAL, not the original canonical master document.

This snapshot preserves recoverable historical decision summaries from the PWFA project. The original ChatGPT WritingBlock **57318**, its full architecture text, exact ADR option matrices, and original evidence register could not be retrieved. This file must not be treated as a verified substitute for the master. No mathematical claims, benchmark outcomes, or review closures are inferred from missing material.

## Governing constraints

- PWFA proposes a reference computational model built on spatially distributed coupled oscillators, continuous circle-valued phase fields, internal memory and external knowledge, with encoding, storage, retrieval, observation, nonlocal coupling and reinjection.
- Independent hostile review **Gate 1** is mandatory before any executable Lean 4 implementation. **Gate 2** follows the first reference model (ADR-046 choice C).
- **All** Gate-1 findings must be closed, including minor documentation findings. No exceptions by severity (ADR-055 choice B). Gate 1 is **not verified complete**.
- Afterwards, work may proceed iteratively in small vertical slices, via feature branches and pull requests, with pinned Lean/mathlib versions and continuous integration. An indefinitely open architecture backlog is not itself a blocker after the mandatory gate, but individual required contracts are.
- Formal proofs of a model do not establish cognitive or biological validity. Engineering parameter targets are not empirical results.

## Recoverable decisions

| ADR | Choice | Recovered meaning | Unrecovered material |
|---|---|---|---|
| 046 | C | Two independent adversarial review gates: before implementation and after reference model | Exact option matrix, gate procedures |
| 055 | B | Every Gate-1 finding must be closed before executable Lean | Original option/rationale matrix |
| 057 | C | Selection recorded | Exact meaning and option matrix **NOT RECOVERED** |
| 058 | A | Selection recorded | Exact meaning and option matrix **NOT RECOVERED** |
| 059 | B | Selection recorded | Exact meaning and option matrix **NOT RECOVERED** |
| 076a | C | Baseline κ=1, a=0.8, α=π/2−0.1, ω=0; controls a=0/0.4, winding 0/±1 | Symbol definitions, units, schedule |
| 076b | A | N=128/256/512, 16/32-bit patterns, up to 16 memories, 100 libraries | Generation, acceptance rules |
| 093 | C | Global scalar learned gain `K_eff = K0 + 0.25*m/(1+h)` | Underlying evolution, ranges |
| 094 | C | Homeostasis τ_h=50, `dh/dt=(Q-h)/50`; branch-local or carried stimulated h with standardized recall | Q definition, exact resets |
| 095 | C | Smooth compact C∞ bumps centered `(j+1/2)/N`, radius `0.4/N`, anchor 0, t=40 anchored signed-imaginary decoder | Exact normalized encoder/decoder functions |
| 096 | C | Sequential pattern training carries m/h, resets oscillator/trace, deterministic order and reverse-order ablation | Episode schedule and exact reset states |
| 097 | C | Multiplicative phase-midpoint solver; exponential trace/homeostat stages; dt=0.1/0.05/0.025; exact event boundaries; winding and convergence tracking | Solver updates/error guarantees |
| 098 | C | Uniform periodic grid, normalized trapezoidal quadrature, residuals, normalized observation rows, quality-gated diagnostic top-k k=ceil(0.1*N), candidate contrast gate 0.05, no sparsification of pairwise learning | Full observation/quality equations |
| 099 | C | Primary benchmark: 16-bit, 128 samples, four stored patterns, 100 libraries; 10% flipped and 10% masked with no-overlap rounded rule; held-out deterministic cues; sensitivities 32 bits, 256/512 samples, loads 1/8/16, phase/radius/orientation, antipodal and reverse-order | Precise rounding/seeds/baselines/cue algorithm |
| 100 | C | Target ≥5 percentage points exact-recall advantage against preregistered comparator, matched resource budget, clustered 95% confidence interval lower bound >0 | Comparator, cluster unit, interval method, preregistration |

These are **recoveries of selections and summaries**, not verbatim historical Architectural Decision Records (ADRs). In Batch 12, ADR-057/058/059 had been open; later selections C/A/B are recovered. Their semantics remain unverified. ADR-076b is a broader sweep; ADR-099 defines a later narrower primary benchmark.

## Unresolved reconstruction obligations

1. Retrieve or reconstruct the original continuous state space, nonlocal phase-evolution equations, learned pairwise memory equations, kernels, observations, and reinjection mappings. Do not adopt generic textbook formulas by assumption.
2. Recover every parameter's meaning, bound, initialization, reset and carry behavior, including oscillators, traces, m and h. Negative effective kernels were allowed; stability must not be asserted without proof.
3. Recover numerical update formulas, convergence norms, topological diagnostics, normalization/residual rules, and the quality-gate calibration.
4. Specify exact corpus generation, train/test separation, reproducible seeds, deterministic cues, bit corruption and overlap/rounding, controls, ablations, matched resource accounting, statistical cluster and interval methods.
5. Explicitly label every item as mathematical contract, unproved hypothesis, formal proof, numerical test, proposed success criterion, or measured empirical result.
6. Restore complete **append-only** ADR provenance: exact offered A/B/C/Other choices, user decision, contemporary assistant recommendation and reasoning, tradeoffs, proof obligations, scoped primary sources and verification limits, chronology, cross-dependencies, and two-way links.
7. Obtain the complete independent Gate-1 reviewer findings and documentary evidence of **every** closure before any executable Lean code.

## Provenance ledger

- **HIST-001:** PWFA project conversation summaries, 2026-11-19–22 — partial history recovered, complete prior chat inaccessible.
- **HIST-002:** Canonical WritingBlock ID **57318**, target revision v0.26 — **original body not recovered**.
- **HIST-003:** Selected ADR outcomes listed above — recovered selection summaries, not original transcripts.
- **EXT-001:** Independently checked original research citations — **not recovered**. Do not fabricate research references.
- **GATE-001:** Reviewer report and Gate-1 closure — **not found/not verified**.

### Recovery protocol

When the complete master becomes available, compare it against this snapshot, preserve historical wording, and merge without discarding prior ADRs. Mark missing option text **NOT RECOVERED** instead of supplying guesses. Counts of accepted ADRs were inconsistent in summaries (79 versus 83), so no authoritative total is asserted here. The architecture and evidence remain provisional until the independent review gates are documented.

**Implementation status: BLOCKED by ADR-046/055 Gate 1.**