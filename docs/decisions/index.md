# Architectural decision index

**Historical source:** [Original recovery snapshot](../history/recovery-original.md). The 15 historical extracts are **partial**, not a complete inventory of PWFA decisions. The original historical total is **NOT VERIFIED** (prior summaries conflicted between 79 and 83). New, owner-approved decisions are identified separately.

| ADR | Topic | Selection | Status |
|---|---|---|---|
| [ADR-046](ADR-046.md) | Independent hostile review gates | C | Recovered-partial; slice-level application via ADR-108 |
| [ADR-055](ADR-055.md) | Close every Gate-1 finding before executable Lean | B | Recovered-partial; global scope superseded by ADR-108 |
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
| [ADR-101](ADR-101.md) | Constrained reconstruction of mathematical core (new decision, 2026-11-22) | A | Accepted strategy; Gate 1 open |
| [ADR-102](ADR-102.md) | Continuous 2D periodic spatial domain (new) | B | Accepted topology; Gate 1 open |
| [ADR-103](ADR-103.md) | Unit-complex phase representation (new) | A | Accepted representation; Gate 1 open |
| [ADR-104](ADR-104.md) | Isotropic distance-based baseline coupling (new) | A | Accepted geometry. [ADR-111](ADR-111.md) defines the profile. |
| [ADR-105](ADR-105.md) | Shortest periodic Euclidean spatial distance (new) | A | Accepted flat-torus metric; Gate 1 open |
| [ADR-108](ADR-108.md) | Scope-limited independent Gate 1 per vertical slice (new) | A | Independent requirement superseded for experiments by ADR-109 |
| [ADR-109](ADR-109.md) | Internal hostile review plus uncertified experimental Lean (new) | A | Accepted experimental governance |
| [ADR-110](ADR-110.md) | Phase-lag law for the flat torus baseline | 1A | Accepted for written review |
| [ADR-111](ADR-111.md) | Finite-range structural coupling on the flat torus | 2A | Accepted profile and comparison kernels. Nominal radius open. |
| [ADR-112](ADR-112.md) | Total site budgets for the first torus grids | B | Accepted 16×8, 16×16, and 32×16. |
| [ADR-113](ADR-113.md) | First torus radius comparison | C | Compare 1/4 and 3/8 at every grid size before choosing a default. |
| [ADR-114](ADR-114.md) | Structural quadrature in torus validation | B | Evolve raw and row-normalized weights as coequal tests. |
| [ADR-115](ADR-115.md) | Torus placement for the first 16-bit recall experiment | A | One bit per cell center on a 4×4 layout. |
| [ADR-116](ADR-116.md) | Anchor for the torus recall decoder | A | Compare each bit observation with the field phase at (0,0) at the same recall time. |
| [ADR-117](ADR-117.md) | Lean experiments for research and architecture choices | Owner directive | Accepted. Check formalizable assumptions and publish reproducible evidence before recommendations. |
| [ADR-118](ADR-118.md) | Bit polarity and relative phase choices | 1A | Primary ±90°, with ±45° as a comparison. |
| [ADR-119](ADR-119.md) | Masked input stimulation | 2A | Omit the bit-specific stimulus and record background initialization. |
| [ADR-120](ADR-120.md) | Cue background for first encoder validation | A | Uniform primary field and a reproducible, target-independent varied sensitivity condition. |
| [ADR-121](ADR-121.md) | Encoder validation grid placement | 1A | Origin-aligned primary and half-cell-shifted sensitivity in both axes. |
| [ADR-122](ADR-122.md) | Recall scoring denominator | A | All scheduled cues primary, with coverage and answered-only accuracy. |
| [ADR-123](ADR-123.md) | First pairwise training input | A | Signed real phase alignment with a complement recall check. |
| [ADR-124](ADR-124.md) | Pairwise memory across training episodes | A | Equal weight per completed episode with the reverse-order ablation retained. |
| [ADR-125](ADR-125.md) | Pairwise summary within each word | A | Time average of signed alignment over a positive-duration training window. |
| [ADR-126](ADR-126.md) | Training window for the first pilot | A | Use the full scheduled episode for each word, including early transients. |
| [ADR-127](ADR-127.md) | Pilot training durations | A | Compare 25 and 50 time units per word on the same development cues. |
| [ADR-128](ADR-128.md) | Weights for learned retrieval | A | Use all stored pairs with equal cell area at both training durations. |

## What these statuses mean

- **Recovered-partial:** User's selected letter or outcome was recovered, but original alternative matrices, assistant recommendations, evidence or exact semantics remain missing.
- **Accepted:** Reserved for a decision whose provenance and scope have been confirmed.
- **Superseded:** Historical choice retained and linked to a replacing ADR.

ADR-057, ADR-058, and ADR-059 have known letters **C/A/B** from a later selection, but their **option meanings are not recovered**. Do not use those entries as an implementation contract.

See [decision policy](README.md), [template](template.md), [proposed dependency map](dependencies.md), [historical chronology](chronology.md), and [recovery status](../history/recovery-status.md).
