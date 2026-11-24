#!/usr/bin/env bash
# Run the standalone research checks described in
# [the research workflow](../CONTRIBUTING.md#lean-experiments-for-research-decisions).
set -eu
cd "$(dirname "$0")/.."
for experiment in scripts/experiments/*.lean; do
  echo "Checking $experiment"
  lake lean "$experiment" -- -DwarningAsError=true
done
