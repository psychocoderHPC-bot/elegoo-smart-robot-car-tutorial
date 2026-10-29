#!/usr/bin/env bash
# Render the tutorial PDF with the bundled fonts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNO_ROOT="$(dirname "$SCRIPT_DIR")"
MAIN="$UNO_ROOT/tutorial/main.typ"
FONT_DIR="$UNO_ROOT/tutorial/assets/fonts"
OUT_DIR="$UNO_ROOT/dist"
OUT="$OUT_DIR/Elegoo-Smart-Robot-Car-Tutorial.pdf"

if [[ ! -f "$MAIN" ]]; then
  printf 'ERROR: tutorial source not found: %s\n' "$MAIN" >&2
  exit 1
fi
if [[ ! -d "$FONT_DIR" ]]; then
  printf 'ERROR: font directory not found: %s (run tools/setup.sh)\n' "$FONT_DIR" >&2
  exit 1
fi
command -v typst >/dev/null 2>&1 || {
  printf 'ERROR: typst not found on PATH (run tools/setup.sh)\n' >&2
  exit 2
}

mkdir -p "$OUT_DIR"
printf '[render] %s -> %s\n' "$MAIN" "$OUT"
typst compile --root "$UNO_ROOT" --font-path "$FONT_DIR" "$MAIN" "$OUT"
printf '[render] wrote %s\n' "$OUT"
