#!/usr/bin/env bash
# Version handshake for the lean-verify skill.
# Usage: bash lean_env.sh [project-dir]     (defaults to the current directory)
# Prints what this machine and project actually have, and compares the project's
# toolchain with the version the skill's references were compiled against.
set -u
SNAPSHOT_MINOR=36            # references/*.md were compiled against Lean 4.36.0
ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { echo "cannot cd to $ROOT"; exit 2; }

say() { printf '%-22s %s\n' "$1" "$2"; }
have() { command -v "$1" >/dev/null 2>&1; }

if [ -f lean-toolchain ]; then TC="$(tr -d '[:space:]' < lean-toolchain)"; else TC="(no lean-toolchain file here)"; fi
say "project toolchain:" "$TC"
if have lean; then
  say "lean on PATH:" "$(lean --version 2>/dev/null | head -1)"
else
  say "lean on PATH:" "NOT FOUND (install elan, or put a toolchain's bin/ on PATH)"
fi
have lake && say "lake:" "$(lake --version 2>/dev/null | head -1)"
PREFIX="$(lean --print-prefix 2>/dev/null || true)"
if [ -n "$PREFIX" ]; then
  say "toolchain prefix:" "$PREFIX"
  say "library sources:" "$PREFIX/src/lean   <- grep these: the docs for THIS version"
fi

# Tools that ship inside recent toolchains (4.35+: checkers; 4.36+: Beam on Linux/macOS).
for t in lean-beam lean-beam-mcp leanchecker lean4lean nanoda_bin con-leche con-ron cadical; do
  if [ -n "$PREFIX" ] && [ -x "$PREFIX/bin/$t" ]; then say "$t:" "bundled"
  elif have "$t"; then say "$t:" "on PATH"
  else say "$t:" "no"; fi
done
if have bwrap; then say "bwrap (sandbox):" "yes"
else say "bwrap (sandbox):" "no -> lake check / lake comparator cannot sandbox here (Linux only)"; fi

# Project shape.
[ -f lakefile.toml ] && say "lake config:" "lakefile.toml"
[ -f lakefile.lean ] && say "lake config:" "lakefile.lean"
if [ -f lake-manifest.json ]; then
  # names inside the "packages" array only (the manifest's own top-level "name" is this project)
  DEPS="$(tr -d '\n' < lake-manifest.json | sed -n 's/.*"packages" *: *\[\(.*\)\].*/\1/p' | grep -o '"name": *"[^"]*"' | sed 's/.*: *"//; s/"$//' | sort -u | tr '\n' ' ')"
  say "dependencies:" "${DEPS:-none}"
  case " $DEPS " in
    *" mathlib "*) say "mathlib:" "yes -> 'lake exe cache get' before building; Mathlib search engines apply";;
    *)             say "mathlib:" "no  -> core + Std only; web search engines mostly index Mathlib";;
  esac
fi
[ -d .lake/packages ] && say "dep sources:" ".lake/packages/   <- grep these before searching the web"
if grep -rqs '^module *$' --include='*.lean' --exclude-dir=.lake . 2>/dev/null; then
  say "module system:" "in use (files start with 'module'; mind public/private imports)"
fi

# Snapshot comparison.
MINOR="$(printf '%s' "$TC" | sed -n 's/.*v4\.\([0-9][0-9]*\)\..*/\1/p')"
echo
if [ -z "$MINOR" ]; then
  echo "VERDICT: no 4.x release version found (nightly, custom toolchain, or no lean-toolchain file)."
  echo "         Treat every syntax claim in references/ as unverified and probe with the compiler."
elif [ "$MINOR" -gt "$SNAPSHOT_MINOR" ]; then
  echo "VERDICT: project is on 4.$MINOR, NEWER than the skill snapshot (4.$SNAPSHOT_MINOR)."
  echo "         Run: python3 <skill>/scripts/whats_new.py --from $SNAPSHOT_MINOR --to $MINOR"
  echo "         Trust the compiler over references/verification.md wherever they disagree."
elif [ "$MINOR" -lt 34 ]; then
  echo "VERDICT: project is on 4.$MINOR, which predates contracts (4.34) and vcgen (4.35)."
  echo "         See the version table in references/freshness.md, or propose a toolchain bump."
elif [ "$MINOR" -lt "$SNAPSHOT_MINOR" ]; then
  echo "VERDICT: project is on 4.$MINOR, older than the snapshot (4.$SNAPSHOT_MINOR)."
  echo "         Check the version table in references/freshness.md for what is missing."
else
  echo "VERDICT: project matches the skill snapshot (4.$SNAPSHOT_MINOR). References apply as written."
  echo "         Still build before claiming anything."
fi
