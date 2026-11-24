---
type: llm
focus: trace
weight: 1
---

The proved specification of tryConsume determines the new token count exactly when the request is accepted (old tokens minus n) and states that the state is unchanged when it is refused; a constant or do-nothing implementation would not satisfy it
