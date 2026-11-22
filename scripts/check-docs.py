#!/usr/bin/env python3
"""Validate link targets and stable document filenames without external packages."""
from pathlib import Path
from urllib.parse import unquote
import re
import sys

root = Path(__file__).resolve().parents[1]
errors = []
md_files = sorted(root.rglob("*.md"))
versioned = re.compile(r"(?:^|[-_.])v\d+\.\d+(?:\.\d+)?(?=[-_.]|$)", re.I)
link_pattern = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
for file in md_files:
    rel = file.relative_to(root)
    if versioned.search(rel.name):
        errors.append(f"{rel}: version number in document filename")
    text = file.read_text(encoding="utf-8")
    # Preserve the historical snapshot byte-for-byte; its missing newline predates this checker.
    if rel != Path("docs/history/recovery-original.md") and text and not text.endswith("\n"):
        errors.append(f"{rel}: missing final newline")
    for link in link_pattern.findall(text):
        target = link.strip().split(" ", 1)[0].strip("<>")
        if not target or target.startswith(("#", "http:", "https:", "mailto:")):
            continue
        target = unquote(target.split("#", 1)[0])
        if target and not (file.parent / target).exists():
            errors.append(f"{rel}: broken relative link -> {target}")
if errors:
    for error in errors:
        print("ERROR:", error)
    sys.exit(1)
print(f"Documentation checks passed: {len(md_files)} Markdown files")
