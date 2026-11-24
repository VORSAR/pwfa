module

public import PWFA.Phase
public import PWFA.PhaseInverse
public import PWFA.TorusDistance
public import PWFA.TorusOscillator
public import PWFA.TorusMeanField
public import PWFA.TorusDiskNormalization
public import PWFA.TorusVelocityBound
public import PWFA.TorusLocalFlow
public import PWFA.TorusSmoothNormalization
public import PWFA.TorusSynchronized
public import PWFA.TorusGlobalFlow

/-!
# Public architecture interface

Importing this module exposes the reviewed phase, geometry, coupling, and evolution results
through one entry point. The audit programs import this same interface to check that each
statement is available to downstream code.

[Specification](docs/architecture/components.md) · [Scope and evidence](docs/roadmap.md)
-/
