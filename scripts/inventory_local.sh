#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$HOME/Documents/GitHub}"
OUT="docs/migration/local_repos.csv"
mkdir -p "$(dirname "$OUT")"
echo "name,path,remote" > "$OUT"
shopt -s nullglob
for gitdir in "$ROOT"/*/.git; do
  repo="$(basename "$(dirname "$gitdir")")"
  path="$(dirname "$gitdir")"
  remote="$(git -C "$path" remote get-url origin 2>/dev/null || echo "")"
  echo "$repo,$path,$remote" >> "$OUT"
done
echo "Wrote $OUT"
