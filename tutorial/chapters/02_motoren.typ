#import "../lib/components.typ": *

#chapter(2, [Motoren], goal: [
  Du verstehst, wie der Motortreiber die Drehrichtung umschaltet und wie du die
  Geschwindigkeit in 255 Stufen einstellst. Du baust ein Start-Gate mit Taste
  und Countdown. Danach fährt dein Auto vorwärts, rückwärts und im Quadrat.
  Zum Schluss stellst du den Geradeauslauf mit dem Trimm ein.
])[

  = Die erste Fahrt

  Zwei Programme stehen am Anfang. Das erste fährt vier Manöver. Das zweite
  erhöht die Geschwindigkeit in Stufen. Lies zuerst den Code, danach die
  Erklärung. Beide Programme starten erst nach einem Tastendruck.
  Abbildung 2.1 zeigt diesen Start als Plan.

  #figure(
    numbering: none,
    image("/tutorial/assets/img/kap02_startablauf.svg", width: 100%),
    caption: [Abbildung 2.1: Das Start-Gate. Erst Tastendruck, Loslassen und der Countdown geben die Fahrt frei.],
  )

  #listing("/code/026_drive_test/026_drive_test_solution/026_drive_test_solution.ino", title: [Vor, zurück und drehen])

  = Warum setup nie fahren darf

  Beim Hochladen hängt das Auto am USB-Kabel. Der Arduino startet direkt nach
  dem Flashen, noch bevor du das Kabel weglegen kannst. Stünde ein Fahrbefehl in
  `setup`, führe das Auto sofort los. Es zöge am Kabel oder über die Tischkante.

  Deshalb steht jeder Fahrbefehl in `loop` hinter einem Start-Gate. Du drückst
  die Taste auf dem Shield und lässt sie wieder los. Dann zählt das Programm
  3, 2, 1. In dieser Zeit legst du das Kabel zur Seite und setzt das Auto hin.
  Erst nach dem Countdown fährt es. Abbildung 2.1 zeigt das Gate als Plan:
  Solange die Taste nicht gedrückt ist, läuft das Programm im Kreis und wartet.

  #mission[
    Baue ein Auto, das erst nach Tastendruck und Countdown fährt. Teste
    vorwärts, rückwärts und beide Drehungen. Fahre danach ein Quadrat mit
    eigenen Fahrfunktionen.
  ]

  #listing("/code/031_speed_ramp/031_speed_ramp_solution/031_speed_ramp_solution.ino", title: [Rampe von 0 bis 255])

  = Die H-Brücke

  Der Motortreiber enthält pro Seite eine H-Brücke. Sie polt die Spannung um.
  Ein Richtungspin pro Seite gibt die Richtung vor. Der PWM-Pin gibt die
  Geschwindigkeit vor. `analogWrite` schaltet schnell ein und aus: 0 ist aus,
  255 ist volle Kraft, 120 ist knapp die Hälfte.

  = Was der Code macht

  Zeile 11 bis 15 stoppen beide Motoren. `STBY` auf `LOW` trennt den Treiber.
  Zeile 16 bis 24 sind `drive`: zwei Geschwindigkeiten, `constrain` auf -255 bis
  255, positiv vorwärts, negativ rückwärts, `abs` für `analogWrite`.

  Abbildung 2.2 trennt die eine Zahl in zwei Aufgaben. Das Vorzeichen wählt die
  Drehrichtung, der Betrag ohne Vorzeichen bestimmt die Geschwindigkeit.

  #figure(
    numbering: none,
    image("/tutorial/assets/img/kap02_drive.svg", width: 100%),
    caption: [Abbildung 2.2: `drive` macht aus einer Zahl zwischen -255 und 255 Richtung und Geschwindigkeit.],
  )

  Zeile 25 bis 31 lesen die Taste. `INPUT_PULLUP` hält sie auf `HIGH`, gedrückt
  liefert `LOW`. Zeile 32 bis 46 sind das Gate: warten auf den Druck, warten
  aufs Loslassen, dann 3, 2, 1.

  Zeile 63 bis 85 fahren. Vorwärts und rückwärts dauern eine Sekunde. Für die
  Drehung laufen die Räder gegenläufig.

  #achtung[
    Stelle das Auto so auf eine Kiste, dass beide Räder frei drehen und das
    Auto nicht vom Tisch fallen kann. Lege das USB-Kabel locker, sodass es
    nirgends zieht. Halte eine Hand am Ein-/Aus-Schalter. Der Countdown hilft
    beim Timing, ist aber keine Garantie: Prüfe vor dem Start, dass das Auto
    sicher steht und das Kabel frei liegt.
  ]

  = Geschwindigkeit in Stufen

  `analogWrite` kennt 0 bis 255. Kleine Werte drehen die Achse oft nicht.
  Zeile 9 legt die Stufe auf 51: 0, 51, 102, 153, 204, 255. Zeile 72 bis 77
  fährt jede Stufe an. Beobachte, ab welcher Zahl die Räder drehen.

  #probiere[
    Ändere `RAMP_STEP` auf `17`. Jetzt gibt es 16 Stufen. Ändere danach
    `STEP_DELAY_MS` auf `200`, dann läuft der Test schneller.
  ]

  = Der Trimm

  Zwei Motoren laufen nie gleich, das Auto zieht zur Seite. `LEFT_TRIM` und
  `RIGHT_TRIM` in Zeile 9 und 10 gleichen das aus. Zieht es nach links, erhöhe
  `RIGHT_TRIM`; zieht es nach rechts, erhöhe `LEFT_TRIM`. Werte von -20 bis 20.

  #tipp[
    Fährt das Auto rückwärts, obwohl `driveForward` aufgerufen wird, tausche in
    `drive` die beiden Richtungspins: `PIN_BIN1` und `PIN_AIN1` in Zeile 19 und
    20. Dann stimmt die Richtung für dein Shield.
  ]

  = Mission: Quadrat fahren

  Ein Quadrat hat vier gleiche Seiten und vier Drehungen um 90 Grad. In der
  Aufgabe fehlen die Funktionen `driveOneSide` und `driveSquare`.

  #gap("/code/036_square/036_square_exercise/036_square_exercise.ino", [
    Fülle `driveOneSide`: vorwärts fahren, `SIDE_MS` warten, anhalten. Fülle
    `driveSquare`: eine Seite fahren, links drehen, `TURN_MS` warten, anhalten.
    Wiederhole das vier Mal.
  ])

  #notespace(lines: 4)

  #solution("/code/036_square/036_square_solution/036_square_solution.ino", title: [Quadrat])

  Stelle die Zeiten selbst ein. `SIDE_MS` bestimmt die Seitenlänge, `TURN_MS`
  den Drehwinkel.

  = Fehler und Merken

  #fehler((
    ([Die Räder stehen still], [Prüfe, ob `drive` den Treiber mit `PIN_STBY` auf `HIGH` schaltet.]),
    ([Das Auto fährt rückwärts], [Tausche in `drive` die Pins `PIN_BIN1` und `PIN_AIN1`.]),
    ([Das Auto zieht nach links], [Erhöhe `RIGHT_TRIM` um einige Stufen.]),
    ([Die Taste startet nichts], [Prüfe `pinMode(PIN_BUTTON, INPUT_PULLUP)`. Gedrückt liefert `LOW`.]),
  ))

  #merken[
    `setup` enthält keinen Fahrbefehl. Das Gate wartet auf die Taste und zählt
    3, 2, 1. `drive` bekommt links und rechts getrennte Geschwindigkeiten.
    Positiv fährt vorwärts, negativ rückwärts.
  ]

  #checklist((
    [Ich kann erklären, warum `setup` nie fährt],
    [Ich habe das Gate mit Taste und Countdown getestet],
    [Ich habe vorwärts, rückwärts und beide Drehungen gesehen],
    [Ich habe ein Quadrat mit eigenen Fahrfunktionen gebaut],
  ))

]
