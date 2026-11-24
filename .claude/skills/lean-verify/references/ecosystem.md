# The verification ecosystem around Lean (pointers, November 2026)

This file is a map. Apart from the first row, nothing here was compiled for this snapshot;
entries come from project descriptions and Lean FRO talks. Check each project's repository and
its supported toolchain before recommending or adopting it.

| You want to verify… | Look at | Notes |
|---|---|---|
| Lean code itself: `do` programs, loops, state, exceptions | core contracts and `vcgen` (`verification.md`) | in the toolchain; experimental |
| Rust code | **Aeneas** (`AeneasVerif/aeneas`), with Charon as front end; **hax** (`cryspen/hax`) | translates safe Rust into pure Lean, then you prove in Lean; used for cryptographic code such as SymCrypt |
| Distributed protocols, transition systems | **Veil** (`verse-lab/veil`) | specification language embedded in Lean; SMT-backed push-button checking for decidable fragments, interactive Lean proof otherwise; its VC generator is proved sound in Lean |
| Imperative programs in a Dafny-like, auto-active style | **Velvet** on **Loom** (`verse-lab/velvet`, `verse-lab/loom`) | annotation-heavy style with solver discharge, proofs still kernel-checked |
| Temporal properties | **Lentil** (`verse-lab/Lentil`) | LTL reasoning infrastructure |
| Refinement of stateful systems | **lean-machines** | Event-B-style modelling and refinement |
| A language of your own (deep embedding) | `Std.WP` instances + `vcgen` | since 4.35 `vcgen` works for any program type with a weakest-precondition interpretation |
| Computer-science foundations (semantics, automata, λ-calculi) | **CSLib** (`leanprover/cslib`) | follows Mathlib's contribution and AI-use policies |
| Mathematics-heavy properties | **Mathlib** | large dependency; see `search.md` section 5 |
| Zero-knowledge and blockchain | ArkLib, zkLean, risc0-lean4 | see the Awesome list |

Related infrastructure:

- **Lean Beam** (`leanprover/lean-beam`): official CLI and MCP server giving agents proof
  states, speculative `run-at` probes and module checkpoints through the language server.
  Bundled with Linux and macOS toolchains from 4.36; beta. It ships its own skill; use that for
  the mechanics. Beam describes itself as a non-adversarial development tool: not for judging
  untrusted proofs.
- **Official Lean skills** (`leanprover/skills`): `lean-proof`, `lean-setup`, `lean-bisect`,
  `lean-mwe`, and Mathlib PR and review conventions. Install in Claude Code with
  `claude plugin marketplace add https://github.com/leanprover/skills.git` then
  `claude plugin install lean@leanprover`.
- **lean4-skills** (`cameronfreer/lean4-skills`): community workflow pack for agent-driven
  theorem proving, oriented to Mathlib-style mathematics.
- **lean-lsp-mcp**: community MCP server over the Lean language server; predates Beam.
- **SymM / `sym =>`**: the framework `vcgen` and `grind` are being moved onto for scale. Relevant
  if you write your own verification tooling.

How to discover what is new: Reservoir, the Awesome Lean Programming list, the Lean FRO roadmap
and Leonardo de Moura's published talk slides, the release-note highlights, and the Zulip
announcement stream.
