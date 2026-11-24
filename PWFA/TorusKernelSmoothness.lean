module

public import PWFA.TorusMeanField

/-!
# Smoothness of the periodic finite-range kernel

[ADR-111](../docs/decisions/ADR-111.md) uses a smooth profile of squared shortest distance.
The [kernel contract](../docs/verification/slices/torus-oscillator-baseline.md#smooth-primary-kernel)
requires smoothness in both locations, including across a change of representatives.
We work with the periodic lift to two pairs of real coordinates. These are the local coordinates
of the flat quotient. At a tie for nearest representative the kernel is locally zero.
-/

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus Set Filter
open scoped Topology ContDiff

noncomputable section

private abbrev Coordinates := Fin 2 → ℝ
private abbrev Locations := Coordinates × Coordinates

/-- Evaluate the actual torus kernel in arbitrary lifts of the two locations. -/
def liftedSmoothKernel (r : Radius) (p : (Fin 2 → ℝ) × (Fin 2 → ℝ)) : ℝ :=
  smoothKernel r (ofCoordinates p.1) (ofCoordinates p.2)

/-- Each location may change its lift by an independent lattice vector. -/
theorem liftedSmoothKernel_periodic (r : Radius) (x y : Fin 2 → ℝ) (a b : Fin 2 → ℤ) :
    liftedSmoothKernel r (fun i => x i + (a i : ℝ), fun i => y i + (b i : ℝ)) =
      liftedSmoothKernel r (x, y) := by
  simp only [liftedSmoothKernel, ofCoordinates_add_lattice]

private def separation (p : Locations) : ℝ := euclideanDist (ofCoordinates p.1) (ofCoordinates p.2)

private theorem continuous_separation : Continuous separation := by
  have hc : Continuous ofCoordinates :=
    continuous_pi fun i => (AddCircle.continuous_mk' 1).comp (continuous_apply i)
  exact continuous_euclideanDist (hc.comp continuous_fst) (hc.comp continuous_snd)

private def polynomial (shift : Fin 2 → ℤ) (p : Locations) : ℝ :=
  ∑ i, (p.1 i - p.2 i + (shift i : ℝ)) ^ 2

private theorem smooth_polynomial (shift : Fin 2 → ℤ) : ContDiff ℝ ∞ (polynomial shift) := by
  unfold polynomial
  fun_prop

private theorem local_square (p : Locations) (h : separation p < 1 / 2) :
    ∃ shift, (fun u => separation u ^ 2) =ᶠ[𝓝 p] polynomial shift := by
  obtain ⟨shift, hs⟩ := exists_latticeLength_eq_euclideanDist p.1 p.2
  refine ⟨shift, ?_⟩
  -- Strict coordinate bounds keep the same lattice shift valid on a whole neighborhood.
  have near (i : Fin 2) : ∀ᶠ u : Locations in 𝓝 p, |u.1 i - u.2 i + (shift i : ℝ)| < 1 / 2 := by
    apply (show Continuous (fun u : Locations => |u.1 i - u.2 i + (shift i : ℝ)|) by fun_prop).continuousAt.eventually_lt continuousAt_const
    have hb := PiLp.norm_apply_le (WithLp.toLp 2 (fun j => p.1 j - p.2 j + (shift j : ℝ))) i
    exact (show |p.1 i - p.2 i + (shift i : ℝ)| ≤ latticeLength p.1 p.2 shift from hb).trans_lt
      (hs ▸ h)
  filter_upwards [eventually_all.2 near] with u hu
  have hc (i : Fin 2) : dist (ofCoordinates u.1 i) (ofCoordinates u.2 i) =
      |u.1 i - u.2 i + (shift i : ℝ)| := by
    rw [← ofCoordinates_add_lattice u.1 shift]
    change dist ((u.1 i + (shift i : ℝ) : ℝ) : UnitAddCircle) (u.2 i : UnitAddCircle) = _
    rw [dist_eq_norm, ← QuotientAddGroup.mk_sub, add_sub_right_comm]
    exact (AddCircle.norm_coe_eq_abs_iff 1 one_ne_zero).2 (by simpa using (hu i).le)
  simp only [separation, euclideanDist_eq_sqrt_sum, hc, sq_abs, polynomial]
  exact Real.sq_sqrt (Finset.sum_nonneg fun _ _ => sq_nonneg _)

/-- At every point strictly outside the support the kernel is zero in a neighborhood. -/
theorem liftedSmoothKernel_zero_near (r : Radius) (p : (Fin 2 → ℝ) × (Fin 2 → ℝ))
    (h : (r : ℝ) < euclideanDist (ofCoordinates p.1) (ofCoordinates p.2)) :
    liftedSmoothKernel r =ᶠ[𝓝 p] (fun _ => 0) := by
  filter_upwards [continuousAt_const.eventually_lt continuous_separation.continuousAt h] with u hu
  exact smoothKernel_zero_of_le_dist r hu.le

/-- A half-period tie in either coordinate has a whole neighborhood of zero coupling. -/
theorem liftedSmoothKernel_zero_near_tie (r : Radius) (p : (Fin 2 → ℝ) × (Fin 2 → ℝ)) (i : Fin 2)
    (h : dist (ofCoordinates p.1 i) (ofCoordinates p.2 i) = 1 / 2) :
    liftedSmoothKernel r =ᶠ[𝓝 p] (fun _ => 0) := by
  apply liftedSmoothKernel_zero_near
  have hb := PiLp.norm_apply_le (WithLp.toLp 2 (fun j => dist (ofCoordinates p.1 j)
    (ofCoordinates p.2 j))) i
  have hle : dist (ofCoordinates p.1 i) (ofCoordinates p.2 i) ≤ separation p := by
    simpa [Real.norm_eq_abs, abs_of_nonneg dist_nonneg, separation, euclideanDist] using hb
  exact r.property.2.trans_le (h ▸ hle)

private def profile (r : Radius) (s : ℝ) : ℝ :=
  smoothBump (s / (r : ℝ) ^ 2) / (Real.pi * (r : ℝ) ^ 2 * ∫ t in (0 : ℝ)..1, smoothBump t)

private theorem smooth_profile (r : Radius) : ContDiff ℝ ∞ (profile r) := by
  exact (expNegInvGlue.contDiff.comp (contDiff_const.sub (contDiff_id.div_const _))).div_const _

/-- The periodic lift is jointly smooth in the four coordinates, including coincident points. -/
theorem contDiff_liftedSmoothKernel (r : Radius) : ContDiff ℝ ∞ (liftedSmoothKernel r) := by
  rw [contDiff_iff_contDiffAt]
  intro p
  by_cases h : separation p < 1 / 2
  · obtain ⟨s, hs⟩ := local_square p h
    exact ((smooth_profile r).comp (smooth_polynomial s)).contDiffAt.congr_of_eventuallyEq
      (hs.fun_comp (profile r))
  · exact contDiffAt_const.congr_of_eventuallyEq
      (liftedSmoothKernel_zero_near r p (r.property.2.trans_le (le_of_not_gt h)))

private theorem profile_flat (r : Radius) :
    ftaylorSeries ℝ (profile r) ((r : ℝ) ^ 2) =
      ftaylorSeries ℝ (fun _ : ℝ => (0 : ℝ)) ((r : ℝ) ^ 2) := by
  -- On the closed outer half-line the profile equals zero. Smoothness identifies its
  -- one-sided derivatives there with its full derivatives at the endpoint.
  have hz : EqOn (profile r) (fun _ => 0) (Ici ((r : ℝ) ^ 2)) := by
    intro s hs
    have hratio := (one_le_div (pow_pos r.property.1 2)).2 hs
    simp [profile, smoothBump, expNegInvGlue.zero_of_nonpos (sub_nonpos.mpr hratio)]
  funext n
  change iteratedFDeriv ℝ n _ _ = iteratedFDeriv ℝ n _ _
  have hx : (r : ℝ) ^ 2 ∈ Ici ((r : ℝ) ^ 2) := le_rfl
  rw [← iteratedFDerivWithin_eq_iteratedFDeriv (uniqueDiffOn_Ici _)
    ((smooth_profile r).of_le (mod_cast le_top)).contDiffAt hx,
    ← iteratedFDerivWithin_eq_iteratedFDeriv (uniqueDiffOn_Ici _) contDiffAt_const hx]
  exact iteratedFDerivWithin_congr hz hx n

/-- Every joint derivative, of any order and in arbitrary directions, vanishes at the edge. -/
theorem liftedSmoothKernel_flat_at_edge (r : Radius) (p : (Fin 2 → ℝ) × (Fin 2 → ℝ))
    (hp : euclideanDist (ofCoordinates p.1) (ofCoordinates p.2) = (r : ℝ)) (n : ℕ) :
    iteratedFDeriv ℝ n (liftedSmoothKernel r) p = 0 := by
  obtain ⟨s, hs⟩ := local_square p (hp.trans_lt r.property.2)
  have hv : polynomial s p = (r : ℝ) ^ 2 := hs.self_of_nhds.symm.trans (congrArg (· ^ 2) hp)
  have he : liftedSmoothKernel r =ᶠ[𝓝 p] (profile r ∘ polynomial s) := hs.fun_comp (profile r)
  rw [(he.iteratedFDeriv ℝ n).self_of_nhds]
  have hg := (smooth_polynomial s).contDiffAt (x := p)
  have hn : (n : WithTop ℕ∞) ≤ ∞ := by exact_mod_cast (show (n : ℕ∞) ≤ ⊤ from le_top)
  -- The higher chain rule uses the entire Taylor series. Replacing the outer series by
  -- the zero function's series therefore handles all mixed derivatives at once.
  rw [iteratedFDeriv_comp (smooth_profile r).contDiffAt hg hn, hv, profile_flat, ← hv,
    ← iteratedFDeriv_comp (g := fun _ : ℝ => (0 : ℝ)) contDiffAt_const hg hn]
  exact congrFun iteratedFDeriv_fun_zero p

end

end PWFA.TorusOscillator
