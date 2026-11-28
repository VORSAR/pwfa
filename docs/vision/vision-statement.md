# Vision statement

**Status:** owner statement, recorded on 2026-11-28. PWFA stands for **Persistent Wave-Field Architecture**. The statement below is reproduced as the owner supplied it. It has not been compared with the unrecovered master document. [Recovery status](../history/recovery-status.md) · [Evidence register](../research/evidence-register.md)

## Statement

> The original vision of **Persistent Wave-Field Architecture (PWFA)** is to explore a fundamentally different foundation for artificial intelligence, inspired by the brain's continuous, distributed, and persistent information processing. Rather than treating intelligence as a sequence of discrete computations, PWFA investigates whether interacting, multidimensional wave fields can simultaneously represent information, perform computation, form associative memories, and retrieve knowledge. Its central hypothesis is that information can exist as evolving spatial and temporal patterns, with learning emerging through changes in the relationships between those patterns. The ultimate ambition is an architecture with persistent internal state, capable of integrating external knowledge, adapting through experience, and developing increasingly complex computational behavior without requiring every operation to be explicitly orchestrated.
>
> **PWFA is not intended to be another large language model, transformer architecture, conventional neural network, or simulation of biological neurons.** It does not aim to reproduce the brain's anatomy, imitate consciousness, or claim biological equivalence. Nor is it simply a wave-based implementation of existing neural-network algorithms, a conventional database with a different retrieval mechanism, or a collection of oscillators producing interesting mathematical behavior. Those mechanisms may serve as research tools, but they are not the objective. PWFA seeks to determine whether persistent wave dynamics constitute a genuinely useful computational primitive, with learning, memory, and information processing arising from the architecture's underlying dynamics. Its validity must come from mathematical consistency, reproducible experiments, and measurable advantages against established computational baselines—not biological analogies or theoretical elegance alone.

## How the repository relates to the statement

The notes below connect the statement to existing documents. They are commentary and record no new decision.

**Central hypothesis.** Information can exist as evolving spatial and temporal patterns, and learning can emerge through changes in the relationships between those patterns. This is a research hypothesis. Nothing in the repository demonstrates it yet. [Hypotheses and claims](hypotheses.md)

**Standard of validity.** The statement accepts mathematical consistency, reproducible experiments, and measurable advantages against established computational baselines. Biological analogy and theoretical elegance do not suffice on their own. The Lean checks, frozen experiment protocols and matched-comparator criterion apply that standard. [Research workflow](../../CONTRIBUTING.md#lean-experiments-for-research-decisions) · [Mission criterion](../decisions/ADR-100.md) · [Controls and baselines](../experiments/baselines.md)

**Research tools and the objective.** The statement allows oscillator models and similar mechanisms as research tools. The torus oscillator reference model and the 16-bit recall benchmark are used in that role. Interesting oscillator mathematics, a wave-based copy of an existing neural-network algorithm, or a database with a different retrieval mechanism would not meet the objective. [Problem statement](problem-statement.md) · [Roadmap](../roadmap.md)

**Parts still unspecified.** The external knowledge path has no contract. The learned memory has pilot decisions for pairwise training and retrieval, while its scalar gain and homeostat dynamics remain open. [Interface inventory](../architecture/interfaces.md) · [Memory dynamics](../mathematics/memory.md) · [Gap register](../research/core-gap-register.md)
