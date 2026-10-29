#!/usr/bin/env bash
# Reproduce the Arduino UNO tutorial toolchain from scratch.
# Idempotent: safe to re-run, no interactive prompts.
set -euo pipefail

ARDUINO_CLI_VERSION="1.5.1"
ARDUINO_CLI_SHA256="28a8e119c498a25607821c36cb2dc49e8463941b261a0d99091baa7bc692dd2b"
TYPST_VERSION="0.15.1"
TYPST_SHA256="a6d077d0a95eed5a2eba715b2dae06be954f624ccbf85758a03f389ded33118c"
AVR_CORE_VERSION="1.8.8"
# ESP32 core: nur für Zusatzkapitel nötig (Kamera/Farberkennung).
# 2.0.17 is the last 2.x known to carry the esp32-camera API the kit code
# expects; 3.x changes the camera/face APIs and is intentionally not pinned.
ESP32_CORE_VERSION="2.0.17"
ESP32_BOARD_URL="https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json"

# Requested libraries, plus their mandatory dependencies (pinned so the
# resolved set is reproducible).
# FastLED bleibt auf 3.9.15: 3.10.x kollidiert mit Servo
# ("multiple definition of __vector_11").
LIBS=(
  "FastLED@3.9.15"
  "IRremote@4.7.1"
  "Servo@1.2.2"
  "Adafruit MPU6050@2.2.9"
  "Adafruit Unified Sensor@1.1.15"
  "Adafruit BusIO@1.17.4"
  "Adafruit GFX Library@1.13.0"
  "Adafruit SSD1306@2.5.17"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNO_ROOT="$(dirname "$SCRIPT_DIR")"
FONT_DIR="$UNO_ROOT/tutorial/assets/fonts"
VERSIONS_FILE="$SCRIPT_DIR/VERSIONS.txt"

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
else
  SUDO=(sudo)
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/uno-setup.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

log() { printf '[setup] %s\n' "$*"; }
die() { printf '[setup] ERROR: %s\n' "$*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "missing command: $1"; }
need curl
need tar
need unzip
need install

fetch_verify() { # url dest sha256
  local url="$1" dest="$2" want="$3" got
  curl -fsSL -o "$dest" "$url"
  got="$(sha256sum "$dest" | cut -d' ' -f1)"
  [[ "$got" == "$want" ]] || die "checksum mismatch for $url: got $got want $want"
}

install_arduino_cli() {
  if command -v arduino-cli >/dev/null 2>&1 \
     && arduino-cli version 2>/dev/null | grep -q "Version: ${ARDUINO_CLI_VERSION}"; then
    log "arduino-cli ${ARDUINO_CLI_VERSION} already installed"
    return
  fi
  local url="https://github.com/arduino/arduino-cli/releases/download/v${ARDUINO_CLI_VERSION}/arduino-cli_${ARDUINO_CLI_VERSION}_Linux_64bit.tar.gz"
  log "downloading arduino-cli ${ARDUINO_CLI_VERSION}"
  fetch_verify "$url" "$TMP_DIR/arduino-cli.tar.gz" "$ARDUINO_CLI_SHA256"
  tar -xzf "$TMP_DIR/arduino-cli.tar.gz" -C "$TMP_DIR" arduino-cli
  "${SUDO[@]}" install -m 0755 "$TMP_DIR/arduino-cli" /usr/local/bin/arduino-cli
}

install_esp32_core() {
  # ESP32 core: nur für Zusatzkapitel nötig. Idempotent: the board-manager URL
  # is only added once and an already installed version is left alone.
  local urls
  urls="$(arduino-cli config get board_manager.additional_urls 2>/dev/null || true)"
  if ! grep -qF "$ESP32_BOARD_URL" <<<"$urls"; then
    log "registering ESP32 board manager URL"
    arduino-cli config add board_manager.additional_urls "$ESP32_BOARD_URL"
    arduino-cli core update-index
  fi
  if arduino-cli core list --format json \
       | jq -e --arg id "esp32:esp32" --arg v "$ESP32_CORE_VERSION" \
         '.platforms[] | select(.id==$id and .installed_version==$v)' >/dev/null; then
    log "esp32:esp32 ${ESP32_CORE_VERSION} already installed"
    return
  fi
  log "installing esp32:esp32 ${ESP32_CORE_VERSION}"
  # esptool (bundled) needs pyserial; provide it on a bare machine.
  python3 -c 'import serial' >/dev/null 2>&1 \
    || "${SUDO[@]}" apt-get install -y python3-serial >/dev/null
  arduino-cli core install "esp32:esp32@${ESP32_CORE_VERSION}"
}

install_typst() {
  if command -v typst >/dev/null 2>&1 \
     && typst --version 2>/dev/null | grep -q "typst ${TYPST_VERSION}"; then
    log "typst ${TYPST_VERSION} already installed"
    return
  fi
  local url="https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz"
  log "downloading typst ${TYPST_VERSION}"
  fetch_verify "$url" "$TMP_DIR/typst.tar.xz" "$TYPST_SHA256"
  tar -xJf "$TMP_DIR/typst.tar.xz" -C "$TMP_DIR"
  "${SUDO[@]}" install -m 0755 \
    "$TMP_DIR/typst-x86_64-unknown-linux-musl/typst" /usr/local/bin/typst
}

install_fonts() {
  mkdir -p "$FONT_DIR"
  local base="https://raw.githubusercontent.com/google/fonts/main/ofl/atkinsonhyperlegible"
  local f
  for f in \
    "AtkinsonHyperlegible-Regular.ttf:7fb917c89019896d0b52ee84b7cbb3304c18cb90b19a62f5e32712bd23e97669" \
    "AtkinsonHyperlegible-Bold.ttf:5a3b0c8cc8ca545155150b4512a1fa248298df121c50d6557e651e61fbdab92f" \
    "AtkinsonHyperlegible-Italic.ttf:021beda4d3c6edfc78872e436d74009f9a1bcb294331908fe5747c61d3dcc514" \
    "AtkinsonHyperlegible-BoldItalic.ttf:7a46f1b0ef2f64b61065c1a6b5a11fcb9b019b44062d88ba121a083cc39e86bf"; do
    local name="${f%%:*}" sha="${f##*:}"
    log "font $name"
    fetch_verify "$base/$name" "$FONT_DIR/$name" "$sha"
  done

  log "font JetBrains Mono Regular/Bold"
  fetch_verify \
    "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip" \
    "$TMP_DIR/jetbrainsmono.zip" \
    "6f6376c6ed2960ea8a963cd7387ec9d76e3f629125bc33d1fdcd7eb7012f7bbf"
  local jb
  for jb in Regular Bold; do
    unzip -p "$TMP_DIR/jetbrainsmono.zip" "fonts/ttf/JetBrainsMono-${jb}.ttf" \
      > "$FONT_DIR/JetBrainsMono-${jb}.ttf"
  done
  unzip -p "$TMP_DIR/jetbrainsmono.zip" OFL.txt > "$FONT_DIR/OFL-JetBrainsMono.txt"
  fetch_verify "$base/OFL.txt" "$FONT_DIR/OFL-AtkinsonHyperlegible.txt" \
    "f32d22b3908fcad2c86a74000614ec22e6a7f66ea7e867e616026a27aebdc143"

  local families
  families="$(typst fonts --font-path "$FONT_DIR")"
  grep -qx "Atkinson Hyperlegible" <<<"$families" \
    || die "font family 'Atkinson Hyperlegible' not found by typst"
  grep -qx "JetBrains Mono" <<<"$families" \
    || die "font family 'JetBrains Mono' not found by typst"
  log "typst sees both font families"
}

write_versions() {
  local core_version esp32_version libs
  core_version="$(arduino-cli core list --format json \
    | jq -r '.platforms[] | select(.id=="arduino:avr") | .installed_version')"
  esp32_version="$(arduino-cli core list --format json \
    | jq -r '.platforms[] | select(.id=="esp32:esp32") | .installed_version')"
  libs="$(arduino-cli lib list --format json \
    | jq -r '.installed_libraries[] | "\(.library.name) \(.library.version)"' \
    | sort)"

  {
    printf '# Resolved toolchain versions (generated by tools/setup.sh)\n'
    printf 'generated_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'arduino-cli=%s\n' "$(arduino-cli version | sed -E 's/.*Version: ([^ ]+).*/\1/')"
    printf 'core_arduino_avr=%s\n' "$core_version"
    printf 'core_esp32_esp32=%s  # nur für Zusatzkapitel nötig\n' "${esp32_version:-not-installed}"
    printf 'typst=%s\n' "$(typst --version | awk '{print $2}')"
    printf '\n[libraries]\n%s\n' "$libs"
    printf '\n[fonts]\n'
    printf 'family=Atkinson Hyperlegible files=AtkinsonHyperlegible-{Regular,Bold,Italic,BoldItalic}.ttf license=OFL-AtkinsonHyperlegible.txt\n'
    printf 'family=JetBrains Mono files=JetBrainsMono-{Regular,Bold}.ttf license=OFL-JetBrainsMono.txt\n'
    printf 'font_dir=%s\n' "$FONT_DIR"
  } > "$VERSIONS_FILE"
  log "wrote $VERSIONS_FILE"
}

need jq
install_arduino_cli
install_typst
install_fonts

# Arduino core and libraries. Config init is intentionally overwritten so the
# script works on a blank machine.
arduino-cli config init --overwrite >/dev/null
arduino-cli core update-index
arduino-cli core install "arduino:avr@${AVR_CORE_VERSION}"
install_esp32_core
for lib in "${LIBS[@]}"; do
  arduino-cli lib install "$lib"
done

write_versions
log "done: arduino-cli $(arduino-cli version | sed -E 's/.*Version: ([^ ]+).*/\1/'), typst $(typst --version | awk '{print $2}')"
