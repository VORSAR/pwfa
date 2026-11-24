#!/usr/bin/env python3
"""Static red-flag scan for Lean 4 sources. A pre-pass for review, not a verdict.

    python3 spec_smells.py PATH [PATH...]          # files or directories (.lake/ is skipped)
    python3 spec_smells.py --json src/
    python3 spec_smells.py --min medium Foo.lean   # hide low/info leads

It reports places where a proof can be accepted by Lean and still not mean what the
reader thinks: gaps (sorry), extensions of the trusted base (axioms, native evaluation,
implemented_by), declarations that change what a statement means (instances of core
classes, notation, macros), weak-looking specifications, Lean semantics that surprise
people (truncating subtraction, `xs[i]!`), and idioms that are deprecated on current
toolchains. Every hit is a lead to read in context: most notation is innocent, and a
clean scan proves nothing. Exit code: 1 if any HIGH lead was found, else 0.
"""
import argparse
import json
import os
import re
import sys

HIGH, MEDIUM, LOW, INFO = "high", "medium", "low", "info"
ORDER = {HIGH: 0, MEDIUM: 1, LOW: 2, INFO: 3}

CORE_CLASSES = (
    r"LE|LT|BEq|DecidableEq|Decidable\w*|OfNat|OfScientific|HAdd|HSub|HMul|HDiv|HMod|HPow|HAppend|"
    r"Add|Sub|Mul|Div|Mod|Neg|Membership|Coe\w*|Inhabited|Nonempty|Ord|Hashable|LawfulBEq|"
    r"EquivBEq|GetElem\w*|ToString|Repr|Min|Max|Std\.WP\.\w+|WP\w*"
)

BENIGN_OPTIONS = re.compile(
    r"^(experimental\.(intrinsic|vcgen)|maxHeartbeats|maxRecDepth|linter\.[\w.]+|pp\.[\w.]+|"
    r"autoImplicit|relaxedAutoImplicit|trace\.[\w.]+|profiler(\.[\w.]+)?|diagnostics(\.[\w.]+)?)$"
)

# (severity, category, regex, message)
RULES = [
    (HIGH, "GAP", r"\b(sorry|admit)\b", "placeholder proof: the statement is assumed, not proved"),
    (HIGH, "TRUST", r"^\s*(?:private\s+|protected\s+|public\s+)?axiom\b", "declares an axiom: everything downstream is only as sound as this statement"),
    (HIGH, "TRUST", r"\bnative_decide\b|\bdecide\s*\+native\b|\bofReduceBool\b|\breduceBool\b",
     "native evaluation: trusts the compiler and every @[implemented_by]/@[extern]; external checkers cannot replay it"),
    (HIGH, "TRUST", r"debug\.skipKernelTC|addDeclWithoutChecking|\bunsafeCast\b|\blcProof\b|\blcUnreachable\b",
     "bypasses or subverts kernel checking"),
    (HIGH, "TRUST", r"@\[\s*(?:[\w.]+\s*,\s*)*implemented_by\b", "runtime behaviour replaced without proof: the theorem is about the model, not the code that runs"),
    (HIGH, "TRUST", r"@\[\s*(?:[\w.]+\s*,\s*)*extern\b", "foreign implementation: proofs are about the Lean model, not the C/FFI code"),
    (MEDIUM, "TRUST", r"^\s*(?:private\s+|protected\s+)?unsafe\s+(def|instance|abbrev)\b", "unsafe definition: check it cannot reach verified code paths"),
    (MEDIUM, "TRUST", r"^\s*(?:@\[[^\]]*\]\s*)?(?:private\s+|protected\s+)?partial\s+def\b",
     "partial def is opaque to proofs: nothing can be proved about its result"),
    (MEDIUM, "TRUST", r"^\s*(?:private\s+|protected\s+)?opaque\b", "opaque constant: specifications cannot see inside it"),
    (MEDIUM, "MEANING", r"^\s*(?:@\[[^\]]*\]\s*)?(?:local\s+|scoped\s+|private\s+)?instance\b[^:\n]*:\s*(?:" + CORE_CLASSES + r")\b",
     "instance of a core class: this decides what ≤, =, ==, +, literals, coercions or `decide` MEAN for the type; read its body"),
    (MEDIUM, "MEANING", r"^\s*(?:local\s+|scoped\s+)?(?:notation|infixl?|infixr|prefix|postfix)\b",
     "custom notation: a statement using it may not say what it appears to say"),
    (MEDIUM, "MEANING", r"^\s*(?:local\s+|scoped\s+)?(?:macro|macro_rules|syntax|elab|elab_rules|binder_predicate)\b",
     "syntax extension or metaprogram: can rewrite statements and tactics; read what it expands to"),
    (MEDIUM, "MEANING", r"attribute\s*\[\s*-\s*instance\s*\]|attribute\s*\[\s*local\s+instance", "instance resolution altered locally"),
    (MEDIUM, "MEANING", r"\bunif_hint\b|@\[\s*(?:[\w.]+\s*,\s*)*(?:reducible|irreducible|csimp)\b", "changes reduction/unification or compiled code path"),
    (MEDIUM, "SPEC", r"\bthrows\b[^\n]*=>\s*True\s*$", "exception postcondition True: the contract permits failing on every input"),
    (MEDIUM, "SPEC", r"\bensures\b[^\n]*=>\s*True\s*$", "postcondition True: the contract promises nothing about the result"),
    (MEDIUM, "SPEC", r"\brequires\b[^\n]*\bFalse\b", "precondition mentions False: check the contract is not vacuous"),
    (MEDIUM, "SPEC", r"\(\s*\w+\s*:\s*False\s*\)|:\s*False\s*→", "hypothesis False: the theorem is vacuous"),
    (MEDIUM, "SPEC", r"(?:\brequires\b|\(\s*\w+\s*:)[^\n]*<\s*0(?![\w.])", "condition `… < 0`: unsatisfiable if the left side is a Nat; check the contract or theorem is not vacuous"),
    (LOW, "SEMANTICS", r"\]\s*!|\.(?:get|head|tail|getLast|back|pop|toNat|toInt)!", "panicking accessor: returns the Inhabited default in proofs; a spec may silently be about `default`"),
    (LOW, "SEMANTICS", r"\bpanic!|\bunreachable!|\bdbgTrace\b", "panic/unreachable evaluates to a default value in the logic"),
    (LOW, "SEMANTICS", r"\bFloat(?:32)?\b", "Float: opaque to most proof automation and not the reals"),
    (INFO, "STALE", r"\bmvcgen\b|\bmintro\b|\bmspec\b|\bmexact\b|\bmhave\b|\bmframe\b|\bopen\s+Std\.Do\b",
     "Std.Do proof mode / mvcgen: deprecated since 4.35-4.36 in favour of vcgen (Std.WP)"),
    (INFO, "STALE", r"\bLean\.trustCompiler\b|\bletFun\b", "removed or deprecated on current toolchains"),
]
COMPILED = [(sev, cat, re.compile(rx), msg) for sev, cat, rx, msg in RULES]
SET_OPTION = re.compile(r"\bset_option\s+([\w.]+)\s+(\S+)")


def strip_comments(text: str) -> str:
    """Blank out comments and string literals, preserving line structure."""
    out, i, n, depth = [], 0, len(text), 0
    while i < n:
        two = text[i:i + 2]
        if depth:
            if two == "/-":
                depth += 1; out.append("  "); i += 2
            elif two == "-/":
                depth -= 1; out.append("  "); i += 2
            else:
                out.append("\n" if text[i] == "\n" else " "); i += 1
        elif two == "/-":
            depth = 1; out.append("  "); i += 2
        elif two == "--":
            while i < n and text[i] != "\n":
                out.append(" "); i += 1
        elif text[i] == '"':
            out.append('"'); i += 1
            while i < n and text[i] != '"':
                if text[i] == "\\" and i + 1 < n:
                    out.append("  "); i += 2; continue
                out.append("\n" if text[i] == "\n" else " "); i += 1
            if i < n:
                out.append('"'); i += 1
        else:
            out.append(text[i]); i += 1
    return "".join(out)


def scan_file(path: str):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            raw = f.read()
    except OSError as e:
        return [{"file": path, "line": 0, "severity": INFO, "category": "IO", "message": str(e), "text": ""}]
    code_lines = strip_comments(raw).splitlines()
    raw_lines = raw.splitlines()
    hits = []
    for idx, line in enumerate(code_lines):
        for sev, cat, rx, msg in COMPILED:
            if rx.search(line):
                hits.append({"file": path, "line": idx + 1, "severity": sev, "category": cat,
                             "message": msg, "text": raw_lines[idx].strip()[:160]})
        for m in SET_OPTION.finditer(line):
            if not BENIGN_OPTIONS.match(m.group(1)):
                hits.append({"file": path, "line": idx + 1, "severity": MEDIUM, "category": "MEANING",
                             "message": f"set_option {m.group(1)} {m.group(2)}: non-routine option; confirm it does not weaken checking or change elaboration",
                             "text": raw_lines[idx].strip()[:160]})
    return hits


def lean_files(paths):
    for p in paths:
        if os.path.isfile(p):
            yield p
        else:
            for root, dirs, files in os.walk(p):
                dirs[:] = [d for d in dirs if d not in (".lake", ".git", "build", "node_modules")]
                for f in sorted(files):
                    if f.endswith(".lean"):
                        yield os.path.join(root, f)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("paths", nargs="+")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--min", choices=[HIGH, MEDIUM, LOW, INFO], default=INFO, help="lowest severity to show")
    args = ap.parse_args()

    hits = []
    nfiles = 0
    for f in lean_files(args.paths):
        nfiles += 1
        hits.extend(scan_file(f))
    hits = [h for h in hits if ORDER[h["severity"]] <= ORDER[args.min]]
    hits.sort(key=lambda h: (ORDER[h["severity"]], h["file"], h["line"]))

    if args.json:
        print(json.dumps({"files_scanned": nfiles, "leads": hits}, indent=1))
    else:
        print(f"scanned {nfiles} file(s); {len(hits)} lead(s). Leads are places to read, not verdicts.")
        last = None
        for h in hits:
            if h["severity"] != last:
                print(f"\n[{h['severity'].upper()}]")
                last = h["severity"]
            print(f"  {h['file']}:{h['line']}: {h['category']}: {h['message']}")
            print(f"      > {h['text']}")
        if not hits:
            print("No leads. This does NOT establish that the specifications are meaningful: "
                  "vacuous hypotheses and weak postconditions are invisible to pattern matching.")
    return 1 if any(h["severity"] == HIGH for h in hits) else 0


if __name__ == "__main__":
    sys.exit(main())
