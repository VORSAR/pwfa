---
name: lean-verify
description: Write, verify and review Lean 4 code for formal verification, using toolchain-current idioms instead of stale memory. Use this skill whenever work touches Lean 4 - .lean files, lakefile.toml/lakefile.lean, lean-toolchain, theorems, tactics, specifications or contracts (requires/ensures), vcgen, grind, Hoare triples, loop invariants, proof repair, or `sorry` - and whenever the user asks to prove a program correct, formalize a specification, check whether a Lean proof or AI-generated proof can be trusted, audit axioms, or review a Lean PR. Also use it when a Lean proof is stuck or going in circles, and when unsure whether a Lean feature, tactic or syntax still exists in the project's version. Covers a version handshake, spec-first writing with contracts and vcgen, a trust ladder and specification audit for reviews, a backtracking protocol for stuck proofs, and where to find current Lean knowledge.
---

# Lean verification: write, review, and stay current

## Why this skill exists

Lean ships a stable release about every month, and the program-verification surface was rebuilt
between September and November 2026 (4.34 to 4.36): contracts on `def`, the `vcgen` tactic, a new
`Std.WP` library, bundled independent proof checkers. What you remember about verifying programs
in Lean is probably older than that. Code written from memory tends to compile with deprecation
warnings at best. Even the examples in the 4.34 release notes no longer compile on 4.36.

So this skill is built on one rule: **the compiler in the project's toolchain is the authority;
everything else, including this skill, is a dated hint.** The references here were compiled
against Lean 4.36.0 and say so. When they disagree with the compiler, the compiler is right.

The second rule concerns honesty about results. Lean can establish that a statement is proved.
It cannot establish that the statement is the one anybody wanted. Most real verification
failures are of the second kind, and they pass every automated check.

## Step 0: handshake (every session, before writing or judging anything)

```bash
bash <skill-dir>/scripts/lean_env.sh [project-dir]
```

It reports the project's toolchain, which bundled tools exist (Lean Beam, external kernels,
sandbox), whether Mathlib is a dependency, and a verdict comparing the toolchain with this
skill's snapshot. Act on the verdict:

- **Matches the snapshot**: the references apply as written.
- **Newer**: run `python3 <skill-dir>/scripts/whats_new.py --from 36 --to <minor>` and read the
  highlights and breaking changes before writing verification code. Recompile the relevant file
  from `assets/examples/` as a probe.
- **Older than 4.35**: `vcgen` and most contract syntax do not exist there. Read the version
  table in `references/freshness.md` and tell the user what the toolchain lacks.
- **No Lean found**: say so. Do not present unbuilt Lean code as working; offer it explicitly
  as an unchecked draft.

## Writing verified code

1. **Agree the specification first.** State it in plain language, then in Lean, and show both to
   the user before investing in proofs, because a proof of the wrong statement is waste. Write
   it in terms the implementation does not use. Ask of it what `references/review.md` section 3
   asks: can the preconditions be met, does the postcondition pin the result down, what happens
   on the failing path.
2. **Pick the style** (`references/verification.md` section 2): contract clauses on the `def`
   for effectful code, separate theorems with `vcgen` for existing code or multi-function
   properties, `fun_induction` and `grind` for pure recursive functions.
3. **Choose a strategy before the first tactic** (`references/stuck.md` section 8): write the
   informal argument in a few sentences, match the goal shape to a first tactic, and sketch a
   skeleton when the argument has more than two steps.
4. **Build in small steps.** One definition or one proof step, then build
   (`lake build`, `lake env lean File.lean`, or Lean Beam probes if installed). Fix errors in
   the order syntax, types, unsolved goals, warnings. Let `grind` and `vcgen … with finish` do
   the routine work (`references/automation.md`).
5. **When a verification condition will not close, ask first whether it is true.** An open VC is
   often Lean pointing at a bug in the code or the specification. Follow the stuck protocol.
6. **Finish with evidence**, in this order:
   ```bash
   lake build --wfail                                          # no sorry, no deprecation warnings
   lake env lean --run <skill-dir>/scripts/AxiomAudit.lean <Module>...   # only the 3 standard axioms
   python3 <skill-dir>/scripts/spec_smells.py <paths>          # nothing unexplained
   ```
   Then report: toolchain version, commands run, axioms, anything not checked.

Things that are never yours to do silently, because each changes what is being claimed:
weakening or rewording the agreed specification, adding hypotheses, leaving `sorry`, declaring
an `axiom`, using `native_decide`, adding `@[implemented_by]`, `unsafe` or `partial` to verified
code, or defining instances and notation that alter what a statement means. If one seems
necessary, stop and put the choice to the user with the evidence.

## Reviewing Lean code and proofs

Treat the code as untrusted, your own included. Read `references/review.md`, then:

1. **Is it proved?** Climb the trust ladder as far as the stakes require: `lake build --wfail`,
   the axiom audit, `lake check` (sandboxed kernel replay, Linux), `lake check --paranoid`
   (all bundled independent kernels), `lake comparator` against a trusted statement file.
2. **Does it mean what it claims?** Run `scripts/spec_smells.py` for leads, then do the
   specification audit by reading: restate each key theorem from its Lean text alone, open
   every definition and instance it depends on, check the hypotheses are satisfiable, check the
   conclusion excludes wrong implementations (mutation probe), check that the proved function
   is the one that runs.
3. **Report** in the format of `review.md` section 6: verdict, rung reached, findings with
   evidence, and an explicit "not checked" list.

`assets/examples/Defects.lean` holds ten planted defects that Lean 4.36 accepts; seven leave no
trace in any axiom check. Use it to calibrate, and to confirm on a new toolchain that the
review tooling still behaves as documented.

## When a proof is stuck

Read `references/stuck.md` as soon as one of these happens: three attempts on the same goal
that differ only in tactics; goals growing instead of shrinking; the same error twice; a
timeout; ten build cycles on one verification condition; or the urge to weaken something.

The protocol in brief:

1. **Falsify first.** Evaluate the claim on boundary inputs, try a bounded `decide`, read the
   countermodel in `grind +verbose`. If the goal is false, stop and report what is wrong.
2. **Classify the failure** (false statement, weak invariant, missing fact, fact present but
   unused, wrong architecture, elaboration problem, toolchain drift, hostile definition).
3. **Backtrack by level, not by variant.** At most three tries per rung, then climb:
   tactic, goal inspection and isolation, missing lemma, stronger invariant or generalised
   induction, different proof architecture, definition change (user agrees), specification
   change (user decides), escalate.
4. **Fetch resources for that class** using the table in `stuck.md` section 5.
5. **Keep a journal** (`assets/proof-journal.md`) so that failed approaches are not repeated and
   a later session can resume.
6. **Escalate with a stuck report** instead of an unexplained `sorry`.

## Finding current knowledge

Order of authority, details in `references/freshness.md` and `references/search.md`:

1. a probe compiled in the project's toolchain;
2. the library sources shipped with it: `"$(lean --print-prefix)/src/lean"` (grep these for
   syntax declarations, docstrings, and proofs of similar lemmas);
3. the reference manual for that version: `https://lean-lang.org/doc/reference/<version>/`;
4. release notes since the snapshot (`scripts/whats_new.py`);
5. dependency sources in `.lake/packages/`;
6. search engines and community channels;
7. memory, last.

In-project search (`exact?`, `try?`, `grind?`, grep) comes before web search. The web engines
mostly index Mathlib. Never cite a lemma name without confirming it with `#check`.

## Working with other Lean tooling

This skill covers what to verify, how to judge it, and how to stay current. It does not replace
tools for the inner loop:

- **Lean Beam** (`lean-beam`, bundled with 4.36+ toolchains on Linux and macOS): proof states,
  speculative `run-at` probes, checkpoints. If its skill is installed, use it for mechanics and
  use this skill for strategy. Beam is a development aid and not proof acceptance.
- **Official `leanprover/skills`** (`lean-proof`, `lean-setup`, `lean-mwe`, `lean-bisect`,
  Mathlib PR and review skills): follow them for their topics. They and this skill agree on
  stepwise proving and on attacking the hardest case first.
- If neither is present, plain `lake build` and `lake env lean` are enough.

## Reference index

| Read | When |
|---|---|
| `references/freshness.md` | handshake says the toolchain differs; any doubt whether syntax or a tactic exists; refreshing this skill |
| `references/verification.md` | writing contracts, invariants, `vcgen` proofs, `@[spec]` lemmas; decoding their errors |
| `references/automation.md` | choosing a tactic; using and debugging `grind` |
| `references/stuck.md` | a stuck trigger fired; planning a hard proof |
| `references/review.md` | any review, audit, or "can I trust this" question; before reporting your own work as verified |
| `references/search.md` | looking for a lemma, a definition, or a package |
| `references/ecosystem.md` | the target is Rust, a protocol, another language, or needs a library beyond core |
| `references/conventions.md` | naming, documentation, CI, contributing upstream, AI disclosure |

Scripts (`scripts/`): `lean_env.sh` (handshake), `AxiomAudit.lean` (per-declaration axioms),
`spec_smells.py` (static review leads), `whats_new.py` (release-note delta).
Examples (`assets/examples/`), all compiled on 4.36.0: `Intrinsic.lean`, `Extrinsic.lean`,
`Backtrack.lean`, `Defects.lean`.
