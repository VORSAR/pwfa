# Architectural decision index

**Source:** [Original recovery snapshot](../history/recovery-original.md). These 15 extracts are **partial**, not a complete set of historical PWFA decisions. Original total is **NOT VERIFIED** (prior summaries conflicted between 79 and 83).

| ADR | Topic | Recovered selection | Status |
|---|---|---|---|
| [ADR-046](ADR-046.md) | Independent hostile review gates | C | Recovered-partial |
| [ADR-055](ADR-055.md) | Close every Gate-1 finding before executable Lean | B | Recovered-partial |
| [ADR-057](ADR-057.md) | Historical choice with unrecovered semantics | C | Recovered-partial |
| [ADR-058](ADR-058.md) | Historical choice with unrecovered semantics | A | Recovered-partial |
| [ADR-059](ADR-059.md) | Historical choice with unrecovered semantics | B | Recovered-partial |
| [ADR-076a](ADR-076a.md) | Oscillator baseline and controls | C | Recovered-partial |
| [ADR-076b](ADR-076b.md) | Discretization and memory-load sweep | A | Recovered-partial |
| [ADR-093](ADR-093.md) | Global scalar learned gain | C | Recovered-partial |
| [ADR-094](ADR-094.md) | Homeostatic adaptation | C | Recovered-partial |
| [ADR-095](ADR-095.md) | Spatial encoding and anchored decoder | C | Recovered-partial |
| [ADR-096](ADR-096.md) | Sequential memory training and order ablation | C | Recovered-partial |
| [ADR-097](ADR-097.md) | Numerical integration and convergence diagnostics | C | Recovered-partial |
| [ADR-098](ADR-098.md) | Periodic quadrature and quality-gated diagnostics | C | Recovered-partial |
| [ADR-099](ADR-099.md) | Primary associative recall benchmark | C | Recovered-partial |
| [ADR-100](ADR-100.md) | Preregistered performance threshold | C | Recovered-partial |

## What these statuses mean

- **Recovered-partial:** User's selected letter or outcome was recovered, but original alternative matrices, assistant recommendations, evidence or exact semantics remain missing.
- **Accepted:** Reserved for a decision whose provenance and scope have been confirmed.
- **Superseded:** Historical choice retained and linked to a replacing ADR.

ADR-057, ADR-058, and ADR-059 have known letters **C/A/B** from a later selection, but their **option meanings are not recovered**. Do not use those entries as an implementation contract.

See [decision policy](README.md), [template](template.md), [proposed dependency map](dependencies.md), [historical chronology](chronology.md), and [recovery status](../history/recovery-status.md).
