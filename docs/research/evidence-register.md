# Evidence register

The original research bibliography remains unavailable. The external papers below provide comparisons for the ring, flat torus, and phase encoding. Their connection to PWFA is the comparison described in each entry.

| ID | Source | Verification | Scope and limits |
|---|---|---|---|
| HIST-001 | Earlier PWFA project discussion summaries | Partial recovery | Original full transcript inaccessible |
| HIST-002 | PWFA master WritingBlock 57318, 2026-11-22 revisions v0.24 section 6, v0.25 sections 4–5, and v0.26 sections 3–4 | Partial project excerpts checked 2026-11-23 | Establishes the unit ring, cosine kernel, recovered parameter meanings, and structural phase law in [ADR-076a](../decisions/ADR-076a.md) and the [ring reference](../mathematics/ring-oscillator-reference.md). The complete master and original option matrix remain unavailable. |
| HIST-003 | [Original committed recovery snapshot](../history/recovery-original.md) | Verifiable Git artifact | Records partial decisions, not the original historical options |
| EXT-001 | Original external source bibliography | **NOT RECOVERED** | No causal or validity claims may be sourced to missing bibliography |
| EXT-002 | [Abrams and Strogatz, *Chimera States for Coupled Oscillators* (2004)](https://arxiv.org/pdf/nlin/0407045), Eqs. 1–2 | Primary paper checked 2026-11-23 | Independent precedent for unit-mass cosine coupling on a ring and the phase-lag sign convention. [Historical ring reference](../mathematics/ring-oscillator-reference.md) |
| EXT-003 | [Panaggio and Abrams, *Chimera States on a Flat Torus* (2013)](https://arxiv.org/pdf/1211.2021), Eqs. 1 and 4 | Primary author manuscript checked 2026-11-23 | Supports the torus phase-law comparison. Its coordinate-cosine kernel uses different geometry from the radial profile in [ADR-104](../decisions/ADR-104.md). |
| EXT-004 | [Omel’chenko et al., *Stationary patterns of coherence and incoherence in two-dimensional arrays of non-locally coupled phase oscillators* (2012)](https://webdoc.sub.gwdg.de/ebook/serien/e/wias/2012/wias_preprints_1682.pdf), Eqs. 1 and 6 | Primary author manuscript checked 2026-11-23 | Supports the periodic disk geometry and normalization used in the [torus comparator](../verification/slices/torus-oscillator-baseline.md#published-disk-comparator). The continuum variable in that work is a local mean field. |
| EXT-005 | [Zhao and Li, 2024 online / 2025 issue](https://doi.org/10.1017/S0956792524000238) | Primary paper checked 2026-11-24 | Introduction and three-pattern construction. Antipodal pairwise phase differences and stability under a Hebbian second-harmonic model. [Encoder implications](bit-to-phase-map.md) |
| EXT-006 | [Fu et al., 2025](https://doi.org/10.1137/24M1702477) | Primary paper checked 2026-11-24 | Abstract. Higher-order self-dynamics breaks common phase-translation symmetry in their retrieval model. [Encoder implications](bit-to-phase-map.md) |
| EXT-007 | [Hashimoto et al., 2026](https://doi.org/10.1587/transfun.2025MAP0008) | Primary paper checked 2026-11-24 | Abstract. Simulated retrieval under a periodic softmax energy on a finite product of unit circles. [Encoder implications](bit-to-phase-map.md) |
| EXT-008 | [Liu and Li, 2026](https://arxiv.org/abs/2609.14389) | Primary preprint checked 2026-11-24 | Introduction. In their higher-order Winfree models, binary fixed points include unstored patterns; stability and auxiliary fields distinguish them. [Encoder implications](bit-to-phase-map.md) |
| EXT-009 | [Frady and Sommer, 2019](https://doi.org/10.1073/pnas.1902653116) | Primary paper checked 2026-11-24 | Threshold phasor model, equations 1–4. The model permits silent zero-amplitude units, a different state space from the PWFA unit-phase field. [Encoder implications](bit-to-phase-map.md) |
| GATE-001 | Independent pre-implementation Gate-1 findings and closure | **NOT VERIFIED** | No executable Lean implementation authorization |

New entries must include: canonical source link/identifier, author/date, primary vs secondary status, specific claim supported, the exact relevant section, evidence limitations, date checked, and affected requirements/ADRs.

For this registry, **Git commits prove what was committed**, not that scientific or historical claims are correct.

[Research questions](open-questions.md) · [Proof obligations](../verification/proof-obligations.md) · [Recovery status](../history/recovery-status.md).
