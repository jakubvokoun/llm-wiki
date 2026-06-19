#!/usr/bin/env bash
# Deterministic wiki health checks. Complements the judgement-based /lint pass.
# Usage: ./scripts/lint.sh
#   Reports: broken relative links, orphan pages, index drift, missing
#   frontmatter, and raw/ provenance coverage.
#   Exit code: 1 if hard issues (broken links / missing-from-index) found, else 0.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$ROOT/wiki"
RAW="$ROOT/raw"

TMP="$(mktemp)"
trap 'rm -f "$TMP" "$INBOUND" "$IDX"' EXIT
INBOUND="$(mktemp)"
IDX="$(mktemp)"

# Extract resolved (absolute, anchor-stripped) .md link targets from a file.
# Emits one absolute path per internal link; skips http(s) and pure anchors.
link_targets() {
	local f="$1" dir link
	dir="$(dirname "$f")"
	{ grep -oE '\]\([^)]+\.md[^)#]*' "$f" 2>/dev/null || true; } | sed -E 's/^\]\(//' | while IFS= read -r link; do
		case "$link" in http*) continue ;; esac
		realpath -m "$dir/$link"
	done
}

content_pages() {
	find "$WIKI"/{sources,entities,concepts,analyses} -name '*.md' 2>/dev/null
}

# --- Check 1: broken relative links (any wiki .md, including index/log) ---
while IFS= read -r f; do
	dir="$(dirname "$f")"
	{ grep -oE '\]\([^)]+\.md[^)#]*' "$f" 2>/dev/null || true; } | sed -E 's/^\]\(//' | while IFS= read -r link; do
		case "$link" in http*) continue ;; esac
		[ -f "$dir/$link" ] || echo "broken-link|${f#"$ROOT"/}|$link"
	done
done < <(find "$WIKI" -name '*.md') >>"$TMP"

# --- Check 2: orphan pages (no inbound link from any other content page) ---
# index.md/log.md are excluded as sources: index links everything by design.
while IFS= read -r f; do
	link_targets "$f"
done < <(content_pages) | sort -u >"$INBOUND"

while IFS= read -r f; do
	abs="$(realpath -m "$f")"
	grep -qxF "$abs" "$INBOUND" || echo "orphan|${f#"$ROOT"/}|no inbound links from other pages"
done < <(content_pages) >>"$TMP"

# --- Check 3: index drift (content page not linked from index.md) ---
link_targets "$WIKI/index.md" | sort -u >"$IDX"
while IFS= read -r f; do
	abs="$(realpath -m "$f")"
	grep -qxF "$abs" "$IDX" || echo "missing-from-index|${f#"$ROOT"/}|not listed in index.md"
done < <(content_pages) >>"$TMP"

# --- Check 4: required frontmatter keys on content pages ---
while IFS= read -r f; do
	[ "$(head -1 "$f")" = "---" ] || {
		echo "no-frontmatter|${f#"$ROOT"/}|missing YAML frontmatter"
		continue
	}
	fm="$(sed -n '2,/^---$/p' "$f")"
	for key in title tags sources updated; do
		grep -qE "^${key}:" <<<"$fm" || echo "frontmatter-key|${f#"$ROOT"/}|missing '$key:'"
	done
done < <(content_pages) >>"$TMP"

# --- Report ---
print_group() {
	local cat="$1" label="$2" n
	n="$(grep -c "^$cat|" "$TMP" || true)"
	[ "$n" -eq 0 ] && return
	echo
	echo "## $label ($n)"
	grep "^$cat|" "$TMP" | while IFS='|' read -r _ file detail; do
		echo "  - $file: $detail"
	done
}

print_group broken-link "Broken links"
print_group missing-from-index "Missing from index"
print_group orphan "Orphan pages"
print_group no-frontmatter "Missing frontmatter"
print_group frontmatter-key "Incomplete frontmatter"

# --- raw/ provenance coverage (summary only; backfill is gradual) ---
raw_total="$(find "$RAW" -maxdepth 1 -name '*.md' | wc -l)"
raw_missing=0
while IFS= read -r f; do
	[ "$(head -1 "$f")" = "---" ] || raw_missing=$((raw_missing + 1))
done < <(find "$RAW" -maxdepth 1 -name '*.md')
echo
echo "## raw/ provenance"
echo "  $((raw_total - raw_missing))/$raw_total files have source_url/fetched frontmatter"

# --- Summary / exit ---
hard="$(grep -cE '^(broken-link|missing-from-index)\|' "$TMP" || true)"
echo
if [ "$hard" -gt 0 ]; then
	echo "FAIL: $hard hard issue(s) (broken links / index drift)."
	exit 1
fi
echo "OK: no broken links or index drift."
