module

public import PWFA.TorusMeanField
public import Mathlib.MeasureTheory.Measure.Lebesgue.VolumeOfBalls

/-!
# Exact area of the disk comparator

A centered half-open square counts each torus point once. The radius bound puts the whole open
Euclidean disk inside that square. Translating the quotient map transports the planar area
formula to every center, including centers across a coordinate seam.

[Specification](../docs/decisions/ADR-111.md) · [Scope and evidence](../docs/verification/slices/torus-oscillator-baseline.md#disk-normalization-review)
-/

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus MeasureTheory MeasureTheory.Measure Set TopologicalSpace
open scoped ENNReal

noncomputable section

private abbrev Coordinates := Fin 2 → ℝ

private def centeredSquare : Set Coordinates :=
  univ.pi fun _ => Ioc (-(1 / 2 : ℝ)) (1 / 2)

/-- The centered unit square, with Lebesgue measure, covers the torus with its chosen area. -/
private theorem measurePreserving_coordinates :
    MeasurePreserving ofCoordinates (volume.restrict centeredSquare) area := by
  have harea : area = (volume : Measure Point) := by
    apply (addHaarMeasure_eq_iff _ _).mpr
    change volume (univ : Set Point) = 1
    simp [volume_pi, Measure.pi_univ]
  rw [harea]
  change MeasurePreserving ofCoordinates
    ((Measure.pi fun _ : Fin 2 => (volume : Measure ℝ)).restrict centeredSquare)
    (Measure.pi fun _ : Fin 2 => (volume : Measure UnitAddCircle))
  rw [centeredSquare, Measure.restrict_pi_pi]
  apply measurePreserving_pi
  intro i
  convert UnitAddCircle.measurePreserving_mk (-(1 / 2 : ℝ)) using 1
  norm_num

private theorem dist_on_centeredSquare (u : Coordinates) (hu : u ∈ centeredSquare) :
    euclideanDist 0 (ofCoordinates u) = ‖WithLp.toLp 2 u‖ := by
  have hcoord (i : Fin 2) : dist (0 : UnitAddCircle) (ofCoordinates u i) = |u i| := by
    rw [dist_comm, dist_zero_right]
    apply (AddCircle.norm_coe_eq_abs_iff (1 : ℝ) one_ne_zero).2
    obtain ⟨hleft, hright⟩ := hu i (mem_univ _)
    simpa only [abs_one] using abs_le.mpr ⟨hleft.le, hright⟩
  simp [euclideanDist, PiLp.norm_eq_of_L2, hcoord, Real.norm_eq_abs]

private theorem disk_preimage_inter_square (radius : Radius) (x : Point) :
    (fun u => x + ofCoordinates u) ⁻¹' {y | euclideanDist x y < (radius : ℝ)} ∩
      centeredSquare = WithLp.toLp 2 ⁻¹' Metric.ball (0 : EuclideanSpace ℝ (Fin 2)) radius := by
  have htranslate (u : Coordinates) : euclideanDist x (x + ofCoordinates u) =
      euclideanDist 0 (ofCoordinates u) := by
    simpa only [zero_add, add_comm (ofCoordinates u) x] using
      euclideanDist_add_right 0 (ofCoordinates u) x
  ext u
  change (euclideanDist x (x + ofCoordinates u) < (radius : ℝ) ∧ u ∈ centeredSquare) ↔ _
  rw [htranslate]
  change _ ↔ dist (WithLp.toLp 2 u) 0 < (radius : ℝ)
  rw [dist_zero_right]
  constructor
  · rintro ⟨hd, hu⟩
    rwa [← dist_on_centeredSquare u hu]
  · intro hd
    have hu : u ∈ centeredSquare := by
      intro i _
      have hcoord : |u i| < 1 / 2 := by
        have hle := PiLp.norm_apply_le (WithLp.toLp 2 u) i
        exact (show |u i| ≤ ‖WithLp.toLp 2 u‖ from hle).trans_lt (hd.trans radius.property.2)
      exact ⟨(abs_lt.mp hcoord).1, (abs_lt.mp hcoord).2.le⟩
    exact ⟨by rwa [dist_on_centeredSquare u hu], hu⟩

/-- An open Euclidean torus disk of admissible radius has planar disk area at every center. -/
theorem area_disk (radius : Radius) (x : Point) :
    area {y | euclideanDist x y < (radius : ℝ)} = ENNReal.ofReal (Real.pi * (radius : ℝ) ^ 2) := by
  -- Translating the covering map keeps Haar area fixed while moving the disk center.
  have hmap := (measurePreserving_add_left area x).comp measurePreserving_coordinates
  have hd := measurableSet_disk radius x
  rw [← hmap.measure_preimage hd.nullMeasurableSet, Measure.restrict_apply (hmap.measurable hd)]
  change volume ((fun u => x + ofCoordinates u) ⁻¹' {y | euclideanDist x y < (radius : ℝ)} ∩
    centeredSquare) = _
  rw [disk_preimage_inter_square radius x,
    (PiLp.volume_preserving_toLp (Fin 2)).measure_preimage measurableSet_ball.nullMeasurableSet,
    EuclideanSpace.volume_ball_fin_two, ENNReal.ofReal_mul Real.pi_pos.le,
    ENNReal.ofReal_pow radius.property.1.le, mul_comm]

/-- The existing constant-density disk kernel integrates to exactly one at every center. -/
theorem integral_diskKernel (radius : Radius) (x : Point) :
    (∫ y, diskKernel radius x y ∂area) = 1 := by
  change (∫ y, {y | euclideanDist x y < (radius : ℝ)}.indicator
    (fun _ => (Real.pi * (radius : ℝ) ^ 2)⁻¹) y ∂area) = 1
  rw [integral_indicator (measurableSet_disk radius x), setIntegral_const, Measure.real, area_disk,
    ENNReal.toReal_ofReal (mul_nonneg Real.pi_pos.le (sq_nonneg _)), smul_eq_mul]
  exact mul_inv_cancel₀ (mul_pos Real.pi_pos (pow_pos radius.property.1 2)).ne'

end

end PWFA.TorusOscillator
