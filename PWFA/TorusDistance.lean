module

public import Mathlib.Analysis.Normed.Group.AddCircle
public import Mathlib.Analysis.Normed.Lp.PiLp

/-!
# Periodic Euclidean geometry

Each coordinate is a circle of period one. The coupling distance combines the shortest
displacements in the two coordinates by Euclidean length. The lattice-minimum theorem proves
representative independence. The diagonal example distinguishes this distance from the product
metric.

[Specification](../docs/decisions/ADR-105.md) · [Scope and evidence](../docs/verification/slices/spatial-metric-remediation.md)
-/

@[expose] public section

namespace PWFA.Torus

noncomputable section

/-- The flat unit torus, with mathlib's product topology. -/
abbrev Point := UnitAddTorus (Fin 2)

/-- The point represented by two real coordinates. -/
def ofCoordinates (coordinates : Fin 2 → ℝ) : Point :=
  fun i => (coordinates i : UnitAddCircle)

theorem ofCoordinates_add_lattice (x : Fin 2 → ℝ) (shift : Fin 2 → ℤ) :
    ofCoordinates (fun i => x i + (shift i : ℝ)) = ofCoordinates x := by
  funext i
  change ((x i + (shift i : ℝ) : ℝ) : UnitAddCircle) = (x i : UnitAddCircle)
  have hzero : ((shift i : ℝ) : UnitAddCircle) = 0 :=
    (AddCircle.coe_eq_zero_iff (1 : ℝ)).2 ⟨shift i, by simp [zsmul_eq_mul]⟩
  rw [AddCircle.coe_add, hzero, add_zero]

/-- Euclidean length of the two circular distances. -/
def euclideanDist (x y : Point) : ℝ :=
  ‖WithLp.toLp 2 (fun i => dist (x i) (y i))‖

theorem euclideanDist_eq_sqrt_sum (x y : Point) :
    euclideanDist x y = Real.sqrt (∑ i : Fin 2, dist (x i) (y i) ^ 2) := by
  simp [euclideanDist, PiLp.norm_eq_of_L2, Real.norm_eq_abs]

theorem continuous_euclideanDist {X : Type*} [TopologicalSpace X] {x y : X → Point}
    (hx : Continuous x) (hy : Continuous y) : Continuous (fun t => euclideanDist (x t) (y t)) := by
  simp only [euclideanDist_eq_sqrt_sum]
  refine Real.continuous_sqrt.comp (continuous_finsetSum _ fun i _ => ?_)
  exact (((continuous_apply i).comp hx).dist ((continuous_apply i).comp hy)).pow 2

theorem euclideanDist_nonneg (x y : Point) : 0 ≤ euclideanDist x y :=
  norm_nonneg _

theorem euclideanDist_eq_zero (x y : Point) : euclideanDist x y = 0 ↔ x = y := by
  constructor
  · intro h
    have hz := norm_eq_zero.mp h
    funext i
    exact dist_eq_zero.mp (congrArg (fun v : PiLp 2 (fun _ : Fin 2 => ℝ) => v i) hz)
  · rintro rfl
    simp [euclideanDist, PiLp.norm_eq_of_L2]

theorem euclideanDist_comm (x y : Point) : euclideanDist x y = euclideanDist y x := by
  simp only [euclideanDist, dist_comm (y _) (x _)]

private theorem norm_toLp_mono {u v : Fin 2 → ℝ}
    (hu : ∀ i, 0 ≤ u i) (huv : ∀ i, u i ≤ v i) :
    ‖WithLp.toLp 2 u‖ ≤ ‖WithLp.toLp 2 v‖ := by
  simpa [PiLp.norm_eq_of_L2, Real.norm_eq_abs, sq_abs] using
    Real.sqrt_le_sqrt
      (Finset.sum_le_sum (s := Finset.univ) fun i _ => pow_le_pow_left₀ (hu i) (huv i) 2)

theorem euclideanDist_triangle (x y z : Point) :
    euclideanDist x z ≤ euclideanDist x y + euclideanDist y z := by
  let u : Fin 2 → ℝ := fun i => dist (x i) (y i)
  let v : Fin 2 → ℝ := fun i => dist (y i) (z i)
  calc
    euclideanDist x z ≤ ‖WithLp.toLp 2 (u + v)‖ :=
      norm_toLp_mono (fun _ => dist_nonneg) (fun i => dist_triangle (x i) (y i) (z i))
    _ ≤ euclideanDist x y + euclideanDist y z := by
      rw [WithLp.toLp_add]
      exact norm_add_le _ _

theorem euclideanDist_add_right (x y z : Point) :
    euclideanDist (x + z) (y + z) = euclideanDist x y := by
  simp [euclideanDist, dist_add_right]

private theorem coordDist_eq (x y : ℝ) :
    dist (x : UnitAddCircle) (y : UnitAddCircle) = |x - y - (round (x - y) : ℝ)| := by
  rw [dist_eq_norm, ← QuotientAddGroup.mk_sub, UnitAddCircle.norm_eq]

/-- Length of one real displacement obtained by shifting representatives by a lattice vector. -/
def latticeLength (x y : Fin 2 → ℝ) (shift : Fin 2 → ℤ) : ℝ :=
  ‖WithLp.toLp 2 (fun i => x i - y i + (shift i : ℝ))‖

theorem euclideanDist_le_latticeLength (x y : Fin 2 → ℝ) (shift : Fin 2 → ℤ) :
    euclideanDist (ofCoordinates x) (ofCoordinates y) ≤ latticeLength x y shift := by
  calc
    euclideanDist (ofCoordinates x) (ofCoordinates y) ≤
        ‖WithLp.toLp 2 (fun i => |x i - y i + (shift i : ℝ)|)‖ :=
      norm_toLp_mono (fun _ => dist_nonneg) (fun i => by
        change dist (x i : UnitAddCircle) (y i : UnitAddCircle) ≤ _
        rw [coordDist_eq]
        simpa only [Int.cast_neg, sub_neg_eq_add] using round_le (x i - y i) (-shift i))
    _ = latticeLength x y shift := by
      simp [latticeLength, PiLp.norm_eq_of_L2, Real.norm_eq_abs]

theorem exists_latticeLength_eq_euclideanDist (x y : Fin 2 → ℝ) :
    ∃ shift : Fin 2 → ℤ, latticeLength x y shift = euclideanDist (ofCoordinates x) (ofCoordinates y) := by
  -- Each coordinate can attain its nearest lattice shift simultaneously on this square torus.
  refine ⟨fun i => -round (x i - y i), ?_⟩
  simp [latticeLength, euclideanDist, ofCoordinates, PiLp.norm_eq_of_L2, Real.norm_eq_abs,
    coordDist_eq, sub_eq_add_neg]

theorem euclideanDist_isLeast_latticeLength (x y : Fin 2 → ℝ) :
    IsLeast (Set.range (latticeLength x y)) (euclideanDist (ofCoordinates x) (ofCoordinates y)) := by
  refine ⟨exists_latticeLength_eq_euclideanDist x y, ?_⟩
  rintro _ ⟨shift, rfl⟩
  exact euclideanDist_le_latticeLength x y shift

private theorem coordDist_le_half (x y : UnitAddCircle) : dist x y ≤ 1 / 2 := by
  rw [dist_eq_norm]
  simpa using AddCircle.norm_le_half_period (1 : ℝ) (x := x - y) one_ne_zero

private theorem norm_half_vector : ‖WithLp.toLp 2 (fun _ : Fin 2 => (1 / 2 : ℝ))‖ =
    Real.sqrt 2 / 2 := by
  rw [PiLp.norm_eq_of_L2, Fin.sum_univ_two]
  norm_num [Real.norm_eq_abs]
  have hr : Real.sqrt 2 ≠ 0 := ne_of_gt (Real.sqrt_pos.2 (by norm_num))
  field_simp [hr]
  nlinarith [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)]

theorem euclideanDist_le_diameter (x y : Point) : euclideanDist x y ≤ Real.sqrt 2 / 2 := by
  calc
    euclideanDist x y ≤ ‖WithLp.toLp 2 (fun _ : Fin 2 => (1 / 2 : ℝ))‖ :=
      norm_toLp_mono (fun _ => dist_nonneg) (fun i => coordDist_le_half (x i) (y i))
    _ = Real.sqrt 2 / 2 := norm_half_vector

private theorem halfCoordDist : dist (0 : UnitAddCircle) ((1 / 2 : ℝ) : UnitAddCircle) = 1 / 2 := by
  rw [dist_comm, dist_zero_right]
  simpa using (AddCircle.norm_half_period_eq (1 : ℝ))

theorem euclideanDist_diagonal :
    euclideanDist 0 (ofCoordinates (fun _ => 1 / 2)) = Real.sqrt 2 / 2 := by
  change ‖WithLp.toLp 2 (fun _ : Fin 2 => dist (0 : UnitAddCircle)
    ((1 / 2 : ℝ) : UnitAddCircle))‖ = _
  rw [halfCoordDist]
  exact norm_half_vector

theorem productDist_diagonal : dist (0 : Point) (ofCoordinates (fun _ => 1 / 2)) = 1 / 2 := by
  let diagonal : Point := ofCoordinates (fun _ => 1 / 2)
  change dist (0 : Point) diagonal = _
  apply le_antisymm
  · exact dist_pi_le_iff'.2 (fun _ => halfCoordDist.le)
  · have h := dist_pi_le_iff'.1 (le_refl (dist (0 : Point) diagonal)) (0 : Fin 2)
    change dist (0 : UnitAddCircle) ((1 / 2 : ℝ) : UnitAddCircle) ≤ _ at h
    rwa [halfCoordDist] at h

end

end PWFA.Torus
