module

import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
meta import Lean.Elab.BuiltinCommand
meta import Lean.Util.CollectAxioms

/-!
# Clean reconstruction of a compact phase stimulus

The [width experiment](../../docs/research/bit-to-phase-map.md#internal-review-of-the-provisional-18-stimulus-width)
uses a uniform unit background and equal-weight bilinear interpolation at a cell midpoint.
The [grid experiment](encoder-grid.lean) checks which bit contributes at each neighboring node.
Here we check the exact peak fractions and what an imperfect reconstructed anchor does to
both bit signs. This is a static point-readout test, before learning or evolution.
-/

namespace EncoderWidthReadout

open scoped ComplexConjugate
noncomputable section

-- Squared length units are 1/320². Peak normalization sets the central gain to one.
private def gain (radiusSquared distanceSquared : ℕ) : ℝ :=
  if distanceSquared < radiusSquared then
    Real.exp (-(distanceSquared : ℝ) / ((radiusSquared : ℝ) - distanceSquared))
  else 0

private theorem stencil_gains :
    gain 1600 500 = Real.exp (-5/11) ∧ gain 1600 1300 = Real.exp (-13/3) ∧
    gain 1600 200 = Real.exp (-1/7) ∧ gain 1600 125 = Real.exp (-5/59) ∧
    gain 1024 500 = Real.exp (-125/131) ∧ gain 1024 200 = Real.exp (-25/103) ∧
    gain 1024 125 = Real.exp (-125/899) ∧ gain 1024 1300 = 0 ∧
    gain 1600 1800 = 0 ∧ gain 1600 2125 = 0 ∧ gain 1024 1800 = 0 ∧
    gain 1024 2125 = 0 ∧ gain 1600 0 = 1 ∧ gain 1024 0 = 1 := by
  norm_num [gain]

-- The bit angle exceeds each anchor-node angle, and their sum stays within the
-- monotone part of sine for both selected phase alphabets.
private theorem coarse_gains_safe :
    0 < Real.exp (-13/3) ∧ Real.exp (-13/3) < Real.exp (-5/11) ∧
    Real.exp (-5/11) + Real.exp (-13/3) ≤ 1 := by
  refine ⟨Real.exp_pos _, Real.exp_lt_exp.mpr (by norm_num), ?_⟩
  have bound (x : ℝ) (hx : 0 ≤ x) : Real.exp (-x) ≤ 1/(1+x) := by
    rw [Real.exp_neg, inv_eq_one_div]
    exact one_div_le_one_div_of_le (by linarith) (by linarith [Real.add_one_le_exp x])
  have hb := bound (5/11) (by norm_num)
  have ha := bound (13/3) (by norm_num)
  norm_num at hb ha
  linarith

private def phase (angle : ℝ) : ℂ := ⟨Real.cos angle, Real.sin angle⟩
private def anchor (angles : Fin 4 → ℝ) : ℂ := (∑ i, phase (angles i)) / 4

-- At a bit center the four shifted samples all have the same phase, so taking
-- their complex mean recovers that phase, with its attenuated angular offset.
private theorem identical_midpoint (b : ℝ) : anchor (fun _ => b) = phase b := by
  simp [anchor, nsmul_eq_mul]

private theorem phase_norm (angle : ℝ) : ‖phase angle‖ = 1 := by
  rw [show phase angle = Complex.exp ((angle : ℂ) * Complex.I) by
    apply Complex.ext
    · exact (Complex.exp_ofReal_mul_I_re angle).symm
    · exact (Complex.exp_ofReal_mul_I_im angle).symm]
  exact Complex.norm_exp_ofReal_mul_I _

private theorem anchor_norm_le (angles : Fin 4 → ℝ) : ‖anchor angles‖ ≤ 1 := by
  simp only [anchor, norm_div, Complex.norm_ofNat]
  have h := norm_sum_le (s := Finset.univ) (f := fun i => phase (angles i))
  simp [phase_norm] at h
  linarith

private theorem raw_score (angles : Fin 4 → ℝ) (bit : ℝ) :
    (conj (anchor angles) * phase bit).im = (∑ i, Real.sin (bit - angles i)) / 4 := by
  simp only [anchor, map_div₀, map_ofNat, map_sum, div_mul_eq_mul_div,
    Finset.sum_mul, Complex.div_ofNat_im, Complex.im_sum, Complex.mul_im,
    Complex.conj_re, Complex.conj_im, phase, Real.sin_sub]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  ring

private def anchoredScore (angles : Fin 4 → ℝ) (bit : ℝ) : ℝ :=
  (conj (anchor angles / (‖anchor angles‖ : ℂ)) * phase bit).im

private theorem normalized_score (angles : Fin 4 → ℝ) (bit : ℝ) :
    anchoredScore angles bit = ((∑ i, Real.sin (bit - angles i)) / 4) / ‖anchor angles‖ := by
  rw [anchoredScore, map_div₀, Complex.conj_ofReal, div_mul_eq_mul_div, Complex.div_ofReal_im,
    raw_score]

-- All four surrounding anchor angles may vary independently, including omissions
-- (zero angle). A positive point score also proves that the mean anchor is nonzero.
private theorem clean_bounds (angles : Fin 4 → ℝ) {b l : ℝ} (hl : 0 ≤ l)
    (hb : l < b) (ht : b+l ≤ Real.pi/2) (h : ∀ i, |angles i| ≤ l) :
    0 < ‖anchor angles‖ ∧ Real.sin (b-l) ≤ anchoredScore angles b ∧
      anchoredScore angles (-b) ≤ -Real.sin (b-l) := by
  have hs : 0 < Real.sin (b-l) :=
    Real.sin_pos_of_pos_of_lt_pi (by linarith) (by linarith [Real.pi_pos])
  have sums (x : Fin 4 → ℝ) (hx : ∀ i, |x i| ≤ l) :
      Real.sin (b-l) ≤ (∑ i, Real.sin (b-x i)) / 4 := by
    have hi (i : Fin 4) : Real.sin (b-l) ≤ Real.sin (b-x i) := by
      obtain ⟨hlo, hhi⟩ := abs_le.mp (hx i)
      exact Real.monotoneOn_sin ⟨by linarith [Real.pi_pos], by linarith⟩
        ⟨by linarith [Real.pi_pos], by linarith⟩ (by linarith)
    have hh := Finset.sum_le_sum (s := Finset.univ) (fun i _ => hi i)
    simp at hh
    linarith
  have hp := sums angles h
  have hn := sums (fun i => -angles i) (fun i => by simpa using h i)
  have hn' : (∑ i, Real.sin (-b - angles i)) / 4 ≤ -Real.sin (b-l) := by
    simp_rw [show ∀ i, -b - angles i = -(b - -angles i) by intro i; ring, Real.sin_neg]
    rw [Finset.sum_neg_distrib]
    linarith
  have hpos : 0 < ‖anchor angles‖ := by
    apply norm_pos_iff.mpr
    intro he
    rw [← raw_score, he] at hp
    simp at hp
    linarith
  have hmul := mul_le_mul_of_nonneg_left (anchor_norm_le angles) hs.le
  refine ⟨hpos, ?_, ?_⟩
  · rw [normalized_score, le_div_iff₀ hpos]
    linarith
  · rw [normalized_score, div_le_iff₀ hpos]
    linarith

-- Unanimous same-sign corner bits attain the lower bound. An omitted interior
-- bit then reads with a small false signed signal on the coarse shifted grid.
private theorem unanimous (l b : ℝ) :
    anchoredScore (fun _ => l) b = Real.sin (b-l) := by
  rw [normalized_score]
  simp [anchor, phase_norm, nsmul_eq_mul]

-- When no stimulus reaches the anchor nodes, every interior positive gain up to
-- one preserves both signs. This includes the finer grids and the narrower radius.
private theorem clean_no_leak {θ g : ℝ} (hθ : 0 < θ) (ht : θ ≤ Real.pi/2)
    (hg : 0 < g) (hg1 : g ≤ 1) :
    0 < anchoredScore (fun _ => 0) (θ*g) ∧ anchoredScore (fun _ => 0) (-(θ*g)) < 0 := by
  simp only [unanimous, sub_zero, Real.sin_neg, neg_lt_zero, and_self]
  exact Real.sin_pos_of_pos_of_lt_pi (mul_pos hθ hg)
    (by linarith [mul_le_of_le_one_right hθ.le hg1, Real.pi_pos])

-- Instantiate the sign bounds at radius 1/8 on the 16×8 shifted grid.
private theorem coarse_present (angles : Fin 4 → ℝ) {θ : ℝ} (hp : 0 < θ)
    (hθ : θ ≤ Real.pi/2) (h : ∀ i, |angles i| ≤ θ * Real.exp (-13/3)) :
    let b := θ * Real.exp (-5/11)
    let l := θ * Real.exp (-13/3)
    0 < ‖anchor angles‖ ∧ Real.sin (b-l) ≤ anchoredScore angles b ∧
      anchoredScore angles (-b) ≤ -Real.sin (b-l) := by
  obtain ⟨ha, hab, hsum⟩ := coarse_gains_safe
  apply clean_bounds angles (mul_nonneg hp.le ha.le) (mul_lt_mul_of_pos_left hab hp) _ h
  rw [← mul_add]
  exact (mul_le_of_le_one_right hp.le hsum).trans hθ

private theorem coarse_masked (θ : ℝ) (hθ : 0 < θ) (ht : θ ≤ Real.pi/2) :
    anchoredScore (fun _ => θ * Real.exp (-13/3)) 0 < 0 := by
  rw [unanimous, zero_sub, Real.sin_neg, neg_lt_zero]
  obtain ⟨ha, hab, hsum⟩ := coarse_gains_safe
  apply Real.sin_pos_of_pos_of_lt_pi (mul_pos hθ ha)
  have ha1 : Real.exp (-13/3) ≤ 1 := by linarith
  linarith [mul_le_of_le_one_right hθ.le ha1, Real.pi_pos]

-- Apply the same dependency check as the companion point-readout experiment.
run_cmd do
  let allowed := #[`propext, `Classical.choice, `Quot.sound]
  for name in #[``stencil_gains, ``identical_midpoint, ``clean_bounds, ``unanimous,
      ``clean_no_leak, ``coarse_present, ``coarse_masked] do
    let deps ← Lean.collectAxioms name
    unless deps.all (fun dep => allowed.contains dep) do
      throwError "{name} has unexpected dependencies: {deps}"

end
end EncoderWidthReadout
