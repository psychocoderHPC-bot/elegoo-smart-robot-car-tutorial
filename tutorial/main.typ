// Hauptdokument des Buches.
// Kompilieren:
//   typst compile --root /workspace/uno \
//     --font-path tutorial/assets/fonts tutorial/main.typ /tmp/main.pdf

#import "lib/theme.typ": *
#import "lib/components.typ": *

#set document(
  title: "Programmieren lernen mit dem Elegoo Smart Robot Car V4.0",
  author: "René Widera",
  keywords: (
    "Arduino",
    "Elegoo Smart Robot Car V4.0",
    "Robotik",
    "Programmieren lernen",
    "Kinder",
    "Deutsch",
  ),
  date: auto,
)

#show: book

// ---------------------------------------------------------------------------
// Umschlag
// ---------------------------------------------------------------------------

#page(header: none, footer: none)[
  #v(12mm)
  #text(size: 10pt, weight: "bold", fill: accent, tracking: 0.08em)[
    ELEGOO SMART ROBOT CAR V4.0
  ]
  #v(6mm)
  #text(size: 34pt, weight: "bold", fill: ink)[Programmieren lernen]
  #v(2mm)
  #text(size: 22pt, fill: ink)[mit dem Elegoo Smart Robot Car V4.0]
  #v(12mm)
  #align(center)[
    #image("assets/img/style_cover.svg", width: 82%)
  ]
  #v(6mm)
  #text(size: 13pt, fill: ink)[Ein Lernbuch für Arduino und Robotik]
  #v(1mm)
  #text(size: 11pt, fill: ink)[Für Kinder ab 12]
  #v(1fr)
  #text(size: 9pt, fill: rgb("#5A6572"))[Version 1.1 · Stand Oktober 2026]
]

// ---------------------------------------------------------------------------
// Leseanleitung
// ---------------------------------------------------------------------------

#page(header: none, footer: none)[
  #text(size: 20pt, weight: "bold", fill: ink)[So liest du dieses Buch]
  #v(4mm)

  Jedes Kapitel beginnt mit einer kurzen Mission. Danach baust du Schritt für
  Schritt ein Programm auf. Die Kästen helfen dir beim Lesen: Sie sind immer mit
  einem Wort beschriftet, damit du sie auch im Schwarz-Weiß-Druck erkennst.

  #v(2mm)
  #mission[
    Die Mission sagt dir, was du am Ende des Kapitels kannst oder gebaut hast.
  ]

  #goalbox(title: "Deine Aufgabe")[
    Bei einer Aufgabe bekommst du Code mit Lücken. Du ergänzt die fehlenden
    Zeilen selbst, bevor du weiterliest.
  ]

  #block(
    width: 100%,
    fill: green.lighten(88%),
    stroke: (left: 3pt + green),
    inset: (left: 9pt, right: 9pt, top: 6pt, bottom: 6pt),
    radius: 2pt,
    above: 8pt,
    below: 8pt,
  )[
    #text(weight: "bold", fill: green)[Lösung]
    #h(4pt)
    Die Lösung steht immer auf einer neuen Seite. Vergleiche erst nach dem
    eigenen Versuch.
  ]

  #merken[
    Merken fasst eine Regel zusammen, die du dir dauerhaft einprägen solltest.
  ]

  #tipp[
    Ein Tipp spart Zeit. Er zeigt dir einen einfachen Weg oder eine Abkürzung.
  ]

  #achtung[
    Achtung warnt vor einem Fehler, der Bauteile oder dein Programm gefährden kann.
  ]
]

// ---------------------------------------------------------------------------
// Inhalt
// ---------------------------------------------------------------------------

#outline(title: [Inhalt], depth: 1)

// ---------------------------------------------------------------------------
// Bevor du loslegst
// ---------------------------------------------------------------------------

#page[
  #text(size: 20pt, weight: "bold", fill: ink)[Bevor du loslegst]
  #v(4mm)

  Nimm dir kurz Zeit für diese Checkliste. Dann klappt der Start ohne
  Umwege.

  #achtung[
    *Welche Variante hast du?* Schau auf das Etikett des Kits. Dieses Buch
    passt zur Variante mit *TB6612* und *MPU6050/GY-521*. Andere Varianten
    haben eine andere Verdrahtung. Für sie gelten die Original-Dokumente von
    Elegoo, nicht dieses Buch.
  ]

  #tipp[
    Lege Akku und Kabel bereit. Lade den Akku vor dem ersten Fahren auf und
    prüfe, ob alle Kabel fest sitzen.
  ]

  #checklist((
    [Ich habe die Variante mit TB6612 und MPU6050/GY-521 erkannt.],
    [Der Akku ist geladen und alle Kabel sitzen fest.],
    [Arduino IDE 2.x ist installiert.],
    [Unter `Werkzeuge > Board` ist *Arduino Uno* gewählt.],
    [Unter `Werkzeuge > Port` ist der richtige Port gewählt.],
    [Die Bibliotheken sind in den getesteten Versionen installiert.],
    [Der Schalter steht auf *Upload* (nicht auf *Cam*).],
  ))

  #pinref((
    ("FastLED", "3.9.15"),
    ("IRremote", "4.7.1"),
    ("Adafruit MPU6050", "2.2.9"),
    ("Servo", "1.2.2"),
    ("ESP32-Core", "2.0.17 (nur für Kapitel 10)"),
  ))
]

#include "chapters/01_programmieren.typ"
#include "chapters/02_motoren.typ"
#include "chapters/03_ultraschall.typ"
#include "chapters/04_linie.typ"
#include "chapters/05_servo.typ"
#include "chapters/06_mpu6050.typ"
#include "chapters/07_licht.typ"
#include "chapters/08_kamera.typ"
#include "chapters/09_rettungsrover.typ"
#include "chapters/10_esp32.typ"
#include "chapters/11_projekte.typ"
#include "chapters/12_klassen.typ"
#include "chapters/13_cheatsheet.typ"
#include "chapters/99_anhang.typ"
