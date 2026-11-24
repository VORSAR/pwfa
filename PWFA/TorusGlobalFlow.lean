module

public import PWFA.TorusLocalFlow

@[expose] public section

namespace PWFA.TorusOscillator

open PWFA.Torus MeasureTheory Set Filter
open scoped Topology NNReal

noncomputable section

private def UnitSolutionAt (rhs : Field → Field) (f : ℝ → Field) (t : ℝ) : Prop :=
  HasDerivAt f (rhs (f t)) t ∧ ∀ x, ‖f t x‖ = 1

private theorem unit_norm_le_one {z : Field} (hz : ∀ x, ‖z x‖ = 1) : ‖z‖ ≤ 1 :=
  (ContinuousMap.norm_le_of_nonempty _).2 fun x => (hz x).le

private theorem UnitSolutionAt.congr {rhs : Field → Field} {f g : ℝ → Field} {t : ℝ}
    (hf : UnitSolutionAt rhs f t) (heq : g =ᶠ[𝓝 t] f) : UnitSolutionAt rhs g t := by
  unfold UnitSolutionAt at *
  rw [heq.self_of_nhds]
  exact ⟨hf.1.congr_of_eventuallyEq heq, hf.2⟩

private theorem agree_on_overlap {rhs : Field → Field} {K : ℝ≥0}
    (hK : LipschitzOnWith K rhs (Metric.closedBall 0 1))
    {a b c d s : ℝ} {f g : ℝ → Field}
    (hf : ∀ t ∈ Ioo a b, UnitSolutionAt rhs f t)
    (hg : ∀ t ∈ Ioo c d, UnitSolutionAt rhs g t)
    (hs : s ∈ Ioo a b ∩ Ioo c d) (heq : f s = g s) :
    EqOn f g (Ioo a b ∩ Ioo c d) := by
  rw [Ioo_inter_Ioo] at hs ⊢
  apply ODE_solution_unique_of_mem_Ioo (v := fun _ => rhs)
    (s := fun _ => Metric.closedBall 0 1) (fun _ _ => hK) hs _ _ heq
  · intro t ht
    rw [← Ioo_inter_Ioo] at ht
    exact ⟨(hf t ht.1).1, by simpa using unit_norm_le_one (hf t ht.1).2⟩
  · intro t ht
    rw [← Ioo_inter_Ioo] at ht
    exact ⟨(hg t ht.2).1, by simpa using unit_norm_le_one (hg t ht.2).2⟩

/-- Uniform restarts extend the reachable interval across every finite time. -/
private theorem global_of_uniform_restart (rhs : Field → Field) {K : ℝ≥0}
    (hK : LipschitzOnWith K rhs (Metric.closedBall 0 1)) {ε : ℝ} (hε : 0 < ε)
    (restart : ∀ s (z : Field), (∀ x, ‖z x‖ = 1) → ∃ g : ℝ → Field,
      g s = z ∧ ∀ t ∈ Ioo (s - ε) (s + ε), UnitSolutionAt rhs g t)
    (initial : Field) (hunit : ∀ x, ‖initial x‖ = 1) :
    ∃ f : ℝ → Field, f 0 = initial ∧ ∀ t, UnitSolutionAt rhs f t := by
  classical
  let S : Set ℝ := {t | ∃ (a b : ℝ) (f : ℝ → Field), (0 : ℝ) ∈ Ioo a b ∧ t ∈ Ioo a b ∧
    f 0 = initial ∧ ∀ u ∈ Ioo a b, UnitSolutionAt rhs f u}
  have h0 : (0 : ℝ) ∈ S := by
    obtain ⟨f, hf, hsol⟩ := restart 0 initial hunit
    have ht : (0 : ℝ) ∈ Ioo (0 - ε) (0 + ε) := ⟨by linarith, by linarith⟩
    exact ⟨_, _, f, ht, ht, hf, hsol⟩
  have step {s t : ℝ} (hs : s ∈ S) (hst : dist t s < ε) : t ∈ S := by
    obtain ⟨a, b, f, hzero, hsab, finit, hf⟩ := hs
    let A := Ioo a b
    let B := Ioo (s - ε) (s + ε)
    have hsB : s ∈ B := ⟨by linarith, by linarith⟩
    have htB : t ∈ B := by
      rw [Real.dist_eq, abs_lt] at hst
      exact ⟨by linarith [hst.1], by linarith [hst.2]⟩
    obtain ⟨g, hginit, hg⟩ := restart s (f s) (hf s hsab).2
    have agree : EqOn f g (A ∩ B) := agree_on_overlap hK hf hg ⟨hsab, hsB⟩ hginit.symm
    let joined := A.piecewise f g
    have leftEq : EqOn joined f A := piecewise_eqOn _ _ _
    have rightEq : EqOn joined g B := by
      intro u hu
      by_cases ha : u ∈ A
      · exact (leftEq ha).trans (agree ⟨ha, hu⟩)
      · exact piecewise_eq_of_notMem A f g ha
    have hunion : A ∪ B = Ioo (min a (s - ε)) (max b (s + ε)) :=
      Ioo_union_Ioo' (lt_trans hsB.1 hsab.2) (lt_trans hsab.1 hsB.2)
    refine ⟨_, _, joined, hunion ▸ (show (0 : ℝ) ∈ A ∪ B from Or.inl hzero),
      hunion ▸ (show t ∈ A ∪ B from Or.inr htB),
      (leftEq hzero).trans finit, ?_⟩
    intro u hu
    rw [← hunion] at hu
    rcases hu with ha | hb
    · exact (hf u ha).congr (Filter.mem_of_superset (Ioo_mem_nhds ha.1 ha.2) leftEq)
    · exact (hg u hb).congr (Filter.mem_of_superset (Ioo_mem_nhds hb.1 hb.2) rightEq)
  have hopen : IsOpen S := Metric.isOpen_iff.mpr fun s hs =>
    ⟨ε, hε, fun _ ht => step hs ht⟩
  have hclosed : IsClosed S := isOpen_compl_iff.mp <| Metric.isOpen_iff.mpr fun s hs =>
    ⟨ε, hε, fun t ht hmem => hs (step hmem (dist_comm s t ▸ ht))⟩
  have hall := (show IsClopen S from ⟨hclosed, hopen⟩).eq_univ ⟨0, h0⟩
  have reach (t : ℝ) : t ∈ S := hall ▸ mem_univ t
  choose a b f hz ht hi hf using reach
  let trajectory := fun t => f t t
  refine ⟨trajectory, hi 0, fun t => (hf t t (ht t)).congr ?_⟩
  filter_upwards [Ioo_mem_nhds (ht t).1 (ht t).2] with u hu
  exact agree_on_overlap hK (hf u) (hf t) ⟨hz u, hz t⟩ ((hi u).trans (hi t).symm) ⟨ht u, hu⟩

/-- Any global solution from unit data stays in the unit circle at every point. -/
theorem global_solution_unit (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area) {f : ℝ → Field}
    (hunit : ∀ x, ‖f 0 x‖ = 1)
    (hf : ∀ t, HasDerivAt f (continuousRhs p kernel h hrow (f t)) t) (t : ℝ) (x : Point) :
    ‖f t x‖ = 1 := by
  have ht : t ∈ Ioo (-(|t| + 1)) (|t| + 1) := abs_lt.mp (lt_add_one _)
  rw [norm_local_solution_eq_initial p h hrow (by positivity : 0 < |t| + 1)
    (fun u _ => hf u) x ht, hunit]

/-- Existence and uniqueness of the ambient field solution for unit initial data, for all time. -/
theorem existsUnique_global_phase_solution (p : Parameters) {kernel : Point → Point → ℝ}
    (h : TranslationInvariant kernel) (hrow : Integrable (kernel 0) area)
    (initial : Field) (hunit : ∀ x, ‖initial x‖ = 1) :
    ∃! f : ℝ → Field, f 0 = initial ∧
      ∀ t, HasDerivAt f (continuousRhs p kernel h hrow (f t)) t := by
  let rhs := continuousRhs p kernel h hrow
  obtain ⟨K, hK⟩ := lipschitzOnWith_continuousRhs p h hrow 1
  obtain ⟨ε, hε, H⟩ := exists_uniform_local_solution p h hrow 1
  have restart (s : ℝ) (z : Field) (hz : ∀ x, ‖z x‖ = 1) :
      ∃ g : ℝ → Field, g s = z ∧ ∀ t ∈ Ioo (s - ε) (s + ε), UnitSolutionAt rhs g t := by
    obtain ⟨f, hi, hf⟩ := H z (unit_norm_le_one hz)
    refine ⟨fun t => f (t - s), by simpa using hi, fun t ht => ?_⟩
    have ht' : t - s ∈ Ioo (-ε) ε := ⟨by linarith [ht.1], by linarith [ht.2]⟩
    have deriv := (hf (t - s) ht').scomp t ((hasDerivAt_id t).sub_const s)
    refine ⟨?_, fun x => ?_⟩
    · change HasDerivAt (f ∘ (· - s)) (continuousRhs p kernel h hrow (f (t - s))) t
      simpa using deriv
    · rw [norm_local_solution_eq_initial p h hrow hε hf x ht', hi, hz x]
  obtain ⟨f, hi, hf⟩ := global_of_uniform_restart rhs hK hε restart initial hunit
  refine ⟨f, ⟨hi, fun t => (hf t).1⟩, ?_⟩
  rintro g ⟨hgi, hg⟩
  apply ODE_solution_unique_univ (v := fun _ => rhs) (s := fun _ => Metric.closedBall 0 1)
    (fun _ => hK) _ _ (hgi.trans hi.symm)
  · intro t
    have hnorm := global_solution_unit p h hrow (hgi ▸ hunit) hg t
    exact ⟨hg t, by simpa using unit_norm_le_one hnorm⟩
  · exact fun t => ⟨(hf t).1, by simpa using unit_norm_le_one (hf t).2⟩

end

end PWFA.TorusOscillator
