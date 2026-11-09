#!/usr/bin/env bash
# Builds the standalone Netlify version of the landing page into ./site
# Usage: bash build-site.sh [https://your-site.netlify.app]
set -euo pipefail
cd "$(dirname "$0")"

SITE_URL="${1:-}"
SRC="index.html"
OUT="site"

rm -rf "$OUT"
mkdir -p "$OUT/photos"

# Copy only the photos the page uses
grep -oE 'photos/[A-Za-z0-9._-]*\.(jpe?g|png|webp)' "$SRC" | sort -u | while read -r p; do cp "$p" "$OUT/$p"; done

TITLE="كورال نساء تنجيس · حفل 12 دجنبر 2026"
DESC="حفل موسيقي لكورال نساء تنجيس بقيادة المايسترا زكية يخلف، يوم السبت 12 دجنبر 2026 بقصر الفنون والثقافة بطنجة."

OG_EXTRA=""
if [ -n "$SITE_URL" ]; then
  OG_EXTRA="<meta property=\"og:url\" content=\"$SITE_URL/\">
<meta property=\"og:image\" content=\"$SITE_URL/photos/concert-06.jpg\">
<meta property=\"og:image:width\" content=\"1080\">
<meta property=\"og:image:height\" content=\"608\">
<meta name=\"twitter:card\" content=\"summary_large_image\">"
fi

{
  cat <<EOF
<!doctype html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="description" content="$DESC">
<meta property="og:type" content="website">
<meta property="og:locale" content="ar_MA">
<meta property="og:title" content="$TITLE">
<meta property="og:description" content="$DESC">
$OG_EXTRA
<style>
/* Base reset the Artifact viewer normally provides */
:root { padding-top: env(safe-area-inset-top, 0px); padding-bottom: env(safe-area-inset-bottom, 0px); }
body { margin: 0; }
img { max-width: 100%; }
[hidden] { display: none !important; }
</style>
EOF
  # Head part of the source: everything up to and including </style>
  sed -n '1,/^<\/style>$/p' "$SRC"
  echo "</head>"
  echo "<body>"
  # Body part, with the share link pointing at the live site instead of the artifact
  sed -n '/^<\/style>$/,$p' "$SRC" | tail -n +2 \
    | sed "s|^const PAGE_URL  = .*|const PAGE_URL  = \"${SITE_URL:+$SITE_URL/}\"; // public link to this page (empty = current address)|"
  echo "</body>"
  echo "</html>"
} > "$OUT/index.html"

echo "Built $OUT/ ($(find "$OUT" -type f | wc -l) files)"
