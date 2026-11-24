# PWFA core-specification gap register

**Status:** Active gap inventory. ADR-101 through ADR-105 are approved owner choices; mathematical completeness and Gate 1 remain open.  
**Baseline:** [2026-11-22 repository baseline](../../README.md)  
**Tracking:** [Issue #5](https://github.com/VORSAR/pwfa/issues/5); [ADR-101](../decisions/ADR-101.md), [ADR-102](../decisions/ADR-102.md), [ADR-103](../decisions/ADR-103.md), [ADR-104](../decisions/ADR-104.md), [ADR-105](../decisions/ADR-105.md)  
**Review:** The [phase-only experiment](../verification/slices/phase-algebra-experiment.md) compiled in CI under [ADR-109](../decisions/ADR-109.md). Independent certification is open. [Phase review packet](../verification/slices/phase-algebra-review-packet.md).

## Classification

- **RECOVER:** identify independently attributable original source, preserve exact wording and provenance; otherwise mark NOT RECOVERED.
- **DECIDE:** record new explicit A/B/C/Other alternatives with owner-selected decision, date, rationale, costs, evidence, and obligations. Never retrofit into the historical record.
- **VERIFY:** independently check a fully specified claim, formula, numerical diagnostic, or experimental protocol.
- **P0:** blocks a coherent mathematical or preimplementation review contract. **P1:** blocks downstream empirical evaluation or scope. **P2:** governance or maintenance.

## Newly resolved decisions and unresolved detail

- GAP-001: spatial **topology** selected as T² in ADR-102; phase representation selected as unit-complex S¹ in ADR-103; shortest periodic Euclidean metric selected in ADR-105. Still missing integration measure, function-space regularity and initial conditions. Therefore GAP-001 remains **partially open**, not closed.
- GAP-002: ADR-104 selects the isotropic distance-based baseline and ADR-105 supplies the periodic metric. [ADR-110](../decisions/ADR-110.md) transfers the [historical ring phase law](../mathematics/ring-oscillator-reference.md) to continuous torus phases. [ADR-111](../decisions/ADR-111.md) selects the smooth finite-range kernel and controls. [ADR-113](../decisions/ADR-113.md) selects two radii for comparison. A default radius, independent oscillator review, and the learned interaction remain open.
- GAP-001 experimental sub-slices: [phase algebra](../verification/slices/phase-algebra-experiment.md), [phase conjugation](../verification/slices/phase-inverse-experiment.md), and [Euclidean torus distance](../verification/slices/spatial-metric-remediation.md) have bounded internal authorizations. Independent review and the full state-space contract remain open.
- GAP-005: [ADR-115](../decisions/ADR-115.md) selects a 4×4 torus layout for the first 16-bit recall experiment. [ADR-116](../decisions/ADR-116.md) selects the instantaneous phase at the origin as the recall anchor. [ADR-118](../decisions/ADR-118.md) sets symbol offsets and polarity, and [ADR-119](../decisions/ADR-119.md) sets mask behavior. [ADR-120](../decisions/ADR-120.md) sets the primary and sensitivity background conditions. The varied-background generator, bumps, observations, and decoder calibration remain open.
- GAP-007/008: [ADR-112](../decisions/ADR-112.md) fixes the first three grid shapes and total site counts. [ADR-114](../decisions/ADR-114.md) selects paired raw and normalized structural quadrature. The discrete winding, observation quality, and convergence diagnostics still need a numerical contract.

## Critical dependency register

| ID | Priority | Type | Missing contract or evidence | Source | Completion criterion | Depends on |
|---|---|---|---|---|---|---|
| GAP-001 | P0 | RECOVER→DECIDE | Spatial domain, circle phase topology, state variable types, admissible regularity and initial values | [State space](../mathematics/state-space.md), [ADR-076a](../decisions/ADR-076a.md) | Single normative definition with symbols, domains, units and explicit assumptions | — |
| GAP-002 | P0 | RECOVER→DECIDE | Nonlocal phase evolution, kernel, sign/orientation and parameters | [Evolution](../mathematics/evolution.md), [ADR-076a](../decisions/ADR-076a.md) | Explicit evolution equation and kernel with parameter domains, controls, initial conditions and well-posedness obligations | GAP-001 |
| GAP-003 | P0 | RECOVER→DECIDE | Pairwise learned-memory law, trace dynamics, initialization and retention | [Memory](../mathematics/memory.md), [ADR-093](../decisions/ADR-093.md) | Complete memory update equation compatible with recovered gain; persistence/interference questions stated as hypotheses | GAP-001, GAP-002 |
| GAP-004 | P0 | RECOVER→DECIDE | Definition of Q, homeostat h and denominator safety under allowed negative coupling | [Memory](../mathematics/memory.md), [ADR-094](../decisions/ADR-094.md) | Explicit Q and homeostatic state equations, initial values, admissible bounds or stated counterexamples | GAP-002, GAP-003 |
| GAP-005 | P0 | RECOVER→DECIDE | Bit-to-stimulation map, compact bump formula, normalization, anchored signed-imaginary decoder and ambiguity treatment | [Encoding-decoding](../mathematics/encoding-decoding.md), [ADR-095](../decisions/ADR-095.md) | Complete deterministic encode/observe/decode contract with numerical outputs and applicable correctness hypotheses | GAP-001, GAP-002 |
| GAP-006 | P0 | RECOVER→DECIDE | Training and recall event schedule, episode duration and every trace/phase/memory/homeostat carry/reset | [Data flow](../architecture/data-flow.md), [ADR-096](../decisions/ADR-096.md) | State transition table and event timeline with deterministic replay semantics | GAP-003, GAP-004, GAP-005 |
| GAP-007 | P0 | RECOVER→DECIDE→VERIFY | Concrete midpoint step map, exponential stage order, event alignment, winding and convergence metrics | [Numerics](../mathematics/numerical-methods.md), [ADR-097](../decisions/ADR-097.md) | Discrete update equations, error definitions and testable convergence criteria | GAP-002, GAP-004, GAP-006 |
| GAP-008 | P0 | RECOVER→DECIDE→VERIFY | Periodic quadrature, row normalization, residual and quality diagnostics, top-k tie rules | [Numerics](../mathematics/numerical-methods.md), [ADR-098](../decisions/ADR-098.md) | Explicit formulas and diagnostics; no unintended sparsification of learned pairwise coupling | GAP-005, GAP-007 |
| GAP-009 | P0 | VERIFY | Independent mathematical certification still outstanding; experimental slices instead follow ADR-109 internal hostile review and every in-scope finding's documented closure | [Review gates](../verification/review-gates.md), [ADR-046](../decisions/ADR-046.md), [ADR-055](../decisions/ADR-055.md) | Review dossier, complete findings ledger, closure evidence and independent authorization; executable Lean blocked until then | GAP-001–008, GAP-010 |
| GAP-010 | P1 | RECOVER→DECIDE | Exact recall metric, comparator, matched budget, deterministic cue/corruption rule, sampling, statistical cluster and power | [Benchmark](../experiments/benchmarks.md), [ADR-099](../decisions/ADR-099.md), [ADR-100](../decisions/ADR-100.md) | Preregistered protocol specifying all choices without observed benchmark results | GAP-005, GAP-006 |
| GAP-011 | P1 | RECOVER→DECIDE | External knowledge payload, provenance, timing, consistency, reinjection and error policy | [Interfaces](../architecture/interfaces.md) | Version-independent normative external knowledge contract or explicit deferred scope decision | GAP-001, GAP-005 |
| GAP-012 | P1 | RECOVER | Historical ADR alternatives, contemporaneous rationale, ADR-057/058/059 meanings and primary source bibliography | [Decision index](../decisions/index.md), [Evidence register](../research/evidence-register.md) | Each recovered fact links to verifiable evidence, otherwise remains explicitly NOT RECOVERED | — |
| GAP-013 | P1 | VERIFY | Requirement-to-equation-to-proof/test traceability | [Requirements matrix](../verification/requirements-matrix.md), [Proof obligations](../verification/proof-obligations.md) | Stable links and testable assumptions; no theorem or empirical claim marked proven without artifact | GAP-001–010 |
| GAP-014 | P2 | VERIFY | Enforced PR review, branch rules, and semantic ADR/traceability checks | [Contributing](../../CONTRIBUTING.md), [Docs CI](../../.github/workflows/docs-check.yml) | Confirm branch rules via GitHub settings and add semantic checks without treating CI as independent review | — |

**Gate sequencing:** GAP-009 requires an agreed reviewable specification and all finding closure. The register does not authorize implementation. Recovery research and documentation proposals may proceed concurrently; no requirement to fully reconstruct unrelated historical ADRs before reviewing a new specification.

## First owner decision to request: model reconstruction strategy

**Question:** How should we establish the missing governing PWFA mathematical equations without fabricating their provenance?

| Rank for original intent | Option | Alignment | Feasibility | Advantages | Costs and risks |
|---|---|---|---|---|---|
| 1 | **A: constrained reconstruction** — recover exact primary sources where possible; formulate candidate nonlocal circle-valued oscillator equations constrained by recovered choices; submit new decisions and independent review | High, but not proof of exact historical fidelity | Medium | Preserves continuous nonlocal phase-field and pairwise memory concept; supports explicit obligations | Requires choices for unrecovered operators and can expose ill-posedness; provenance must be labeled new |
| 2 | **B: minimal closed reference model** — choose simplest mathematically closed periodic phase/memory system first; retain roadmap to spatial nonlocal PWFA | Medium | High | Faster path to a reviewable mathematical kernel and bounded proof surface | May omit original nonlocal/memory behavior and distort later claims |
| 3 | **C: historical recovery first** — defer new model contracts until original master equations and choice matrices are recovered | Highest only if source can actually be retrieved; otherwise indeterminate | Low | Avoids prematurely choosing a replacement | Unknown recovery horizon; makes progress contingent on missing transcripts |
| 4 | **Other: discrete-only surrogate** — define a finite-state or purely discrete oscillator model as canonical | Low | High | Easier formal finite-model reasoning | Replaces the original continuous spatial problem, not faithful as the governing reference |

**Owner decision (2026-11-22): A**, recorded as [ADR-101](../decisions/ADR-101.md). The recommendation was contemporaneous, not a recovered historical recommendation. Rank is qualitative based on known recovered intent and availability of a concrete path; no empirical feasibility rates have been measured.

**Scope:** The owner accepted the reconstruction strategy only; specific state-space and equation choices remain pending. No normative replacement equation has been approved.
