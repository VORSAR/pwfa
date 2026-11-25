# Checks for the first trained recall pilot

## Bounded internal review

At revision `dc039d470d92664523fd8a64b157227c82b3cc99`, Codex (GPT-6), the author acting in the internal reviewer role, reviewed two proposed experiments under ADR-109. The first tests scoring of already decoded words. The second tests what information a proposed pairwise training statistic can retain at the two approved phase alphabets. Both use artificial examples. [Pilot endpoint](../experiments/benchmarks.md#first-trained-recall-measurement) · [Memory contract](../mathematics/memory.md) · [Research process](../decisions/ADR-117.md)

| Finding | Severity | Remedy specified before experimental Lean |
|---|---|---|
| SC-01 | High | Index the target and decoded word by the same sixteen positions. Require all positions to match the original target for an exact hit. Represent an abstaining bit and a failed run explicitly. Check a cue with a flipped bit and an omitted bit, copying, exact recovery, a wrong masked bit and a tie. |
| SC-02 | High | Test the effect of excluding failures or abstentions from the denominator on identical synthetic outcomes. Keep the owner’s choice of scoring policy open. Report counts even when no trials ran. Predictions come from the model; the target and corruption labels enter scoring only. |
| PM-01 | High | Treat signed real phase alignment and its square as candidate statistics. Verify symmetry, common-rotation invariance on unit phases, and the exact same/opposite symbol values at both alphabets. Check the ambiguity under simultaneous reversal of an entire word of primary symbols. |
| PM-02 | High | Keep the dense pairwise statistic separate from the recovered global scalar gain. State what a pair contributes before temporal averaging. Include a configuration where magnitude discards a distinction. Training updates, interaction with other sites and the origin, storage capacity, and recall accuracy require separate evidence. |

The remedies freeze and internally clear these two experiments only. The model has no trained output in this revision. Gate 1 remains open. [Review policy](../verification/review-gates.md)

## Counting exact words

At the frozen review revision `0e42e37`, SC-01 and SC-02 were checked against the [Lean scoring experiment](../../scripts/experiments/recall-scoring.lean). Its exact-word predicate on a decoded word is equivalent to every one of its sixteen positions being resolved and equal to its original target. A synthetic cue with one flip and one mask illustrates this test. Copying the cue gets 14 of 14 unchanged bits right, zero of one flipped bit corrected, and zero of one masked bit recovered. Correcting only the flip or only the mask can still leave a wrong word. The one-of-each fixture tests the scorer independently of the benchmark’s pending 10% rounding rule.

| Artificial outcomes | Exact words | Denominator | Fraction |
|---|---:|---:|---:|
| One exact, one wrong, one abstention, one failed run | 1 | 4 scheduled cues | 1/4 |
| Same records, conditional on a complete prediction | 1 | 2 complete predictions | 1/2 |

The scorer keeps numerator and denominator counts. An empty denominator gives an undefined rate. Recording both rates with coverage (complete predictions divided by scheduled cues) exposes the change of denominator. It also keeps failures visible. The strict all-cue rate is the recommendation for the primary endpoint. Classifying an outcome with both a wrong bit and a tie as abstained is an experiment convention. The owner subsequently selected the all-cue primary rate and both companion metrics. The phase threshold remains open. [Denominator decision](../decisions/ADR-122.md) None of the artificial outcomes are measured PWFA predictions.

## Pairwise input to the learning rule

The [pairwise Lean experiment](../../scripts/experiments/pairwise-phase-statistic.lean) checks PM-01 and PM-02 against review revision `0e42e37`. For unit phases $u=e^{ia}, v=e^{ib}$, signed alignment $C(u,v)=\operatorname{Re}(\bar u v)=\cos(a-b)$ is symmetric and invariant under a common rotation. The following values are exact for a pair of ideal bit-center observations.

| Pair of presented symbols | Signed, ±90° | Squared, ±90° | Signed, ±45° | Squared, ±45° |
|---|---:|---:|---:|---:|
| Equal bits | 1 | 1 | 1 | 1 |
| Opposite bits | −1 | 1 | 0 | 0 |

Reversing every angle preserves every signed pair reading because cosine is even. Consequently a word and its complement give identical matrices of these readings at the ideal bit centers. This also holds for a reflected prepared phase field wherever the angle profile changes sign relative to its uniform background. A partial cue and the signed imaginary decoder can still distinguish orientations in a dynamical run. Use complement pairs when testing trained recall.

As a related model, Aoki and Aoyagi give a phase-difference-dependent weight update in Eq. (3). Its phase offset can give a signed cosine drive. This is precedent for a candidate training signal. PWFA must still specify its own trace and learning time scales, training boundaries, and how the learned weights enter evolution. [Aoki and Aoyagi, Physical Review Letters (2009)](https://doi.org/10.1103/PhysRevLett.102.034101)

The owner selected signed alignment as the first candidate and requested a recall check for complementary words with the cue and origin present. [Training-input decision](../decisions/ADR-123.md)

## Internal review of episode accumulation and recall scoring inputs

At `7da3011`, Codex (GPT-6), the author in the internal reviewer role, reviewed two bounded next steps under ADR-109. Each pair has a signed observation summary for each presentation. The continuous dynamics producing those summaries remain unspecified. A separate scoring utility may consume predictions from a future simulator.

| Finding | Severity | Remedy specified before implementation |
|---|---|---|
| EP-01 | High | Check the running arithmetic mean at an empty start and over all four training episodes. Compare a fixed-retention update on the same bounded summaries. Verify the unit interval in signed coordinates $[-1,1]$ is invariant. Check the effect of reversing conflicting inputs. Claims about order apply only to fixed summaries. |
| EP-02 | High | Keep the within-episode trace, phase forcing, and the recovered scalar gain separate. Demonstrate the trade-off with a concrete four-episode sequence and its reverse. Avoid predictions of recall accuracy from this algebra. |
| RS-01 | High | Read the planned cue IDs and targets separately from model outputs. Score one condition and library at a time. Reject duplicate IDs in either file and unknown output IDs. A missing scheduled output and an explicit failed retrieval must both remain in the denominator. |
| RS-02 | High | Inspect the declared readout time, require exactly sixteen binary target symbols, allow an explicit abstention symbol in outputs, and distinguish invalid input from a declared failed run. Use integer counts for every fraction; a zero denominator has undefined accuracy. Exercise the command on synthetic complete, wrong, missing, tied, malformed and duplicate records. |

These remedies authorize only the episode-summary algebra and offline scoring of already-decoded endpoint records. A trusted simulator is responsible for the timestamps and outputs it supplies. The scorer cannot establish how a prediction was obtained or whether training took place. Independent Gate 1 remains open.

### Scoring command check

The [Lean scoring command](../../scripts/experiments/recall-scoring.lean) implements ADR-122 using a separately supplied cue schedule. The RS-01/02 post-implementation check used the command on five synthetic cues in a different order from the schedule. There was one exact word, one wrong word, one abstention, one declared failure, and one missing prediction. It reported primary accuracy 1/5, coverage 2/5, and answered-only accuracy 1/2. Duplicate and unknown IDs, a wrong readout time, and invalid words were rejected. Compilation also checks the empty schedule and zero denominator. These counts are a test fixture. [Input format and command](../experiments/benchmarks.md#score-a-recall-export)

### Weights across training episodes

The [episode accumulation experiment](../../scripts/experiments/episode-accumulation.lean) checks EP-01/02 at review revision `0e418f5`. Lean verified that the running mean equals the first sample at initialization and gives each of four observations weight one quarter. If the old mean and new sample lie in $[-1,1]$, the result does too. A fixed retention factor in $[0,1]$ also preserves that bound. With four fixed readings $(+1,+1,-1,-1)$ or their reverse, equal weighting gives zero either way. Starting at zero and retaining half the old value gives $-9/16$ and $+9/16$ respectively. Reversal invariance of the mean holds for fixed readings even though training feedback may change the readings an episode generates. The owner selected equal weighting. [Episode weighting decision](../decisions/ADR-124.md)

## Internal review of an exponential stage

At `4c49382`, Codex (GPT-6), the author acting as the internal reviewer, examined the proposed trace $\tau T'=C-T$ and the recovered homeostat $50 h'=Q-h$. For this check only, the drive is constant on each stage and duration is nonnegative. The proposed trace uses an unselected positive time constant. [Historical numerics](../decisions/ADR-097.md) · [Homeostat](../decisions/ADR-094.md)

- **ST-01, high.** Differentiate the exact stage, verify its initial value, and check that adjacent stages combine when the drive is unchanged. A varying drive requires a numerical approximation or its own integral; accuracy of such an approximation is outside scope.
- **ST-02, high.** Prove interval preservation for a bounded drive and initial value. For nonnegative $h,Q$ show that the recovered denominator $1+h$ is at least one. Preserve the distinction between this sufficient condition and a selected model for $Q$.
- **ST-03, high.** Start a proposed pair trace at zero. On two equal positive durations, compare opposite drives in both orders against their duration-weighted mean. Derive the terminal responses for arbitrary retention in $(0,1)$ and give an exact half-retention example. Choosing a physical time constant or window requires owner direction.

These remedies clear the constant-drive algebra and counterexample for experimental Lean. They leave the pair trace and its episode summary provisional.

### What the trace retains within one episode

The [Lean check](../../scripts/experiments/exponential-stage.lean) addresses ST-01 through ST-03 against review revision `30e63d6`. With drive $q$ held constant and time constant $\tau>0$, the exact stage from $x$ is $q+(x-q)e^{-t/\tau}$. Lean checked its initial value and differential equation. Splitting a constant-drive interval gives the same endpoint. For $t\ge 0$, the result stays in any closed interval containing both $x$ and $q$. In particular, if the initial homeostat and drive are nonnegative, $1+h(t)\ge 1$ throughout a constant-drive stage at the recovered time constant 50. The model still needs a definition of $Q$ and its initialization.

For a zero-start pair trace, take two halves of equal positive duration $T$ with signed alignment $+1$ and $-1$. Their duration-weighted mean is zero in either order. With $r=e^{-T/\tau}$, the terminal trace is $-(1-r)^2$ for positive then negative alignment and $+(1-r)^2$ in reverse. At half retention these values are $-1/4$ and $+1/4$. This example measures temporal weighting within a presentation. ADR-124 already gives the resulting four episode summaries equal weight. A time mean of raw alignment would preserve equal influence per unit of exposure, and a terminal trace would deliberately emphasize late alignment. Comparing them empirically requires paired trained recall runs. [Across-episode decision](../decisions/ADR-124.md)

The owner selected the elapsed-time mean for the first pilot. [Within-episode decision](../decisions/ADR-125.md)

## Internal review of the selected time mean

At `7607fe1`, Codex (GPT-6), the author acting as internal reviewer under ADR-109, scoped an experiment on the selected positive-duration mean of integrable signed alignment.

- **TM-01, high.** Require a positive elapsed duration for every mean. Check constant signals, bounds for signed unit-phase alignment, and composition at an interior cut using duration weights. Include unequal durations to detect an erroneous mean of means.
- **TM-02, high.** Check a bounded, varying signal by an actual time integral on a full window and on its early and late halves. Identify what the window choice can change without treating an artificial signal as a measured training trajectory.

These remedies clear the averaging identities and counterexamples only. The experiment leaves the training events, quadrature scheme, and recall performance open.

### Exact time averages on a training window

The [Lean check](../../scripts/experiments/training-window-mean.lean) implements TM-01/02 against review revision `992b68e`. It requires a positive window duration. A constant signal has its original value as its mean. If both oscillator phases have unit magnitude and their signed alignment is interval integrable, its mean lies in $[-1,1]$.

Splitting a window at an interior time preserves the full mean when each subwindow mean is weighted by elapsed duration. For subwindows of lengths three and one with respective means +1 and −1, the full mean is +1/2. Counting the two subwindows equally would give zero. This identity uses exact subwindow means; using one sampled value to estimate a varying subwindow mean still requires a quadrature rule.

Window placement is a separate choice. As an illustration, integrate the bounded signal $C(t)=t$ on $[-1,1]$. Lean gives zero over the full interval, −1/2 over its early half, and +1/2 over its late half. The example gives an exact difference for the same signal under different windows. Actual phase histories and their recall rates require trained runs. [Owner decision](../decisions/ADR-125.md)

The owner chose the full scheduled episode for the first pilot. [Window decision](../decisions/ADR-126.md)

## Internal review of candidate episode durations

At `dbc6441`, Codex (GPT-6), the author acting as internal reviewer under ADR-109, scoped a comparison at 25 and 50 model time units per training word. These are new candidates motivated by half and one recovered homeostat time constant. The recall readout has its own clock. [Homeostat](../decisions/ADR-094.md) · [Scheduled window](../decisions/ADR-126.md)

- **ED-01.** Compare the exact homeostat response with constant drive one and initial value zero, retaining both the exact values and their ordering. State that the actual drive and initial state still need definitions.
- **ED-02.** Use a bounded varying alignment on the same physical timeline to show how extending a full training episode can change the mean. Compute nominal step counts at all three recovered step sizes. Internal event cuts may add steps. Neither example estimates the trained recall rate.

These remedies clear only the duration arithmetic and illustrative integrals.

### Checked duration candidates

At review revision `b92b309`, the [homeostat check](../../scripts/experiments/exponential-stage.lean) and [window check](../../scripts/experiments/training-window-mean.lean) address ED-01/02. With constant drive one and zero initial homeostat, the exact responses are $1-e^{-1/2}$ at time 25 and $1-e^{-1}$ at time 50. These are approximately 39.35% and 63.21% of the imposed drive. The times are pilot proposals derived from the homeostat scale. No historical episode length was recovered.

| Training duration per word | Nominal steps at 0.1 | At 0.05 | At 0.025 | Mean for the trial alignment $C(t)=t/25-1$ |
|---|---:|---:|---:|---:|
| 25 | 250 | 500 | 1000 | −1/2 |
| 50 | 500 | 1000 | 2000 | 0 |

The linear test signal stays within $[-1,1]$ on the entire time interval. Extending the window can therefore change the stored mean even on an identical alignment history. Training-step counts double at every recovered step size before extra internal event cuts. The counts describe training work only. Which duration yields better exact-word recall at the separate $t=40$ endpoint requires paired development runs.

The owner selected both durations on identical development cues. [Paired-duration decision](../decisions/ADR-127.md)

## Internal review of paired duration scoring

At `24cae71`, Codex (GPT-6), the author acting in the internal reviewer role, reviewed the offline comparison of two $t=40$ prediction exports.

- **PD-01.** Use one frozen target and corruption roster for both files, join by cue ID, validate each file, and keep missing, failed, or abstaining results in each denominator. Preserve the existing single-condition command and its metrics.
- **PD-02.** Count exact words in both runs, only at 25, only at 50, and in neither. Compute the signed difference (50 minus 25) over all scheduled cues and report discordant cue IDs in deterministic order. Check swapped files, equal marginal counts with different hits, and an empty schedule.

These remedies clear the paired scorer on already-decoded inputs. The simulator must supply the specified training conditions and identical realized development cues. The scorer cannot establish their provenance from an ID alone.

### Paired command check

The [Lean scorer](../../scripts/experiments/recall-scoring.lean) checks PD-01/02 against review revision `a861761`. On a five-cue fixture, each condition recovers one word, but those successes occur on different cues. The paired table records one success unique to each duration and three misses in both. The difference is zero. Lean also checks empty exports, missing predictions, invalid timestamps and IDs, and reversal of the difference when the two files are swapped. For any paired table the common successes cancel from the difference of the two exact-word counts.

In a separate command-line fixture with four scheduled cues, 25-unit training alone recovered cue `a` and 50-unit training alone recovered `b` and `c`. The signed difference was +1/4 and became −1/4 when the files were swapped. Both fixtures contain synthetic predictions. [Command and file format](../experiments/benchmarks.md#score-a-recall-export)

## Internal review of spatial weighting during retrieval

At `024d60f`, Codex (GPT-6), the author acting as internal reviewer under ADR-109, reviewed a conditional comparison for using stored pair values during retrieval. Both candidates store all trained pairs. For a focal site, one uses uniform cell-area weights for its learned mean, and the other multiplies by the existing structural row. [Full pairwise training input](../decisions/ADR-123.md) · [Structural quadrature](../decisions/ADR-114.md)

- **FB-01.** For a finite row with nonnegative integration weights, stored pair values in $[-1,1]$, and unit-bounded complex phases, prove a learned-mean norm bound using the actual weight sum. Distinguish normalized rows and uniform cell area from raw structural mass. Avoid dividing by the sum of signed learned values, which can vanish.
- **FB-02.** Use a two-site illustration where the structural weight at the remote site is zero. Preserve the self-entry of one and vary only the remote stored sign. Calculate both complex means for the same two current phases. Check their difference in the existing phase velocity with the same structural mean, lag and a symbolic learned multiplier in both variants. Exclude choices of scalar gain, coupler calibration, learned equation, and target recall accuracy.

These remedies clear the finite-row algebra and example only. Both the spatial weighting and its relation to the recovered scalar gain require an owner decision before use in a trained simulator.

### Which stored pairs reach the retrieval field

The [Lean experiment](../../scripts/experiments/learned-spatial-weights.lean) checks FB-01/02 against review revision `9518db6`. For a focal site, write the candidate learned mean as $L=\sum_j w_j M_{ij}z_j$. Here $M_{ij}$ is a stored signed alignment and $z_j$ the current phase. With nonnegative $w_j$, $|M_{ij}|\le 1$, and $|z_j|\le 1$, Lean proves $|L|\le\sum_j w_j$. Uniform cell-area weights $w_j=1/N$ sum to one for any positive site count. If the structural weights are used instead, the same bound uses their actual row mass. This distinction matters for the raw structural quadrature option.

In a two-site example the current phases are $1,i$. The local stored value is one. For a remote stored value $m=+1$ or $-1$, equal cell-area weights give learned means $(1+i)/2$ and $(1-i)/2$. If the remote site is outside the structural support, the illustrative normalized structural row $(1,0)$ gives the same learned mean of one in both cases. The signed row with entries $(1,-1)$ sums to zero under equal cell weights but has a nonzero learned mean. Normalizing by that signed sum would be undefined.

If a common structural mean and $gL$ are supplied to the existing phase law at local phase 1, flipping the remote stored value from −1 to +1 changes instantaneous angular velocity by $\kappa g\cos\alpha$ in the equal-cell example and by zero in the finite-range example. This result is conditional on the placement of $g$ and can vanish for particular parameters. The learned multiplier, training feedback, behavior over time and held-out recall all remain open. [Current phase law](../mathematics/evolution.md)

The owner selected equal cell-area weights on the entire grid for learned retrieval. [Retrieval weighting decision](../decisions/ADR-128.md)

## Internal review of four-word memory construction

At `cc1c6dc`, Codex (GPT-6), the author acting as internal reviewer under ADR-109, reviewed a bounded reference calculation for the accepted training and retrieval rules. Use positive-duration piecewise-constant phase histories with unit vectors in the complex plane. Signed alignment on each segment is the real dot product of the two phase vectors. This gives exact integrals for these histories and supplies a regression reference for a future numerical solver.

- **MC-01, high.** Check positive segment durations, exact coverage of the scheduled duration, and unit phases. Divide within each episode by its own elapsed duration and average four separate episode summaries. Include a fixture with unequal segment lengths and a fixture with different segment partitions across words.
- **MC-02, high.** Derive symmetry and unit diagonal from the actual accumulation formula. Use the full signed row including its self-entry, divide by the number of sites exactly once, and validate an example where row-sum normalization would lose the learned field.
- **MC-03, high.** Run exact arithmetic for both 25- and 50-unit fixtures, reporting matrix entries and a cue response. Deliberately scale the same history in the duration control. The first trained recall result still requires measured oscillator trajectories, learned dynamics, and a decoder.

These remedies clear a standalone training and retrieval reference calculation for the stated input class. They select no trajectory approximation or new dynamical parameters.

### Exact four-word training and retrieval control

The [runnable Lean reference](../../scripts/experiments/four-word-memory.lean) checks MC-01 through MC-03 against review revision `3791c55`. It verifies the prescribed duration for each of four input histories, positive segment durations, and unit phases. Within a piecewise-constant segment it computes the exact signed alignment from rational real and imaginary coordinates. Lean connects that computation to the real part of the complex relative phase and proves that every accepted library produces a symmetric matrix with unit diagonal.

For two sites, the four test words have off-diagonal episode means $1/2,-1,1,0$. The first word spends three quarters of its time in agreement and one quarter in opposition. The stored off-diagonal value is therefore $1/8$. With current phases $(1,i)$ the two learned fields are $1/2+i/16$ and $1/16+i/2$. The 25- and 50-unit controls produce these same values because the latter doubles every segment duration with the same phases. A separate library in opposition throughout produces a zero signed row sum and a nonzero learned field. The checks reject an empty grid, missing or invalid duration, or a nonunit phase.

Run this at the repository root to print both exact controls. A simulator can use the controls to check its training and retrieval arithmetic. The inputs are prescribed phase histories; a trained recall run must generate its own histories.

```sh
lake env lean --run scripts/experiments/four-word-memory.lean
```

## Internal review of the learned phase lag

At `a2e1b54`, Codex (GPT-6), the author in the internal reviewer role, reviewed an isolated two-oscillator control for a candidate additive sine interaction driven by the approved learned mean. The current unforced structural lag is $\alpha=\pi/2-0.1$. For the learned channel, compare the same lag with zero lag. Take equal frequencies, reciprocal off-diagonal memory $m$, unit diagonal, equal cell area $1/2$, and a common learned multiplier $g$. The structural contribution to the phase difference is omitted in this control.

- **LG-01, high.** Derive the pair torque from the signed imaginary part of the complex interaction. Include both self-entries and both directions of the learned pair. Check the sign of the relative phase equation and cancellation of common drift.
- **LG-02, high.** For $m=1$, $g>0$ and an initial relative phase of $\pi/2$, check the explicit relative trajectory against the differential equation and the initial condition. Evaluate its half-angle tangent at $t=40$ and compare the two lag choices at the same gain.
- **LG-03, high.** Separate this exact phase-correction control from a trained 16-bit recall rate. The example omits structural forcing, other sites, homeostasis, and decoder behavior. Keep $g$ symbolic to avoid choosing its placement or value.

These remedies clear only the phase-lag comparison and two-site trajectory. The full learned phase law and its gain require owner choices.

### Two-site phase correction at t=40

The [Lean calculation](../../scripts/experiments/learned-phase-lag.lean) checks LG-01 through LG-03 against review revision `999d6ed`. It connects the two signed contributions, including the self-entry, to the existing complex angular-velocity function. Subtracting the velocities of the two sites with phase difference $\delta$ gives

$$\dot\delta=-g\,m\,\cos(\beta)\sin(\delta).$$

In this isolated learned interaction, the equal self-entries cause common rotation and cancel from the relative equation. For a pair stored in agreement ($m=1$) and initially $\pi/2$ apart, the verified trajectory is $\delta(t)=2\arctan(e^{-g\cos(\beta)t})$. Lean checks its initial value, derivative and endpoint. At $t=40$ the half-angle tangent is $e^{-40g}$ with zero learned lag and $e^{-40g\sin(0.1)}$ with the structural reference lag. At the same positive gain both reduce the initial gap, and zero learned lag leaves a strictly smaller gap. The structural lag gives about 9.98% of the zero-lag decay coefficient in this control.

This result motivates zero lag as a candidate for the learned contribution while retaining the specified lag in the structural contribution. Training trajectories, multi-site interference, structural coupling, cue timing and decoding can all affect the actual recall outcome. A comparison across the 25- and 50-unit development runs would measure the effect on exact-word recall. [Structural reference parameters](../mathematics/evolution.md) · [Pilot benchmark](../experiments/benchmarks.md#first-trained-recall-measurement)
