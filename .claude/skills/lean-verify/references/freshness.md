# Freshness: where the truth about Lean lives

Snapshot: **Lean 4.36.0, November 2026**. Everything in this skill marked "verified" was compiled
against that toolchain. Lean publishes a stable release about once a month and the verification
features are flagged experimental, so assume drift and check.

## Order of authority

When two sources disagree, the one higher in this list wins.

1. **The compiler in the project's toolchain.** Write a three-line probe and build it. Nothing
   else is evidence that code works.
2. **The library sources shipped with that toolchain**: `"$(lean --print-prefix)/src/lean"`. These
   are the definitions, docstrings and syntax declarations for exactly this version.
3. **The reference manual for that version**: `https://lean-lang.org/doc/reference/<version>/`
   (for example `4.36.0`; `latest` tracks the newest release, which may be ahead of the project).
4. **Release notes** between the snapshot and the project's version: `scripts/whats_new.py`,
   or `https://lean-lang.org/doc/reference/latest/releases/`.
5. **Sources of the project's dependencies**: `.lake/packages/<dep>/`.
6. **Upstream repositories**: `leanprover/lean4`, `leanprover/reference-manual` (manual and
   tutorials source, including `Tutorial/VCGen.lean`), package repos and their changelogs.
7. **Community**: Lean Zulip, GitHub issues. Useful for "has anyone hit this", weak for syntax.
8. **This skill's references.** A dated snapshot.
9. **Your own memory of Lean.** Last. It predates most of the verification surface.

Even official material goes stale quickly: the `sumEvens` example printed in the 4.34 release
notes does not compile on 4.36 (the invariant binder form and the VC binder names both changed).

## How to probe

```bash
# does this tactic / syntax exist here, and what does it print?
printf 'example (a b : Nat) (h : a < b) : a + 1 ≤ b := by lia\n' > Probe.lean
lake env lean Probe.lean            # inside a project; plain `lean Probe.lean` outside one

# how is a tactic or clause declared, and what does its docstring say?
SRC="$(lean --print-prefix)/src/lean"
grep -rn 'syntax (name := vcgen)' "$SRC"              # -> Std/WP/Tactic.lean
grep -rn -B8 'syntax (name := vcgen)' "$SRC/Std/WP/Tactic.lean"
grep -rln 'experimental.intrinsic' "$SRC"             # where contracts are implemented

# what does a lemma say, and what does it rest on?
printf '#check @List.length_append\n#print axioms List.length_append\n' > Probe.lean && lean Probe.lean
```

If Lean Beam is installed, `run-at` does the same against the real file position without a
scratch file; use its own skill for the mechanics.

## What changed when

Facts below come from the release notes; the 4.36 column was also exercised in this skill's examples.

| Version | Date | Relevant change |
|---|---|---|
| 4.29 | 2026-03 | `decide +native` and `bv_decide` introduce one dedicated axiom per native computation (names contain `_native`) instead of a shared one |
| 4.34 | 2026-09 | Intrinsic verification syntax arrives: `requires`/`ensures` contracts on `def`, `for … invariant`, `assert`, leftover VCs in `where finally \| spec`. Invariants bind consumed prefix and remaining suffix |
| 4.35 | 2026-10 | `vcgen` replaces `mvcgen` (deprecated). `Std.WP` generalises weakest preconditions beyond monads to deep embeddings. `given` clause; `while … invariant … decreasing`; `erased` verification-only variables. `lake check` and `lake comparator`; external kernels bundled. `Lean.trustCompiler`, `Lean.reduceBool` removed. `rwa` redesigned |
| 4.36 | 2026-11 | `throws` clauses. Tactics of the `Std.Do` proof mode (`mintro`, `mspec`, …) deprecated; `import Std.WP` provides `vcgen`. `bv_decide +uf`. `grind` handles many more bit-vector, `Char` and `Fin` goals. Lean Beam (CLI + MCP server for agents) bundled on Linux and macOS. Several `Std.WP` renames with deprecated aliases |
| 4.37 | rc1 2026-11-18 | Not reviewed for this snapshot. Run `whats_new.py --from 36 --all` |

## Stale idioms

| What memory or older material suggests | Status on 4.36 | Use instead |
|---|---|---|
| `import Std.Tactic.Do`, `open Std.Do`, `mvcgen`, `mintro`, `mspec` | deprecated, warns | `import Std.WP`, `open Std.WP Lean.Order`, `vcgen` |
| Separate `theorem f_spec … := by mvcgen …` as the only style | still possible with `vcgen` | also: contract clauses on the `def` itself |
| `for x in xs invariant cur => …` (one cursor binder) | error | `invariant pref suff => …` (two binders, then state) |
| `ensures \| none => … \| some v => …` (match alternatives) | removed in 4.35 | `ensures r => match r with …` or a `fun`-style pattern |
| Check for `Lean.trustCompiler` / `Lean.ofReduceBool` in `#print axioms` | axiom removed | look for axioms with `_native` in the name |
| Install `lean4checker`, `comparator`, `lean4lean` separately | bundled since 4.35 | `lake check`, `lake comparator`, both with `--paranoid` |
| `omega` only for linear integer arithmetic | still works | `lia` also exists, and `grind` has a linear integer solver built in |
| "Lean has no VC generator; verify by unfolding and induction" | outdated | `vcgen`; direct proofs remain fine for small pure functions |

## Refreshing this snapshot

1. `python3 scripts/whats_new.py --from 36 --all` and read the highlights and breaking changes.
2. Recompile every file in `assets/examples/` on the new toolchain. Each failure is a change to
   record. `Defects.lean` must still compile and still show the documented axiom outputs;
   if a defect becomes an error, that is good news to note in `review.md`.
3. Update the two tables above, the affected reference files, and `SNAPSHOT_MINOR` in
   `scripts/lean_env.sh`.
4. Note the date. A snapshot more than three releases old should be treated as a list of
   questions to ask the compiler.
