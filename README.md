# Programmieren lernen mit dem Elegoo Smart Robot Car V4.0

**Version 1.1 · Stand Oktober 2026**

Diese Fassung arbeitet die Befunde aus `review.md` ab. Dazu gehören die
Umstellung der IR-Codes auf IRremote 4.x, sicheres Anhalten bei Sensorausfall
und Verbindungsverlust sowie präzisere Pin- und Sicherheitshinweise. Die
Übungssketches werden jetzt mitgeprüft, wenn sie vollständig bauen; bewusste
Lückenskelette listet `tools/validate.sh` in `SKIP_EXERCISES`. Neu ist Kapitel 12 über
eigene Klassen; es zeigt, wie aus einem Sketch ein wiederverwendbares Bauteil
wird.

Ein deutsches Lernbuch (Typst) für Kinder ab 12. Zwölf Kapitel bauen aus dem
Arduino-Kit ein Auto, das fährt, eine Linie folgt, Hindernisse misst, mit dem
Servo den Kamerakopf dreht und per WLAN ein Bild sendet. Das Cheatsheet am Ende
fasst Pins, Befehle und Fehlerbilder zum Nachschlagen zusammen. Code kommt
direkt aus den `.ino`-Dateien unter `code/`, nichts wird abgetippt.

## Ordner

- `tutorial/` — Typst-Quellen. `main.typ` ist die Wurzel, `chapters/` hält die
  Kapitel, `lib/` die Layout-Bausteine (`components.typ`, `theme.typ`),
  `assets/` die Schriften und Bilder.
- `code/` — die Arduino-Sketches als nummerierte Beispiele. Jedes Beispiel hat
  einen Ordner mit `_exercise` (Skelett) und `_solution` (vollständiges
  Programm). Der Ordner- und Dateiname der `.ino` ist identisch.
- `tools/` — Skripte für Aufbau, Render und Sketch-Prüfung.
- `dist/` — Build-Ausgaben (PDF, Build-Logs, Prüfbericht).
- Die Original-Doku und Firmware des Kits (`ELEGOO Smart Robot Car Kit
  V4.0 2023.02.01/`) sind **nicht** Teil dieses Repositorys. Sie finden sich
  unter <https://github.com/elegooofficial/ELEGOO-Smart-Robot-Car-Kit-V4.0>.

## PDF bauen

```
tools/render.sh
```

liefert `dist/Elegoo-Smart-Robot-Car-Tutorial.pdf`. Benötigt: `typst` und die
unter `tutorial/assets/fonts` liegenden Schriften (Atkinson Hyperlegible,
JetBrains Mono).

## Sketches prüfen

```
tools/validate.sh
```

kompiliert jeden `_solution`-Ordner unter `code/` mit `arduino-cli`
in ein Temp-Builddir und schreibt
`dist/build-report.md`. Zusätzlich baut jedes `_exercise`-Skelett, sofern es
vollständig ist; bewusste Lückenskelette stehen in der `SKIP_EXERCISES`-Liste
im Skript. Der Bericht führt eine Spalte `Kind` (solution/exercise) und zeigt
übersprungene Übungen als `SKIP`.
Pfade mit `esp32` im Namen nutzen das ESP32-Board, alle anderen
`arduino:avr:uno`.
Benötigt: `arduino-cli` plus die Cores `arduino:avr` und `esp32:esp32`
(siehe `tools/setup.sh`).

## Beispiele

Nummern in Fünferschritten, beginnend bei 001. Bei Demo-Beispielen ohne Lücke
sind `_exercise` und `_solution` identisch; bei Aufgaben enthält `_exercise`
das Skelett und `_solution` die vollständige Fassung.

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
| 101 | `101_color_track_esp32` | 10 | ja |
| 106 | `106_follow_color_uno` | 10 | ja |
| 106 M | `106_follow_color_mission` | 11 | ja |
| 111 | `111_parking_guard` | 11 | ja |
| 116 | `116_dance` | 11 | ja |
| 121 | `121_secret_code` | 11 | ja |
| 126 | `126_classes` | 12 | ja |
| 131 | `131_rescue_rover` | 9 | ja |

Kapitel 10 programmiert den ESP32 selbst (Kamera und Farberkennung). Die
Beispiele 101 und 106 gehören dazu; 101 baut fürs ESP32-Board, 106 für den Uno.

_Alle 28 `_solution`-Ordner bauen. Beispiel 101 (`101_color_track_esp32`) laeuft auf dem ESP32, alle anderen auf dem Uno. `tools/validate.sh` prüft zusätzlich jedes `_exercise`-Skelett; die absichtlich unvollständigen bleiben über `SKIP_EXERCISES` außen vor (derzeit nur 121). Der Bericht nennt Art, Board und Status je Sketch._

## Kapitel ändern

Ein Kapitel ist eine Datei `tutorial/chapters/NN_titel.typ`. Der Code kommt
aus `code/` über `#listing("/code/...")` mit root-relativem Pfad. Layout
nutzt nur die Bausteine aus `lib/components.typ` (siehe `lib/README.md`):
`chapter`, `mission`, `listing`, `gap`, `solution`, `tipp`, `achtung`,
`probiere`, `merken`, `fehler`, `checklist`. Neue Seiten: erst die Preview-Datei
rendern und die Seitenzahl zählen, dann löschen.

## Voraussetzungen

- Windows-PC mit Arduino IDE 2.x (für das Auto)
- `typst` 0.15.1 (PDF) — `tools/setup.sh` installiert die Tools
- `arduino-cli` 1.5.1, Core `arduino:avr` 1.8.8 und Core `esp32:esp32`
  2.0.17 (Sketch-Prüfung)
- FastLED 3.9.15. Die 3.10.x-Reihe kollidiert mit Servo
  (`multiple definition of __vector_11`) und wird deshalb nicht genutzt.
- Elegoo Smart Robot Car Kit V4.0 mit Uno, Shield (TB6612 + GY-521),
  HC-SR04, 3 Linienfolgern, SG90, WS2812, IR-Fernbedienung,
  ESP32-WROVER-Kamera, 2 Motoren und Akku
