#!/usr/bin/env bash
# Reformat wiki pages matching a date pattern with prose-wrap never.
# Usage: ./scripts/reformat-today.sh [date]  (default: today)
set -euo pipefail

DATE="${1:-$(date +%Y-%m-%d)}"
WIKI_DIR="$(cd "$(dirname "$0")/.." && pwd)/wiki"

mapfile -t files < <(grep -rl "updated: ${DATE}" "$WIKI_DIR")

if [[ ${#files[@]} -eq 0 ]]; then
	echo "No pages with updated: ${DATE}" >&2
	exit 0
fi

echo "Reformatting ${#files[@]} pages (prose-wrap never)..."
nix-shell "$(dirname "$0")/../shell.nix" --run "prettier --prose-wrap never --write $(printf '"%s" ' "${files[@]}")"
echo "Done."
