# Build

Werkzeuge und Sketches des Arduino-Uno-Tutorials lokal bauen.

## Voraussetzungen

- Linux x86_64, `sudo` für die Installation nach `/usr/local/bin`
- `curl`, `tar`, `unzip`, `jq`
- `pdffonts` und `pdftotext` (Paket `poppler-utils`), um die PDF-Ausgabe zu prüfen
- Netzwerkzugriff für arduino-cli, AVR-Core, Bibliotheken, Typst und Fonts

## Einmalig einrichten

```bash
tools/setup.sh
```

Das Skript ist idempotent und installiert arduino-cli, den AVR-Core, die
Bibliotheken, Typst sowie die OFL-Fonts unter `tutorial/assets/fonts/`. Die
aufgelösten Versionen stehen in `tools/VERSIONS.txt`.

## Sketches prüfen

```bash
tools/validate.sh
```

Kompiliert jedes Verzeichnis unter `code/`, das eine `*.ino` enthält und im
Pfad `_solution` trägt, für `arduino:avr:uno`. Die `_exercise`-Skelette werden
übersprungen. Die Report-Tabelle nennt den Beispielnamen (z. B. `021_average`).
Ergebnis: `dist/build-report.md` und je Sketch ein Log unter
`dist/build-logs/`. Der Exit-Code ist ungleich null,
sobald ein Sketch fehlschlägt. Die Sketches selbst bleiben unverändert, weil
jeder Build in einem temporären Verzeichnis landet.

## PDF rendern

```bash
tools/render.sh
```

Erzeugt `dist/Elegoo-Smart-Robot-Car-Tutorial.pdf` aus `tutorial/main.typ` mit
den gebündelten Fonts. Fehlt `tutorial/main.typ`, bricht das Skript mit einer
Fehlermeldung ab.

## Beispielstruktur

Jedes Beispiel hat eine feste Nummer (Fünferschritte ab 001) und genau zwei
Unterordner. Ordnername und Dateiname der `.ino` sind identisch, weil die
Arduino-IDE das verlangt:

```
code/001_hello_world/
    001_hello_world_exercise/001_hello_world_exercise.ino
    001_hello_world_solution/001_hello_world_solution.ino
```

Bei Demo-Beispielen ohne Lücke ist `_exercise` eine Kopie des vollständigen
Programms; bei Aufgaben bleibt `_exercise` das Skelett und `_solution` enthält
das vollständige Programm. Nur `_solution` wird gebaut.

| Nr. | Ordner | Kapitel | kompiliert |
|----:|--------|:-------:|:----------:|
| 001 | `001_hello_world` | 1 | ja |
| 006 | `006_variables` | 1 | ja |
| 011 | `011_decisions` | 1 | ja |
| 016 | `016_loops` | 1 | ja |
| 021 | `021_average` | 1 | ja |
| 026 | `026_drive_test` | 2 | ja |
| 031 | `031_speed_ramp` | 2 | ja |
| 036 | `036_square` | 2 | ja |
| 041 | `041_distance` | 3 | ja |
| 046 | `046_stop_before_wall` | 3 | ja |
| 051 | `051_calibrate_line` | 4 | ja |
| 056 | `056_line_follow` | 4 | ja |
| 061 | `061_servo_sweep` | 5 | ja |
| 066 | `066_look_around` | 5 | ja |
| 071 | `071_tilt` | 6 | ja |
| 076 | `076_shake` | 6 | ja |
| 081 | `081_led_colors` | 7 | ja |
| 086 | `086_ir_learn` | 7 | ja |
| 091 | `091_ir_drive` | 7 | ja |
| 096 | `096_serial_remote` | 8 | ja |


## Sketch hinzufügen

1. Die nächste freie Nummer wählen (Fünferschritte) und
   `code/<nummer>_<slug>/` anlegen.
2. `_exercise` und `_solution` als Unterordner anlegen; Ordnername und
   `.ino`-Dateiname müssen jeweils gleich lauten.
3. Bei Aufgaben das Skelett in `_exercise`, das vollständige Programm in
   `_solution` ablegen.
4. `tools/validate.sh` ausführen und den Eintrag in `dist/build-report.md`
   prüfen.

Übungsstände (`_exercise` im Pfad) werden bewusst nicht gebaut.
