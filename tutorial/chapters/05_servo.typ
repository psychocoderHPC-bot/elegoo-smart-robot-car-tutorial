#import "../lib/components.typ": *

#chapter(5, [Servo], goal: [
  Ein Servo ist ein kleiner Motor, der eine genaue Stellung halten kann.
  Du steuerst ihn mit einem Winkel von 0 bis 180 Grad.
  Am Ende dreht dein Auto den Kopf, misst links, in der Mitte und rechts und
  fährt in die Richtung mit dem größten Abstand.
])[
  #mission[
    Baue einen schwenkbaren Kopf. Er schaut nach links, geradeaus und nach
    rechts. Danach fährt das Auto dorthin, wo am meisten Platz ist.
  ]

  = Ein Motor mit Gedächtnis

  Ein normaler Motor dreht sich einfach weiter, solange Strom fließt. Ein
  Servo ist anders. In seinem Gehäuse sitzen ein Getriebe und eine kleine
  Steuerung. Du sagst ihm einen Winkel, zum Beispiel 90 Grad. Der Servo dreht
  dorthin und bleibt stehen.

  Der Servo hängt an Pin D10. Drei Adern verbinden ihn mit dem Shield:
  Masse, 5 Volt und das Steuersignal. Das Signal sagt dem Servo, welchen Winkel
  er anfahren soll.

  In diesem Buch gilt: 0 Grad schaut nach links, 90 Grad geradeaus und
  180 Grad nach rechts. Je nach Zusammenbau kann das gespiegelt sein. Dann
  tauschst du links und rechts im Code.

  #achtung[
    Dreh den Servo nie von Hand, solange das Auto Strom hat. Das Getriebe
    arbeitet gegen deine Hand und kann kaputtgehen. Schalte vorher aus.
  ]

  = Der Kopf dreht sich

  Das erste Programm schickt den Kopf einmal durch seinen ganzen Bereich.
  `write(90)` heißt: fahre auf 90 Grad. Danach braucht der Servo Zeit. Ohne
  Wartezeit würde das Programm sofort den nächsten Winkel schicken.

  #listing("/code/061_servo_sweep/061_servo_sweep_solution/061_servo_sweep_solution.ino", title: [Kopf drehen])

  Zeile 2 bindet die Servo-Bibliothek ein. Sie gehört zum Arduino und ist
  schon installiert. Zeile 4 bis 10 legen die Pins fest. Zeile 12 erzeugt das
  Objekt `headServo`, damit steuerst du den Servo später.

  Zeile 40 bis 43 fassen das Drehen zusammen. `lookAt()` stellt den Winkel ein
  und wartet 400 Millisekunden. Zeile 50 verbindet den Servo mit Pin D10. Ab
  Zeile 54 läuft die Schleife: links, geradeaus, rechts und zurück in die
  Mitte. Dann wartet das Programm 800 Millisekunden und beginnt von vorn.

  #achtung[
    Der Servo blockiert Timer1 des Uno. Timer1 erzeugt auch das PWM-Signal auf
    Pin 9 und Pin 10. Darum darfst du die Motoren nicht über Pin 9 oder 10
    regeln. Bei diesem Auto liegen die Motoren auf D5 und D6, die bleiben frei.
    Der Servo selbst sitzt auf D10.
  ]

  #probiere[
    Verkleinere den Bereich auf 30 bis 150 Grad. Der Kopf schwenkt dann nur
    noch ein Stück. Erhöhe danach `STEP_DELAY_MS` auf 600. Der Kopf wird
    langsamer, kommt aber sicher an jedem Winkel an.
  ]

  = Mission: Der freie Weg

  Jetzt bekommt der Kopf eine Aufgabe. Er misst nacheinander links, in der
  Mitte und rechts den Abstand. Die Funktion `readDistanceCm()` kennst du aus
  dem Ultraschallkapitel. Danach vergleicht das Programm die drei Werte und
  fährt in die Richtung mit dem größten Abstand.

  #figure(
    numbering: none,
    image("../assets/img/kap05_ablauf.svg", width: 100%),
    caption: [Abbildung 5.1: Eine Messrunde: Winkel setzen, 400 Millisekunden warten, Abstand messen. Nach drei Positionen wählt das Programm den besten Weg.],
  )

  Abbildung 5.1 zeigt die vier Schritte. Nach jeder Messung dreht der
  Kopf zum nächsten Winkel. Erst wenn alle drei Werte vorliegen, entscheidet
  das Programm.

  Der Übungssketch ist vollständig und baut so, wie er ist. Nur die Funktion
  `chooseAndDrive()` entscheidet noch nicht; im Übungssketch stoppt sie das Auto.
  Sie bekommt die drei Messwerte und
  entscheidet, wohin das Auto fährt.

  #gap("/code/066_look_around/066_look_around_exercise/066_look_around_exercise.ino", [
    Setze `bestCm` und `bestAngle` für links und rechts. Stelle den Kopf vor
    dem Fahren auf 90 Grad. Fahre nur, wenn `bestCm` mindestens
    `MIN_FREE_CM` ist, sonst stoppe mit `stopMotors()`. Drehe dann in die beste
    Richtung und fahre geradeaus.
  ])

  #notespace(lines: 8)

  #solution(
    "/code/066_look_around/066_look_around_solution/066_look_around_solution.ino",
    title: [Mission freier Weg],
  )

  Im Lösungssketch beginnt die Entscheidung bei Zeile 69. Zuerst gilt die
  Mitte mit 90 Grad. Zwei `if`-Abfragen prüfen, ob links oder rechts mehr Platz
  ist. `bestAngle` merkt sich die Richtung.

  Vor dem Fahren stellt Zeile 81 den Kopf wieder gerade. Nur so zeigt der
  Ultraschall in die Fahrtrichtung. Zeile 84 prüft `bestCm` gegen
  `MIN_FREE_CM`. Ist der beste Abstand zu klein oder die Messung ungültig
  (`-1`), stoppt das Auto sofort. Sonst dreht es auf der Stelle und fährt ein
  kurzes Stück. `stopMotors()` beendet die Fahrt.

  #fehler((
    ("Der Servo brummt und zittert.", "Der Winkel liegt außerhalb von 0 bis 180 Grad, oder der Kopf stößt an. Prüfe den Bereich und drehe den Kopf von Hand nur bei ausgeschaltetem Auto."),
    ("Der Kopf springt nur ruckartig.", "Die Wartezeit ist zu kurz. Erhöhe `STEP_DELAY_MS` auf 600 Millisekunden."),
    ("Das Auto fährt sofort nach dem Einschalten los.", "Der Start fehlt. In jedem fahrenden Sketch muss `waitForStart()` vor der ersten Fahrt stehen."),
    ("Der Motor auf D5 oder D6 läuft nicht.", "Prüfe, ob `PIN_PWMA` und `PIN_PWMB` im Sketch zu den Kabeln passen. Der Servo darf nicht auf D5 oder D6 hängen."),
  ))

  #merken[
    Ein Servo fährt einen Winkel an und hält ihn.
    `write(90)` stellt den Kopf geradeaus.
    Nach jedem Winkel braucht der Servo eine kurze Pause.
    Der Servo belegt Timer1, deshalb bleiben D5 und D6 für die Motoren.
    Vor jeder Fahrt wartet das Programm auf die Taste.
  ]

  #checklist((
    [Ich kann den Servo an D10 anschließen und mit `write()` drehen.],
    [Ich weiß, dass 90 Grad geradeaus bedeutet.],
    [Ich kann drei Abstände messen und den größten Wert finden.],
    [Ich kann das Auto in die freie Richtung fahren lassen.],
  ))
]
