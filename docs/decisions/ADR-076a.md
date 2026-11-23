# ADR-076a: Oscillator baseline and controls

- **Status:** Recovered-partial (user selection recorded; primary transcript unavailable)
- **Selected option:** C
- **Decision date:** NOT RECOVERED
- **Source:** [Archived recovery snapshot](../history/recovery-original.md) (HIST-003)
- **Related ADRs:** [ADR-076b](ADR-076b.md), [ADR-097](ADR-097.md)
- **Authoritative review:** NOT VERIFIED

## Context

This entry isolates a historical decision summary from the recovery snapshot. It is **not** the original verbatim discussion or a substitute for an independently reviewed specification.

## Alternatives presented at decision time

- **A:** **NOT RECOVERED**
- **B:** **NOT RECOVERED**
- **C:** Baseline κ=1, a=0.8, α=π/2−0.1, ω=0. Controls: a=0/0.4 and winding 0/±1. *(recovered summary, not verbatim original option text)*
- **Other:** **NOT RECOVERED**

The source summarizes the selected outcome. The actual choice wording and complete offered alternatives are **NOT RECOVERED**.

## Recovered user decision

**Option C.** Baseline κ=1, a=0.8, α=π/2−0.1, ω=0. Controls: a=0/0.4 and winding 0/±1.

## Contemporaneous assistant recommendation

**NOT RECOVERED.** No retrospective recommendation is attributed to the original assistant.

## Rationale, tradeoffs, and consequences

The original comparative rationale and tradeoffs were **NOT RECOVERED**. Baseline/reference model configuration. is the recovered scope; it is not a claim of validity or performance.

## Proof and test obligations

*Reconstruction work item, not a recovered verbatim original obligation:* Recover exact continuous equations, parameter units/domains, phase setup and controls before numerical claims.

## Missing evidence and source limits

The initial extraction lacked definitions, units, admissible domains, precise initial states, the control schedule, and complete alternatives. The amendment below records a later partial recovery. Original research citations and evidence scope remain unavailable. See the [recovery status](../history/recovery-status.md).

## Traceability and dependencies

Related ADRs: [ADR-076b](ADR-076b.md), [ADR-097](ADR-097.md)

Cross-links are **proposed recovery navigation**, not verified historical cross-references. The governing [ADR index](index.md) and archived snapshot track this decision.

## Amendments (append-only)

- **2026-11-22:** Created this partial extraction from the archived recovery snapshot. Missing original evidence and alternatives remain marked **NOT RECOVERED**. No new architectural decision made.
- **2026-11-23:** Recovered the ring cosine kernel, continuous phase law, and parameter meanings from master excerpts. The amplitude $a$ controls cosine modulation, with uniform all-to-all coupling at $a=0$. The [historical ring reference](../mathematics/ring-oscillator-reference.md) records the equations and derived winding checks. The [evidence register](../research/evidence-register.md) identifies the excerpts. The original option matrix and comparative rationale remain unavailable.
