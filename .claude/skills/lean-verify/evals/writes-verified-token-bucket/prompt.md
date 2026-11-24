---
tags: [lean-verify]
max_turns: 40
timeout_seconds: 1500
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

I'm setting up a new Lean project in this directory (create whatever project files you need). I want a verified token-bucket rate limiter: a state with `tokens` and `capacity`, a `refill` that adds some number of tokens but never goes above capacity, and a `tryConsume` that takes n tokens if available and otherwise leaves the state alone and says no. Prove the invariant tokens ≤ capacity is preserved by both, that tryConsume never makes tokens go negative or silently lose tokens, and that a refused request really changes nothing. Tell me exactly what you proved and how you checked it.
