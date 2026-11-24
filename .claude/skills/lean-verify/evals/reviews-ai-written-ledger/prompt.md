---
tags: [lean-verify]
max_turns: 40
timeout_seconds: 1500
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

A contractor's AI assistant produced Ledger.lean in this project and the PR description says "all theorems machine-checked by Lean, build passing". Before I merge: can I rely on what this file claims to prove? Give me a review I can forward.

Input files: Ledger.lean, lakefile.toml, lean-toolchain
