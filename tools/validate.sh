#!/usr/bin/env bash
# Compile every solution sketch (inside a *_solution* folder) under code/ and
# every exercise sketch (inside a *_exercise* folder) that is complete enough to
# build. Write a build report. ESP32 examples use the ESP32 board, all others the
# Arduino Uno. Exercises that intentionally do not build are listed in
# SKIP_EXERCISES with a reason.
# Sketches are never modified: each build uses a temp build dir.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNO_ROOT="$(dirname "$SCRIPT_DIR")"
CODE_DIR="$UNO_ROOT/code"
DIST_DIR="$UNO_ROOT/dist"
LOG_DIR="$DIST_DIR/build-logs"
REPORT="$DIST_DIR/build-report.md"
UNO_FQBN="arduino:avr:uno"
ESP32_FQBN="esp32:esp32:esp32:PartitionScheme=huge_app,PSRAM=enabled"

# Exercise folders that are intentionally incomplete and therefore do not
# compile. Each entry is the path relative to code/.
SKIP_EXERCISES=(
  # Gap skeleton: SECRET/step are filled in by the learner, so the file does
  # not declare them and cannot build before the exercise is solved.
  "121_secret_code/121_secret_code_exercise"
)

command -v arduino-cli >/dev/null 2>&1 || {
  printf 'ERROR: arduino-cli not found on PATH (run tools/setup.sh)\n' >&2
  exit 2
}

rm -rf "$LOG_DIR"
mkdir -p "$LOG_DIR"
BUILD_BASE="$(mktemp -d "${TMPDIR:-/tmp}/uno-build.XXXXXX")"
TMP_REPORT="$(mktemp "${TMPDIR:-/tmp}/uno-report.XXXXXX")"
trap 'rm -rf "$BUILD_BASE" "$TMP_REPORT"' EXIT

failed=0
total=0
compiled=0
skipped=0

printf '| Sketch | Kind | Board | Status | Flash bytes | Flash %% | RAM bytes | RAM %% | Warnings |\n' > "$TMP_REPORT"
printf '|---|---|---|---|---:|---:|---:|---:|---:|\n' >> "$TMP_REPORT"

is_skipped() {
  local rel="$1" entry
  rel="${rel#code/}"
  for entry in "${SKIP_EXERCISES[@]}"; do
    [[ "$rel" == "$entry" ]] && return 0
  done
  return 1
}

compile_sketch() {
  local dir="$1" kind="$2"
  local rel="${dir#"$UNO_ROOT"/}"
  local example
  example="$(basename "$(dirname "$dir")")"

  local safe="${rel//\//__}"
  local log="$LOG_DIR/${safe}.log"
  local build="$BUILD_BASE/$safe"
  local board fqbn status flash_bytes flash_pct ram_bytes ram_pct warnings flash ram

  total=$((total + 1))

  if [[ "$kind" == "exercise" ]] && is_skipped "$rel"; then
    status="SKIP"
    skipped=$((skipped + 1))
    printf '[validate] skipping %s (intentionally incomplete)\n' "$rel"
    printf '| %s | %s | - | %s | - | - | - | - | - |\n' \
      "$example" "$kind" "$status" >> "$TMP_REPORT"
    return
  fi

  mkdir -p "$build"
  if [[ "$rel" == *esp32* ]]; then
    board="esp32"
    fqbn="$ESP32_FQBN"
  else
    board="uno"
    fqbn="$UNO_FQBN"
  fi

  compiled=$((compiled + 1))
  printf '[validate] compiling %s (%s, %s)\n' "$rel" "$kind" "$board"
  if arduino-cli compile --fqbn "$fqbn" --warnings all --no-color \
      --build-path "$build" "$dir" >"$log" 2>&1; then
    status="PASS"
  else
    status="FAIL"
    failed=$((failed + 1))
  fi

  flash_bytes="-" flash_pct="-" ram_bytes="-" ram_pct="-"
  if [[ -f "$log" ]]; then
    flash="$(grep -oE 'Sketch uses [0-9]+ bytes \([0-9]+%\)' "$log" | tail -n1 || true)"
    ram="$(grep -oE 'Global variables use [0-9]+ bytes \([0-9]+%\)' "$log" | tail -n1 || true)"
    if [[ -n "$flash" ]]; then
      flash_bytes="$(sed -E 's/.*uses ([0-9]+) bytes.*/\1/' <<<"$flash")"
      flash_pct="$(sed -E 's/.*\(([0-9]+)%\).*/\1/' <<<"$flash")"
    fi
    if [[ -n "$ram" ]]; then
      ram_bytes="$(sed -E 's/.*use ([0-9]+) bytes.*/\1/' <<<"$ram")"
      ram_pct="$(sed -E 's/.*\(([0-9]+)%\).*/\1/' <<<"$ram")"
    fi
  fi
  warnings="$(grep -c 'warning:' "$log" 2>/dev/null || true)"
  warnings="${warnings:-0}"

  printf '| %s | %s | %s | %s | %s | %s | %s | %s | %s |\n' \
    "$example" "$kind" "$board" "$status" "$flash_bytes" "$flash_pct" \
    "$ram_bytes" "$ram_pct" "$warnings" >> "$TMP_REPORT"
}

if [[ -d "$CODE_DIR" ]]; then
  while IFS= read -r -d '' dir; do
    compile_sketch "$dir" "solution"
  done < <(find "$CODE_DIR" -type f -name '*.ino' -path '*_solution*' -printf '%h\0' | sort -zu)

  while IFS= read -r -d '' dir; do
    compile_sketch "$dir" "exercise"
  done < <(find "$CODE_DIR" -type f -name '*.ino' -path '*_exercise*' -printf '%h\0' | sort -zu)
fi

if [[ "$total" -eq 0 ]]; then
  printf '\n_No sketches found under %s._\n' "$CODE_DIR" >> "$TMP_REPORT"
fi

mv "$TMP_REPORT" "$REPORT"
printf '[validate] %d sketch(es), %d compiled, %d failed, %d skipped; report: %s\n' \
  "$total" "$compiled" "$failed" "$skipped" "$REPORT"

[[ "$failed" -eq 0 ]] || exit 1
