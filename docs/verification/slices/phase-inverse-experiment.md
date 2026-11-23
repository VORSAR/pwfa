# Experimental phase conjugation and inverse

**Status:** Internally cleared under [ADR-109](../../decisions/ADR-109.md) for the bounded experiment below. Independent Gate 1 is pending.

## Contract

Extend the existing [phase algebra](phase-algebra-experiment.md) with complex conjugation. For each $z$ in the norm-one subtype, `phaseConj z` has underlying complex value $\bar z$. Its norm is one, conjugating twice returns $z$, and multiplying $z$ and `phaseConj z` in either order returns `phaseOne`. These are the remaining algebraic parts of [S1-P07](spatial-phase-foundation.md#2-proposed-theorem-and-test-obligations). The experiment uses the existing `UnitPhase`, `phaseMul`, and `phaseOne` as dependencies.

## Internal review before implementation

The assistant reviewed a separate extension to the original six-theorem contract on 2026-11-23. The reviewer is also the author. The scope and dispositions are recorded in this commit.

| Finding | Disposition |
|---|---|
| PH-INV-01 | Preserve the unit-norm invariant. Complex conjugation preserves norm, and $z\bar z=\lVert z\rVert^2=1$ on the subtype. |
| PH-INV-02 | Prove both identities and involution in the subtype. Apply equality on the underlying complex values and subtype extensionality. |
| PH-INV-03 | Preserve the frozen phase review target. The extension can import the original phase module and expose its own declarations. The original phase definitions and six obligations stay pinned in the independent review packet. |

Experimental authorization covers this algebraic extension. Compilation and the axiom audit are required evidence before any formal proof is reported as checked.
