module

public import PWFA.TorusGlobalFlow
public import Mathlib.Analysis.Convex.Contractible
public import Mathlib.Analysis.SpecialFunctions.Complex.Circle
public import Mathlib.Topology.Covering.FundamentalGroupCircle

/-!
# Winding around the two torus coordinates

The basis loops traverse one spatial coordinate in the positive direction. Their images are
loops in the unit circle, with angles measured in turns. A trajectory can rotate their
common basepoint. Lifting the entire two-parameter family keeps track of that motion and
expresses winding as the integer difference between the two lifted endpoints.
[Phase-law obligations](../docs/decisions/ADR-110.md) ·
[Winding contract](../docs/verification/slices/torus-oscillator-baseline.md#coordinate-winding-preservation)
-/

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus MeasureTheory Set
open scoped unitInterval

noncomputable section

/-- One positive turn along coordinate i of the flat unit torus. -/
def coordinateLoop (i : Fin 2) : Path (0 : Point) 0 where
  toFun t j := if j = i then ((t : ℝ) : UnitAddCircle) else 0
  continuous_toFun := continuous_pi fun j => by
    by_cases hj : j = i <;> simp [hj] <;> fun_prop
  source' := by ext j; simp
  target' := by ext j; simp

/-- A unit complex phase expressed in turns on the additive circle. -/
def phaseAngle (z : ℂ) (hz : ‖z‖ = 1) : UnitAddCircle :=
  (AddCircle.homeomorphCircle (T := (1 : ℝ)) one_ne_zero).symm
    (⟨z, mem_sphere_zero_iff_norm.mpr hz⟩ : Circle)

theorem continuous_phaseAngle {X : Type*} [TopologicalSpace X] {f : X → ℂ}
    (hf : Continuous f) (hu : ∀ x, ‖f x‖ = 1) : Continuous (fun x => phaseAngle (f x) (hu x)) :=
  (AddCircle.homeomorphCircle (T := (1 : ℝ)) one_ne_zero).symm.continuous.comp
    (hf.subtype_mk fun x => mem_sphere_zero_iff_norm.mpr (hu x))

/-- The image of the spatial cycle is based at the physical phase at the origin. -/
def imageLoop (z : Field) (hu : ∀ x, ‖z x‖ = 1) (i : Fin 2) :
    Path (phaseAngle (z 0) (hu 0)) (phaseAngle (z 0) (hu 0)) :=
  (coordinateLoop i).map (continuous_phaseAngle z.continuous hu)

/-- Integer winding of the physical phase along an oriented coordinate loop. -/
def coordinateWinding (z : Field) (hu : ∀ x, ‖z x‖ = 1) (i : Fin 2) : ℤ :=
  AddCircle.windingNumber (.of (.mk (imageLoop z hu i)))

/-- Continuous families of unit fields have constant winding on a real open interval. -/
theorem coordinateWinding_eq_on_interval {a b : ℝ} (z : ℝ → Field)
    (hc : ContinuousOn z (Ioo a b)) (hu : ∀ t ∈ Ioo a b, ∀ x, ‖z t x‖ = 1)
    {s t : ℝ} (hs : s ∈ Ioo a b) (ht : t ∈ Ioo a b) (i : Fin 2) :
    coordinateWinding (z s) (hu s hs) i = coordinateWinding (z t) (hu t ht) i := by
  let J := Ioo a b
  let : ContractibleSpace J := (convex_Ioo a b).contractibleSpace ⟨s, hs⟩
  let : LocallyPathConnectedSpace J := (convex_Ioo a b).locallyPathConnectedSpace
  let : ContractibleSpace I := (convex_Icc (0 : ℝ) 1).contractibleSpace ⟨0, by simp⟩
  let : LocallyPathConnectedSpace I := (convex_Icc (0 : ℝ) 1).locallyPathConnectedSpace
  have htime : Continuous (fun u : J => z u) := continuousOn_iff_continuous_domRestrict.mp hc
  let angles : C(J × I, UnitAddCircle) :=
    ⟨fun u => phaseAngle (z u.1 (coordinateLoop i u.2)) (hu u.1 u.1.2 _),
      continuous_phaseAngle (continuous_eval.comp
        ((htime.comp continuous_fst).prodMk ((coordinateLoop i).continuous.comp continuous_snd))) _⟩
  let start : J × I := (⟨s, hs⟩, 0)
  obtain ⟨lift, ⟨_, hlift⟩, _⟩ := (AddCircle.isCoveringMap_coe (1 : ℝ)).existsUnique_continuousMap_lifts
    angles start (AddCircle.equivIco 1 0 (angles start) : ℝ) AddCircle.coe_equivIco
  let wind (u : J) := coordinateWinding (z u) (hu u u.2) i
  -- A single continuous choice of lift over the whole rectangle avoids choosing angles
  -- separately for each time, which could introduce arbitrary jumps by integer turns.
  have value (u : J) : (wind u : ℝ) = lift (u, 1) - lift (u, 0) := by
    let pathLift : C(I, ℝ) := ⟨fun v => lift (u, v), lift.continuous.comp (continuous_const.prodMk continuous_id)⟩
    have hpath : ((↑) : ℝ → UnitAddCircle) ∘ pathLift = imageLoop (z u) (hu u u.2) i := by
      funext v
      change ((lift (u, v) : ℝ) : UnitAddCircle) = angles (u, v)
      exact congrFun hlift (u, v)
    change (AddCircle.windingNumber (.of (.mk (imageLoop (z u) (hu u u.2) i))) : ℝ) = pathLift 1 - pathLift 0
    exact (AddCircle.windingNumber_eq_div _ pathLift hpath).trans (div_one _)
  have hwind : Continuous wind := by
    apply Real.isClosedEmbedding_intCast.isEmbedding.continuous_iff.mpr
    change Continuous (fun u : J => (wind u : ℝ))
    simp_rw [value]
    fun_prop
  exact (inferInstance : PreconnectedSpace J).constant hwind (x := ⟨s, hs⟩) (y := ⟨t, ht⟩)

theorem local_solution_coordinateWinding (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) {f : ℝ → Field}
    {ε : ℝ} (hε : 0 < ε) (hu : ∀ x, ‖f 0 x‖ = 1)
    (hf : ∀ t ∈ Ioo (-ε) ε, HasDerivAt f (continuousRhs p kernel h hrow (f t)) t)
    {t : ℝ} (ht : t ∈ Ioo (-ε) ε) (i : Fin 2) :
    coordinateWinding (f t) (fun x => (norm_local_solution_eq_initial p h hrow hε hf x ht).trans (hu x)) i =
      coordinateWinding (f 0) hu i :=
  coordinateWinding_eq_on_interval f (fun s hs => (hf s hs).continuousAt.continuousWithinAt)
    (fun s hs x => (norm_local_solution_eq_initial p h hrow hε hf x hs).trans (hu x))
    ht ⟨by linarith, hε⟩ i

theorem global_solution_coordinateWinding (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) {f : ℝ → Field}
    (hu : ∀ x, ‖f 0 x‖ = 1) (hf : ∀ t, HasDerivAt f (continuousRhs p kernel h hrow (f t)) t)
    (t : ℝ) (i : Fin 2) :
    coordinateWinding (f t) (global_solution_unit p h hrow hu hf t) i = coordinateWinding (f 0) hu i :=
  local_solution_coordinateWinding p h hrow (by positivity : 0 < |t| + 1) hu (fun s _ => hf s)
    (abs_lt.mp (lt_add_one _)) i

end

end PWFA.TorusOscillator
