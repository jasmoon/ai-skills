#!/usr/bin/env bash
#
# Check that CLAUDE.global.md is a subset of the personal global instructions.
#
# The template holds a header, a "---" marker, and then the text that a reader
# copies into their global instructions. Every rule below the marker must also
# appear, word for word, in the global file.
#
# Usage: bash check-global-subset.sh [template] [global]
#
# Exit codes:
#   0  every line below the marker is present in the global file
#   1  at least one line is missing; the script names each one
#   2  a file is missing, the marker is absent, or there is nothing to check

set -u

TEMPLATE="${1:-CLAUDE.global.md}"
GLOBAL="${2:-$HOME/.claude/CLAUDE.md}"

for f in "$TEMPLATE" "$GLOBAL"; do
  if [ ! -f "$f" ]; then
    printf 'not found: %s\n' "$f" >&2
    exit 2
  fi
done

# Without the marker the loop below reads nothing and the check passes for the
# wrong reason. Stop instead.
if ! tr -d '\r' < "$TEMPLATE" | grep -qx -- '---'; then
  printf 'no --- marker in %s\n' "$TEMPLATE" >&2
  exit 2
fi

normalised=$(mktemp)
trap 'rm -f "$normalised"' EXIT
tr -d '\r' < "$GLOBAL" > "$normalised"

checked=0
missing=0
while IFS= read -r line; do
  # Blank lines carry no rule. Headings differ in level between the two files.
  case "$line" in
    "" | "#"*) continue ;;
  esac
  checked=$((checked + 1))
  if ! grep -Fqx -- "$line" "$normalised"; then
    missing=$((missing + 1))
    printf 'MISSING: %s\n' "$line"
  fi
done < <(sed -n '/^---$/,$p' "$TEMPLATE" | tr -d '\r' | tail -n +2)

if [ "$checked" -eq 0 ]; then
  printf 'nothing below the marker in %s\n' "$TEMPLATE" >&2
  exit 2
fi

printf 'checked %d lines, %d missing\n' "$checked" "$missing"
[ "$missing" -eq 0 ]
