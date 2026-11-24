import Lean
open Lean

/-!
Per-declaration axiom audit.

  lake env lean --run AxiomAudit.lean [--allow Ax.name]... [--json] Module [Module...]

For every theorem/definition declared in the given (already built) modules, list the axioms it
depends on that are outside the allowlist (default: propext, Classical.choice, Quot.sound).
Exit code 0 = clean, 1 = findings, 2 = could not run.
-/

def standardAxioms : List Name := [``propext, ``Classical.choice, ``Quot.sound]

structure Finding where
  decl : Name
  kind : String
  axioms : Array Name

def classify (ax : Name) : String :=
  if ax == ``sorryAx then "sorry"
  else if (ax.toString.splitOn "_native").length > 1 then "native-eval"
  else "custom-axiom"

unsafe def main (args : List String) : IO UInt32 := do
  let mut allow : List Name := standardAxioms
  let mut mods : Array Name := #[]
  let mut json := false
  let mut rest := args
  while !rest.isEmpty do
    match rest with
    | "--allow" :: a :: tl => allow := a.toName :: allow; rest := tl
    | "--json" :: tl => json := true; rest := tl
    | m :: tl => mods := mods.push m.toName; rest := tl
    | [] => pure ()
  if mods.isEmpty then
    IO.eprintln "usage: lake env lean --run AxiomAudit.lean [--allow AXIOM]... [--json] Module..."
    return 2
  initSearchPath (← findSysroot)
  enableInitializersExecution
  let env ← importModules (mods.map fun m => { module := m }) {} (loadExts := true)
  let ctx : Core.Context := { fileName := "<axiom-audit>", fileMap := default }
  let mut findings : Array Finding := #[]
  let mut declared : Array Name := #[]
  let mut checked := 0
  for m in mods do
    let some idx := env.getModuleIdx? m
      | IO.eprintln s!"module not found in environment: {m}"; return 2
    for c in env.header.moduleData[idx.toNat]!.constNames do
      let some info := env.find? c | continue
      if info.isAxiom then
        declared := declared.push c
        continue
      if c.isInternalDetail then continue
      unless info.isTheorem || info.isDefinition || wasOriginallyTheorem env c do continue
      checked := checked + 1
      let (axs, _) ← (collectAxioms c : CoreM _).toIO ctx { env }
      let bad := axs.filter (!allow.contains ·)
      unless bad.isEmpty do
        findings := findings.push { decl := c, kind := if info.isTheorem then "theorem" else "def", axioms := bad }
  if json then
    let fs := findings.map fun f => Json.mkObj [
      ("decl", toJson f.decl.toString), ("kind", toJson f.kind),
      ("axioms", toJson (f.axioms.map fun a => Json.mkObj [("name", toJson a.toString), ("class", toJson (classify a))]))]
    IO.println <| Json.compress <| Json.mkObj [
      ("checked", toJson checked), ("axioms_declared", toJson (declared.map (·.toString))),
      ("findings", Json.arr fs)]
  else
    IO.println s!"checked {checked} declarations in {mods.size} module(s)"
    unless declared.isEmpty do
      IO.println s!"axioms DECLARED in these modules: {declared.toList}"
    for f in findings do
      let parts := f.axioms.toList.map fun a => s!"{a} [{classify a}]"
      IO.println s!"  {f.kind} {f.decl}: {", ".intercalate parts}"
    if findings.isEmpty then IO.println "no non-allowlisted axioms"
  return if findings.isEmpty && declared.isEmpty then 0 else 1
