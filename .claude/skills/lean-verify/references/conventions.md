# Conventions

Follow the project's existing style first. Where it has none, these are the community defaults.

## Naming (Mathlib convention, used across the ecosystem)

- Theorems and lemmas: `snake_case`, describing the statement left to right:
  `length_append`, `sum_push`, `clamp_le_hi`. Hypotheses appear after `of`: `pos_of_ne_zero`.
- Types, structures, classes, propositions as types: `UpperCamelCase`.
- Functions and other terms: `lowerCamelCase`.
- Put declarations in a namespace named for the main type (`List.length_append`), so dot
  notation works.
- Use `≤` and `<`; avoid `≥` and `>` in statements. Automation and lemma names assume it.

Full guides: `leanprover-community.github.io/contribute/naming.html`, `…/style.html`, `…/doc.html`.

## Documentation

- A docstring (`/-- … -/`) on every definition and every theorem that is part of the interface,
  stating in plain language what it says. A reviewer compares this sentence with the statement.
- A module docstring (`/-! … -/`) at the top of each file: what the file is for, main results.

## Verification-specific

- State specifications in terms the implementation does not use. Prefer a simple reference
  function or a two-sided characterisation over a list of one-directional facts.
- Keep specification helper definitions small and separately readable: they are part of the
  trusted reading of every theorem that mentions them.
- No `sorry`, `axiom`, `native_decide`, `@[implemented_by]`, `unsafe` or `partial` in verified
  code paths without an explicit comment saying why and who agreed.
- Put the `experimental.*` options once per file near the imports, so their use is visible.
- Pin the toolchain (`lean-toolchain`) and commit `lake-manifest.json`. A proof is only
  reproducible against the versions it was checked with.
- Run `lake build --wfail` and the axiom audit in CI; on Linux CI add `lake check`.

## Contributing upstream, and AI disclosure

Mathlib accepts AI-assisted contributions only under conditions: its guide states that code
written by an AI without supervision from someone expert in Lean falls well below its bar, that
low-quality LLM pull requests are closed without comment, and that a PR with substantial
LLM-generated code must be labelled `LLM-generated`. CSLib follows the same policy. If work is
headed upstream: disclose the tools used, make sure the human submitter has read and can defend
every declaration, and read the current policy at
`leanprover-community.github.io/contribute/index.html` first, since it has been changing.
The official `mathlib-pr` and `mathlib-review` skills cover the mechanics.
