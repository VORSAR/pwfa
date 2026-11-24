# Finding definitions, lemmas and packages

Search the project and the toolchain before the web. The web engines index Mathlib well and
everything else unevenly; verification work mostly needs core, `Std`, and the project's own code.

## 1. Inside the project (always first)

| Question | Tool |
|---|---|
| Does a lemma close this exact goal? | `exact?` at the goal (prints `exact Lemma …`) |
| What closes it, by any means? | `try?` (prints `simp …`, `grind only […]` alternatives) |
| Which lemmas did automation use? | `grind?`, `simp?` |
| What is this name's statement? | `#check @Name`; `#print Name` for the definition |
| Where is something defined or used? | Lean Beam `definition`, `references`, `workspace-symbols QUERY` if installed; otherwise the editor's go-to-definition |
| Is there a lemma about operation X? | `grep -rn "theorem .*X" "$(lean --print-prefix)/src/lean"` and the same over `.lake/packages/` |
| How is a similar thing proved? | read the neighbouring proofs in those sources |

Lemma names follow a convention you can guess from: operations in order of appearance, joined
by underscores (`List.length_append`, `Nat.add_comm`, `Array.sum_push`). Guess, then confirm with
`#check`. Never cite a guessed name without checking it.

## 2. Reference documentation

- Reference manual for the project's version: `https://lean-lang.org/doc/reference/<version>/`.
  Chapters that matter here: Tactic Proofs, The Simplifier, The `grind` tactic, The `vcgen`
  tactic, Build Tools (Lake), Linters and Code Quality, External Kernels, Validating a Lean
  Proof, Error Explanations.
- Tutorials are in the same source repository (`leanprover/reference-manual`, directory
  `Tutorial/`): verifying imperative programs with `vcgen`, and `grind` on an ordered map.

## 3. Web search engines (snapshot of the landscape, November 2026)

Not exercised from this skill's build environment; confirm endpoints before scripting them.

| Engine | Kind | Use for |
|---|---|---|
| Loogle (`loogle.lean-lang.org`) | pattern and type-shape search | "a lemma of the form `_ ++ _ = _`"; exact, no fuzziness |
| LeanSearch (v2) | natural-language semantic search | "sum of an appended list" |
| Lean Finder | semantic search tuned to user intent, accepts proof states | pasting a goal |
| LeanExplore | semantic search over Mathlib plus `Std`, `Init`, `Batteries`, `Lean` | non-Mathlib declarations |
| Moogle | older semantic search | fallback |

Published comparisons disagree on ranking and are run on Mathlib queries, so try two engines.
Whatever an engine returns, confirm with `#check` in the project: the name may belong to a
newer Mathlib, or to a library the project does not depend on.

## 4. Packages and prior work

- **Reservoir** (`reservoir.lean-lang.org`): the package index, with toolchain compatibility.
- **Awesome Lean Programming** (`github.com/saviorand/awesome-lean-programming`): a curated list
  from the programmer's side, including a program-verification section.
- GitHub code search restricted to `language:Lean` finds usage examples of a new feature faster
  than documentation does in the first months after a release.
- **Lean Zulip** (`leanprover.zulipchat.com`, public archive): the community's working memory.
  Good for "is this a known limitation", weak as a syntax reference because threads are not
  updated when things change.

## 5. Adding a dependency is a decision

A lemma that exists only in Mathlib is not free: Mathlib is large, changes daily, and pins the
toolchain. For verification projects on core and `Std`, prefer proving a small helper lemma
locally and say that the Mathlib version exists. Ask before adding any dependency.
