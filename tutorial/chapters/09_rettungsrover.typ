#import "../lib/components.typ": *

#chapter(9, [Grossprojekt Rettungsrover], goal: [
  Du verbindest Linienfolger, Ultraschall, Servo und LED in einem Programm.
  Du baust eine Zustandsmaschine mit fünf Zuständen.
  Du lässt den Rover Hindernissen ausweichen und nach drei Querlinien
  anhalten.
])[
  #mission[
    Ein Rover, der einer Linie folgt, Hindernissen ausweicht und nach drei
    Querlinien anhält.
  ]

  Jedes Kapitel bis hierher hatte eine Aufgabe. Dieses verbindet sie. Der
  Rover fährt, sieht, dreht den Kopf und leuchtet. Du schreibst dafür ein
  einziges Programm.

  #figure(
    numbering: none,
    image("../assets/img/kap09_zustandsdiagramm.svg", width: 96%),
    caption: [Abbildung 9.1: Fünf Zustände. Die Pfeile tragen die Bedingung für den Wechsel.],
  )

  = Fünf Zustände statt vieler if-Blöcke

  Bei einer Kreuzung muss das Auto wissen, was es gerade tut. Ein
  Linienfolger fährt, ein Hindernis warnt, eine Querlinie zählt. Mit vielen
  `if`-Blöcken verliert man den Überblick. Eine Zustandsmaschine merkt sich
  einen Zustand in einer Variablen. `loop` fragt nur: Welcher Zustand ist
  aktiv? Dann ruft sie genau die passende Funktion auf. Jede Funktion darf
  den Zustand wechseln. Der Zustand ist wie ein Gang beim Fahrrad: Du fährst
  immer nur in einem, und du schaltest bewusst.

  #goalbox(title: "Die fünf Zustände")[
    #table(
      columns: (auto, auto, 1fr),
      table.header([Zustand], [LED], [Aufgabe]),
      [`FOLLOW_LINE`], [blau], [Linie folgen, Abstand messen],
      [`OBSTACLE`], [rot], [anhalten, zurücksetzen, Kopf scannen],
      [`SEARCH`], [gelb], [im Bogen nach der Linie suchen],
      [`CROSSING`], [blau], [über die Querlinie fahren und zählen],
      [`END`], [grün], [anhalten, Kopf auf 90 Grad],
    )
  ]

  = Das vollständige Programm

  #listing("/code/131_rescue_rover/131_rescue_rover_solution/131_rescue_rover_solution.ino",
    title: [Rettungsrover])

  Das `enum` legt die fünf Zustände als Namen für feste Zahlen an.
  `FOLLOW_LINE` ist damit 0, `OBSTACLE` ist 1, und so weiter. Die
  Variable `state` merkt sich den aktuellen Zustand. Das `switch` in
  `loop` wählt danach die passende Funktion.

  `setState` macht drei Dinge: Es speichert den neuen Zustand, es merkt
  sich die Startzeit in `stateSince`, und es setzt die LED-Farbe aus der
  Liste `STATE_LED`. Die Namen für den Serial Monitor stehen in
  `STATE_NAMES`. Jeder Wechsel wird ausgegeben, zum Beispiel `OBSTACLE`
  oder `END`.

  In `followLine` liest der Rover die drei Liniensensoren. Der Fehler ist
  -1, wenn links schwarz ist, +1 bei rechts und 0 sonst. Mit
  `BASE_SPEED = 110` und `STEER_GAIN = 90` bekommt der linke Motor
  `110 + 90`, der rechte `110 - 90`. So zieht das Auto zur Linie zurück.
  Sehen alle drei Sensoren schwarz, wechselt der Zustand nach `CROSSING`.
  Sehen alle drei länger als 300 Millisekunden weiß, geht es nach
  `SEARCH`. Ist ein Hindernis näher als 25 cm oder ist die Messung
  ungültig, geht es nach `OBSTACLE`.

  `avoidObstacle` hält an, fährt 400 Millisekunden rückwärts und stellt
  den Kopf auf 20, 90 und 150 Grad. `lookAt` schreibt den Winkel mit
  `headServo.write` und wartet 400 Millisekunden. Danach misst der Rover
  den Abstand. Er dreht 500 Millisekunden in die Seite mit mehr Platz und
  sucht dann die Linie.

  `searchLine` fährt langsam im Bogen. Sieht ein Sensor wieder schwarz,
  geht es zurück nach `FOLLOW_LINE`. Nach 2 Sekunden ohne Linie hält der
  Rover an und bleibt in `SEARCH`.

  `crossLine` zählt beim Betreten die Querlinie. Dafür sorgt
  `crossings += (next == CROSSING)` in `setState`. Der Rover fährt 250
  Millisekunden gerade über die Linie. Ist die Linie vorbei und der
  Zähler noch unter 3, folgt er wieder der Linie. Bei der dritten
  Querlinie wechselt er nach `END`. Dort stoppt er, die LED wird grün,
  der Kopf steht auf 90 Grad.

  = Sicherheit vor Tempo

  Drei Fälle dürfen nicht zum Blindflug werden:

  - *Kein Echo:* Liefert der Ultraschall keine gültige Messung, weil die
    Leitung ab ist oder eine weiche Fläche schluckt, zählt das wie ein
    Hindernis. Der Rover hält an und wechselt nach `OBSTACLE`.
  - *Linie verloren:* `SEARCH` sucht höchstens 2 Sekunden. Danach stoppt
    er und bleibt stehen.
  - *Fahrt dauert zu lange:* Nach `RESCUE_MAX_MS` (30 Sekunden) ohne
    neue Querlinie wechselt der Rover nach `END` und stoppt. Auch eine
    hängende Querlinie beendet die Fahrt.

  #goalbox(title: "Bibliotheksversionen")[
    FastLED 3.9.15 und Servo 1.2.2 vertragen sich. Mit FastLED 3.10.x
    bricht der Linker mit `multiple definition of __vector_11` ab. Wer die
    neuere Version installiert hat, wählt im Bibliotheksmanager 3.9.15.
  ]

  = Mission: zwei Funktionen fehlen

  Im Sketch 131 sind `avoidObstacle()` und `searchLine()` leer. Alles
  andere ist vollständig. Ergänze die beiden Funktionen so, dass der Rover
  Hindernissen ausweicht und die Linie wiederfindet.

  #gap("/code/131_rescue_rover/131_rescue_rover_exercise/131_rescue_rover_exercise.ino", [
    In `avoidObstacle()`: anhalten, 400 Millisekunden rückwärts fahren,
    den Kopf auf 20, 90 und 150 Grad stellen und jeweils den Abstand
    messen. Drehe danach 500 Millisekunden zu der Seite mit mehr Platz und
    starte `SEARCH`.

    In `searchLine()`: Fahre mit `drive(70, 30)` im Bogen. Sieht ein
    Sensor schwarz, starte `FOLLOW_LINE`. Sind 2 Sekunden ohne Linie
    vergangen, halte an. `now - stateSince` liefert die Zeit seit dem
    Zustandswechsel.
  ])

  #notespace(lines: 6)

  #solution(
    "/code/131_rescue_rover/131_rescue_rover_solution/131_rescue_rover_solution.ino",
    title: [Mission Rettungsrover],
  )

  In `avoidObstacle()` stehen die drei Messungen hintereinander. `l`, `m`
  und `r` sind die Abstände links, in der Mitte und rechts. Die Bedingung
  `l > m && l >= r` wählt links, wenn dort mehr Platz ist als in der Mitte
  und mindestens so viel wie rechts. Sonst prüft `r > m` die rechte Seite.
  Ohne freie Seite fährt der Rover nicht los, sondern geht direkt in
  `SEARCH`.

  In `searchLine()` prüft die erste Abfrage alle drei Sensoren. Ein
  einziger schwarzer Sensor reicht für `FOLLOW_LINE`. Danach entscheidet
  die Zeit: `now - stateSince > SEARCH_MS` bedeutet 2 Sekunden ohne
  Linie. Dann stoppt `stopMotors()` den Rover.

  = Erweitere selbst

  #probiere[
    - *Kamerabild während der Fahrt:* Schalte den Schalter auf `Cam`,
      verbinde dein Handy mit dem WLAN und öffne `http://192.168.4.1/Test`.
      Der Uno fährt weiter, während das Handy das Bild zeigt.
    - *Summen statt LED:* Ersetze die LED-Farbe durch einen kleinen
      Summer an einem freien Pin. Jeder Zustand bekommt einen anderen Ton.
      Welchen Pin dein Summer braucht, steht in seiner Anleitung.
    - *Vierter Zustand:* Ergänze `MANUAL`. Dort liest der Rover die
      Fernbedienung aus Kapitel 7 und fährt mit den Tasten. Ein Tastendruck
      schaltet zwischen `FOLLOW_LINE` und `MANUAL` um.
  ]

  #fehler((
    ([Der Rover reagiert nicht auf die Taste.],
      [Prüfe `pinMode(PIN_BUTTON, INPUT_PULLUP)`. Ohne den internen
      Widerstand liest der Pin keinen Tastendruck.]),
    ([Der Rover zählt die Querlinien nicht.],
      [Die Schwelle passt nicht. Lies die Rohwerte neu und setze
      `LINE_THRESHOLD` zwischen Schwarz und Weiß.]),
    ([Der Linker meldet `multiple definition of __vector_11`.],
      [Deine FastLED-Version ist zu neu. FastLED 3.10.x und Servo 1.2.2
      belegen denselben Timer. Wähle im Bibliotheksmanager FastLED
      3.9.15.]),
    ([Der Rover fährt trotz fehlender Ultraschallmessung weiter.],
      [Behandle den Timeout als Hindernis. `readDistanceCm()` muss einen
      ungültigen Wert liefern und `followLine` muss dann nach `OBSTACLE`
      wechseln. Ohne Echo gilt nie „freie Fahrt“.]),
  ))

  #merken[
    - Ein Zustand ist eine Zahl mit einem Namen. `enum` legt die Namen fest.
    - `switch` wählt die Funktion für den aktuellen Zustand.
    - `millis()` liefert die Zeit seit dem Einschalten. Die Differenz zu
      `stateSince` misst, wie lange ein Zustand schon läuft.
    - Jeder Zustand hat eine LED-Farbe und eine Aufgabe.
    - FastLED 3.9.15 und Servo 1.2.2 passen zusammen. FastLED 3.10.x
      bricht beim Linken ab.
    - Eine ungültige Messung zählt wie ein Hindernis, nicht als freie
      Fahrt.
    - Nach 2 Sekunden ohne Linie und nach 30 Sekunden ohne neue
      Querlinie stoppt der Rover.
  ]

  #checklist((
    [Ich erkläre die fünf Zustände und ihre LED-Farben.],
    [Ich finde im Listing die Stelle, die den Zustand wechselt.],
    [Mein Rover folgt der Linie und weicht einem Hindernis aus.],
    [Mein Rover zählt drei Querlinien und hält danach an.],
    [Mein Rover hält bei fehlendem Echo und verlorener Linie an.],
    [Ich lese jeden Zustandswechsel im Serial Monitor.],
    [Ich habe eine eigene Erweiterung ausprobiert.],
  ))
]
