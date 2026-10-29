#import "../lib/components.typ": *

#chapter(7, [Licht und Fernbedienung], goal: [
  Du bringst die RGB-LED auf dem Shield zum Leuchten. Du liest die
  Befehle deiner Fernbedienung aus und fährst das Auto mit den Tasten.
])[
  #mission[
    Baue ein Auto, das auf einen Tastendruck fährt, mit `OK` anhält und
    dabei eine farbige LED leuchten lässt. Ohne neuen Befehl stoppt es
    nach einer Sekunde von selbst.
  ]

  = Drei Farben in einer LED

  Die LED auf dem Shield heißt WS2812. In ihr stecken drei winzige
  Leuchtdioden: rot, grün und blau. Aus diesen drei Farben mischt sie alle
  anderen. Der Datenpin ist D4.

  Die drei Zahlen in `CRGB(255, 120, 0)` stehen für Rot, Grün und Blau.
  Jede Zahl geht von 0 bis 255. 255 ist die volle Helligkeit. Zusammen
  ergibt das Orange. `CRGB::Red` ist eine Abkürzung für `CRGB(255, 0, 0)`.
  Mit `FastLED.setBrightness(60)` dimmst du alle Farben auf 60 von 255.

  #listing("/code/081_led_colors/081_led_colors_solution/081_led_colors_solution.ino",
    title: [Vier Farben und einmal aus])

  Zeile 7 legt den Speicher für eine LED an. Zeile 8 und 9 bauen die
  Farbliste: Rot, Grün, Blau, ein eigenes Orange und Schwarz. Schwarz
  bedeutet aus. Die Schleife in Zeile 24 bis 28 zeigt jede Farbe
  500 Millisekunden lang. `FastLED.show()` schickt die Farbe erst an die
  LED. Ohne diesen Aufruf bleibt sie dunkel.

  #probiere[
    Ändere `FastLED.setBrightness(60)` auf `20`. Die LED wird deutlich
    dunkler. Ändere dann `CRGB(255, 120, 0)` auf `CRGB(0, 255, 120)`.
    Welche Farbe kommt heraus?
  ]

  = Die Fernbedienung auslesen

  Jede Taste sendet einen Rahmen. Im Karton liegen zwei Revisionen.
  Darum liest du zuerst selbst aus, was deine Fernbedienung sendet.
  Der Empfänger sitzt auf D9.

  `IrReceiver.begin(PIN_IR, DISABLE_LED_FEEDBACK)` schaltet die
  Rückmeldung auf D13 ab. D13 ist der Trigger des Ultraschallsensors.
  Mit eingeschalteter Rückmeldung blinkt dort eine LED und der Abstand
  wird falsch. Das zweite Argument ist deshalb wichtig.

  `decodedIRData` ist eine kleine Tabelle mit mehreren Feldern:

  - `protocol` sagt, welches Übertragungsformat die Taste benutzt.
  - `address` ist die Adresse des Geräts.
  - `command` ist die eigentliche Tastennummer. Sie passt in ein
    `uint8_t`, also in eine Zahl von 0 bis 255.
  - `decodedRawData` ist der ganze 32-Bit-Rahmen. Bei NEC steht er in
    IRremote 4.x anders herum als in alten Beispielen. Zum Steuern
    brauchst du ihn nicht.

  Zum Vergleichen nimmst du `command`. Er ist kurz und für alle Tasten
  einer Fernbedienung eindeutig. `decodedRawData` hilft nur, wenn du
  einen Wert aus einer alten Anleitung wiedererkennen willst.

  Was `0x` bedeutet, steht in Kapitel 6. Kurz: `0x62` ist die Hex-Schreibweise für 98.

  #listing("/code/086_ir_learn/086_ir_learn_solution/086_ir_learn_solution.ino",
    title: [Protokoll, Adresse und Befehl auslesen])

  Der Sketch gibt pro Tastendruck eine Zeile aus, zum Beispiel
  `Protokoll 1 Adresse 0x0 Befehl 0x62 Roh 0xB946FF00`. `Protokoll 1`
  ist NEC. `Befehl 0x62` gehört zur Taste „hoch“. Nach jeder Zeile ruft
  der Sketch `resume()` auf. Damit ist der Empfänger für die nächste
  Taste frei.

  #probiere[
    Drücke alle 14 Tasten der Reihe nach. Schreibe jede Zeile auf ein
    Blatt. Manche Tasten senden beim Halten denselben Befehl mehrfach.
    Notiere nur den ersten Wert.
  ]

  = Mission: Fahren per Fernbedienung

  Jetzt verbindest du die Befehle mit den Motoren. Der Sketch prüft
  `decodedIRData.command` in einer `switch`-Anweisung. Die fünf
  `CMD_...`-Konstanten stehen oben an einer einzigen Stelle. Für eine
  andere Fernbedienung änderst du nur dort die Zahlen.

  `OK` ruft `stopMotors()` auf. Die anderen Tasten rufen `drive()` mit
  160 von 255 auf. Das Start-Gate bleibt Pflicht: Erst drückst du die
  Taste auf dem Shield, dann läuft der Countdown, dann gehorcht das Auto
  der Fernbedienung. Vorher bewegt sich nichts.

  Der Sketch merkt sich die Zeit des letzten gültigen Befehls. Kommt
  eine Sekunde lang kein neuer Befehl, hält er an. Das schützt dich,
  wenn die Batterie leer ist, du hinter ein Hindernis greifst oder die
  Verbindung abreißt. Das Auto fährt nie endlos weiter.

  #figure(
    numbering: none,
    image("../assets/img/kap07_taste.svg", width: 100%),
    caption: [Abbildung 7.1: So wertet der Sketch eine Taste aus. Nur ein bekannter Befehl löst eine Aktion aus. Danach gibt `resume()` den Empfänger wieder frei.],
  )

  Abbildung 7.1 zeigt den Weg vom Signal bis zur Aktion. Ein unbekannter
  Befehl wird verworfen. Das ist wichtig, weil manche Fernbedienungen
  beim Halten denselben Befehl mehrfach senden.

  #gap("/code/091_ir_drive/091_ir_drive_exercise/091_ir_drive_exercise.ino", [
      Öffne die Übungsdatei. Sie ist vollständig und baut sofort.
      Ergänze in `handleCode` die fünf Fälle. Nimm `drive(SPEED, SPEED)`
      für vorwärts, negative Werte für rückwärts und `stopMotors()` für
      `OK`. Die Konstanten `CMD_...` und der Watchdog sind schon fertig.
    ])
  #notespace(lines: 6)

  #solution("/code/091_ir_drive/091_ir_drive_solution/091_ir_drive_solution.ino",
    title: [Mission Fernbedienung])

  #goalbox(title: "Befehlstabelle der Fernbedienung Familie A")[
    Diese Werte stehen in `decodedIRData.command`. Prüfe sie mit dem
    Auslese-Sketch. Andere Fernbedienungen (Familie B) senden andere
    Zahlen. Miss sie mit 086 und trage sie im Sketch an der einen
    markierten Stelle ein. Das `0x` gehört vor jede Zahl.

    #text(size: 8pt)[
      #table(
        columns: (auto, auto, 1fr),
        table.header([Taste], [command], [Aktion]),
        [hoch], [`0x62`], [vorwärts],
        [runter], [`0xA8`], [rückwärts],
        [links], [`0x22`], [links drehen],
        [rechts], [`0xC2`], [rechts drehen],
        [OK], [`0x02`], [anhalten],
        [1], [`0x68`], [noch frei],
        [2], [`0x98`], [noch frei],
        [3], [`0xB0`], [noch frei],
        [4], [`0x30`], [noch frei],
        [5], [`0x18`], [noch frei],
        [6], [`0x7A`], [noch frei],
        [7], [`0x10`], [noch frei],
        [8], [`0x38`], [noch frei],
        [9], [`0x5A`], [noch frei],
      )
    ]
  ]

  #fehler((
    ("Die LED bleibt dunkel.",
     "Prüfe die Farbreihenfolge im `addLeds`-Aufruf. Sie muss `GRB`
      heißen. Mit `RGB` leuchten die Farben falsch oder gar nicht."),
    ("Die Fernbedienung reagiert nicht.",
     "Prüfe den Pin: Der Empfänger hängt an D9. Steht in `begin` eine
      andere Zahl, kommt nichts an. Außerdem muss dort
      `DISABLE_LED_FEEDBACK` stehen, sonst stört D13 den Ultraschall."),
    ("Das Auto fährt bei einem Tastendruck nicht.",
     "Drücke zuerst die Taste auf dem Shield. Ohne das Start-Gate bleibt
      `waitForStart()` stehen und der Loop liest keine Befehle."),
    ("Nur manche Tasten tun etwas.",
     "Deine Fernbedienung nutzt die andere Familie B. Lies die Befehle
      mit dem Auslese-Sketch 086 neu aus und ändere die `CMD_...`-Zahlen
      an der markierten Stelle im Sketch."),
    ("Das Auto hält nach einer Sekunde an, obwohl ich noch fahre.",
     "Das ist der Watchdog. Halte die Richtungstaste gedrückt oder
      drücke sie erneut. Ohne neuen Befehl soll das Auto nicht
      weiterfahren."),
  ))

  #merken[
    - Eine WS2812 mischt Rot, Grün und Blau. Jede Zahl geht von 0 bis 255.
    - `FastLED.show()` schickt die Farbe an die LED.
    - Der IR-Empfänger sitzt auf D9.
      `begin(PIN_IR, DISABLE_LED_FEEDBACK)` hält D13 frei.
    - `command` ist die Tastennummer, `decodedRawData` der ganze Rahmen.
    - Die `CMD_...`-Zahlen stehen an einer einzigen Stelle im Sketch.
    - Ohne neuen Befehl stoppt der Watchdog die Motoren nach einer
      Sekunde. `resume()` öffnet den Empfänger für die nächste Taste.
  ]

  #checklist((
    [Ich kann eine Farbe aus Rot, Grün und Blau mischen.],
    [Ich kann die Helligkeit der LED ändern.],
    [Ich lese Protokoll, Adresse, Befehl und Rohwert im Serial Monitor.],
    [Ich fahre das Auto mit der Fernbedienung und stoppe mit `OK`.],
    [Ich drücke vor jeder Fahrt das Start-Gate.],
    [Ich erkläre, warum das Auto ohne neuen Befehl anhält.],
  ))
]
