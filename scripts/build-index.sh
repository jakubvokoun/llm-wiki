#!/usr/bin/env bash
# Additive, non-destructive index.md sync.
# Curated summaries and the entity Type column are NOT in frontmatter, so this
# never rewrites existing rows. It only finds pages absent from index.md and
# (with --fix) appends stub rows for them, leaving TODO placeholders to fill in.
#
# Usage:
#   ./scripts/build-index.sh         # report missing pages + dead rows
#   ./scripts/build-index.sh --fix   # also append stub rows into index.md
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$ROOT/wiki"
INDEX="$WIKI/index.md"
FIX=0
[ "${1:-}" = "--fix" ] && FIX=1

STUBDIR="$(mktemp -d)"
trap 'rm -rf "$STUBDIR"' EXIT
: >"$STUBDIR/Sources" >"$STUBDIR/Entities" >"$STUBDIR/Concepts" >"$STUBDIR/Analyses"

# Frontmatter helpers
fm_title() { sed -n '2,/^---$/p' "$1" | sed -nE 's/^title:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/p' | head -1; }
fm_updated() { sed -n '2,/^---$/p' "$1" | sed -nE 's/^updated:[[:space:]]*(.*)$/\1/p' | head -1; }

# Resolved set of pages already linked from index.md
indexed="$(mktemp)"
grep -oE '\]\([^)]+\.md[^)#]*' "$INDEX" | sed -E 's/^\]\(//' | while IFS= read -r l; do
	realpath -m "$WIKI/$l"
done | sort -u >"$indexed"

missing=0
declare -A SECTION=([sources]=Sources [entities]=Entities [concepts]=Concepts [analyses]=Analyses)
for dir in sources entities concepts analyses; do
	sec="${SECTION[$dir]}"
	for f in "$WIKI/$dir"/*.md; do
		[ -e "$f" ] || continue
		abs="$(realpath -m "$f")"
		grep -qxF "$abs" "$indexed" && continue
		missing=$((missing + 1))
		base="$(basename "$f")"
		title="$(fm_title "$f")"
		[ -n "$title" ] || title="$base"
		updated="$(fm_updated "$f")"
		case "$dir" in
		sources) row="| [$title]($dir/$base) | TODO summary | $updated |" ;;
		entities) row="| [$title]($dir/$base) | TODO type | TODO summary |" ;;
		concepts) row="| [$title]($dir/$base) | TODO summary |" ;;
		analyses) row="| [$title]($dir/$base) | TODO summary | $updated |" ;;
		esac
		echo "$row" >>"$STUBDIR/$sec"
		echo "MISSING [$sec] $dir/$base"
	done
done

# Dead rows: index links pointing at files that no longer exist
dead=0
grep -oE '\]\([^)]+\.md[^)#]*' "$INDEX" | sed -E 's/^\]\(//' | while IFS= read -r l; do
	[ -f "$WIKI/$l" ] || echo "DEAD-ROW $l"
done | sort -u | while IFS= read -r line; do echo "$line"; done

rm -f "$indexed"

if [ "$missing" -eq 0 ]; then
	echo "index.md is in sync (no missing pages)."
fi

if [ "$FIX" -eq 1 ] && [ "$missing" -gt 0 ]; then
	awk -v stubdir="$STUBDIR" '
		function flush(sec,   file,line) {
			if (sec == "") return
			file = stubdir "/" sec
			while ((getline line < file) > 0) print line
			close(file)
		}
		/^## (Sources|Entities|Concepts|Analyses)$/ { cur = substr($0, 4); intable = 0; print; next }
		(cur != "" && $0 ~ /^\|/) { intable = 1; print; next }
		(cur != "" && intable == 1 && $0 !~ /^\|/) { flush(cur); cur = ""; intable = 0; print; next }
		{ print }
		END { if (cur != "" && intable == 1) flush(cur) }
	' "$INDEX" >"$INDEX.tmp"
	mv "$INDEX.tmp" "$INDEX"
	echo "Appended $missing stub row(s) to index.md. Fill in TODO fields, then run prettier."
elif [ "$missing" -gt 0 ]; then
	echo
	echo "Run with --fix to append the $missing stub row(s) above."
fi
