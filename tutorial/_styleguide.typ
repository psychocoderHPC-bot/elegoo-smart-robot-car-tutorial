// Interne Stilprobe. Nicht in main.typ eingebunden.
// Kompilieren (absolute Pfade unter /tmp brauchen root /):
//   typst compile --root / --font-path tutorial/assets/fonts \
//     tutorial/_styleguide.typ /tmp/styleguide.pdf

#import "lib/theme.typ": *
#import "lib/components.typ": *

#set document(title: "Styleguide: Programmieren lernen mit dem Elegoo Smart Robot Car V4.0", author: "René Widera")
#show: book

#page(header: none, footer: none)[
  #v(18mm)
  #text(size: 12pt, weight: "bold", fill: accent)[STYLEGUIDE]
  #v(4mm)
  #text(size: 28pt, weight: "bold")[Alle Bausteine auf einen Blick]
  #v(4mm)
  #text(size: 11pt)[Diese Datei zeigt jede Komponente einmal. Sie wird nicht mitgedruckt.]
]

#chapter(1, [Beispielkapitel], goal: [Du siehst alle Bausteine und ihre Beschriftung.])[
  = Ein Abschnitt

  Ein normaler Absatz mit `inline code` und einem Verweis auf *wichtige Wörter*.
  Der Text ist linksbündig gesetzt, damit man die Komponenten gut vergleichen kann.

  #mission[
    Eine Mission beschreibt das Ziel der Übung in einem Satz.
  ]

  #tipp[
    Ein Tipp nennt einen einfachen Handgriff oder eine Abkürzung.
  ]

  #achtung[
    Achtung weist auf eine typische Gefahr hin, zum Beispiel auf Verpolung.
  ]

  #probiere[
    Probiere lädt zum Experimentieren ein: ändere einen Wert und beobachte das Ergebnis.
  ]

  #merken[
    Merken fasst eine Regel zusammen, die man behalten sollte.
  ]

  #goalbox(title: "Ziel")[
    Am Ende kannst du eine LED blinken lassen.
  ]

  #fehler((
    ("digitalWrite(13, HIGH)", "Semikolon am Zeilenende ergänzen"),
    ("delay(500)", "Klammern und Zahl prüfen"),
  ))

  #pinref((
    ("13", "LED auf dem Arduino-Board"),
    ("GND", "Masse, gemeinsamer Minuspol"),
    ("5V", "Versorgung für kleine Sensoren"),
  ))

  #checklist((
    [Board per USB verbunden],
    [Richtiger Port in der Arduino IDE gewählt],
    [Sketch ohne Fehler hochgeladen],
  ))

  #notespace(lines: 4)

  = Vollständiges Listing

  #listing("/tmp/styleguide_sample.ino", title: [Blink], note: [Die LED blinkt im Sekundentakt.])

  = Lücke und Lösung

  #gap("/tmp/styleguide_gap.ino", [
    Ergänze die drei fehlenden Zeilen im `loop()`.
  ])

  #solution("/tmp/styleguide_sample.ino", title: [Blink])
]
