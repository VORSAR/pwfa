#!/usr/bin/env python3
"""What changed in Lean since the lean-verify snapshot?

    python3 whats_new.py --from 36 --to 38          # minors 4.37 and 4.38
    python3 whats_new.py --from 36                  # everything newer that exists
    python3 whats_new.py --from 33 --to 36 --all    # also list every verification-related line

Reads the release notes straight from the reference manual's source on GitHub
(leanprover/reference-manual, Manual/Releases/v4_N_0.lean) and prints, per release:
the Highlights headings, the Breaking Changes section, and (with --all) every entry
that mentions the verification surface. It needs network access to
raw.githubusercontent.com. Nothing is cached; rerun whenever the toolchain moves.

Treat the output as leads. The compiler in the project's toolchain is the authority.
"""
import argparse
import re
import sys
import urllib.error
import urllib.request

RAW = "https://raw.githubusercontent.com/leanprover/reference-manual/main/Manual/Releases/v4_{n}_0.lean"
KEYWORDS = re.compile(
    r"vcgen|mvcgen|Std\.WP|Std\.Do|contract|requires|ensures|invariant|\bgrind\b|bv_decide|"
    r"\bcbv\b|deprecat|lake check|comparator|leanchecker|axiom|native|\bsym\b|Sym\.|lean-beam|"
    r"module system|linter",
    re.IGNORECASE,
)


def fetch(n: int):
    url = RAW.format(n=n)
    try:
        with urllib.request.urlopen(url, timeout=30) as r:
            return r.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def clean(line: str) -> str:
    # Strip the Verso markup that makes raw notes hard to read.
    line = re.sub(r"\{[a-zA-Z]+(?: [^}]*)?\}`([^`]*)`", r"`\1`", line)   # {tactic}`x` -> `x`
    line = re.sub(r"\{ref \"[^\"]*\"\}\[([^\]]*)\]", r"\1", line)        # {ref "t"}[text] -> text
    line = re.sub(r"\[#(\d+)\]\([^)]*\)", r"#\1", line)                  # [#123](url) -> #123
    return line.rstrip()


def sections(text: str):
    """Yield (level, title, body_lines) for each markdown-style heading."""
    cur, body = None, []
    for raw in text.splitlines():
        m = re.match(r"^(#+)\s+(.*)$", raw)
        if m:
            if cur:
                yield cur[0], cur[1], body
            cur, body = (len(m.group(1)), m.group(2).strip()), []
        elif cur:
            body.append(raw)
    if cur:
        yield cur[0], cur[1], body


def report(n: int, text: str, show_all: bool) -> None:
    title = re.search(r'#doc \(Manual\) "([^"]+)"', text)
    print(f"\n=== {title.group(1) if title else f'Lean 4.{n}.0'} ===")
    in_highlights = False
    printed = False
    for level, name, body in sections(text):
        if level == 1:
            in_highlights = name.lower().startswith("highlight")
            continue
        if in_highlights and level == 2:
            printed = True
            if name.lower().startswith("breaking"):
                print("  BREAKING CHANGES:")
                for b in body:
                    b = clean(b)
                    if b.strip():
                        print("    " + b.strip()[:400])
            else:
                first = next((clean(b).strip() for b in body if b.strip() and not b.startswith((":::", "```", "%%%"))), "")
                print(f"  * {clean(name)}")
                if first:
                    print(f"      {first[:300]}")
    if not printed and not show_all:
        print("  (no Highlights section yet: release candidates often lack one; rerun with --all)")
    if show_all:
        print("  VERIFICATION-RELATED ENTRIES:")
        lines = text.splitlines()
        for i, raw in enumerate(lines):
            if raw.lstrip().startswith("- [#") and i + 1 < len(lines):
                entry = clean(raw.strip() + " " + lines[i + 1].strip())
                if KEYWORDS.search(entry):
                    print("    " + entry[:320])


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--from", dest="start", type=int, required=True,
                    help="snapshot minor version (exclusive), e.g. 36 for Lean 4.36")
    ap.add_argument("--to", dest="end", type=int, default=None,
                    help="last minor version to report (inclusive); default: keep going until a release is missing")
    ap.add_argument("--all", action="store_true", help="also list every entry touching the verification surface")
    args = ap.parse_args()

    n, found = args.start + 1, 0
    while args.end is None or n <= args.end:
        try:
            text = fetch(n)
        except Exception as e:  # network down, proxy, etc.
            print(f"could not fetch notes for 4.{n}: {e}", file=sys.stderr)
            return 2
        if text is None:
            if args.end is not None:
                print(f"\n=== Lean 4.{n}.0: no release notes published yet ===")
            else:
                break
        else:
            report(n, text, args.all)
            found += 1
        n += 1
    if found == 0:
        print(f"No release notes newer than 4.{args.start} were found. The snapshot is current.")
    else:
        print("\nNext: re-verify anything above that touches code you are about to write, "
              "by compiling a small probe in the project's toolchain.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
