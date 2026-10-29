#import "../lib/components.typ": *

#chapter(11, [Projekte zum Weiterbauen], goal: [
  Du baust vier kleine Projekte, die du nach Kapitel 9 allein schaffst.
  Zwei Projekte haben eine Aufgabe mit Lösung auf der nächsten Seite.
  Jedes Projekt hat einen eigenen Sketch und eine Idee zum Verändern.
])[
  #mission[
    Baue einen Parkwächter, einen Tanzroboter und ein Schloss mit
    Geheimcode. Danach schickst du das Auto mit der Kamera auf eine
    Mission.
  ]

  = Vier Ideen für dein Auto

  Die drei Lösungen sind vollständig und lassen sich direkt übersetzen; die Übungen enthalten TODO-Stellen.
  Öffne den passenden Ordner und darin genau diese Datei:

  - Parkwächter:
    `code/111_parking_guard/111_parking_guard_exercise/`
    `111_parking_guard_exercise.ino`
  - Tanzroboter:
    `code/116_dance/116_dance_exercise/116_dance_exercise.ino`
  - Geheimcode:
    `code/121_secret_code/121_secret_code_solution/`
    `121_secret_code_solution.ino`

  Jeder Sketch hat einen Pin-Block und ein Start-Gate.

  = Parkwächter

  *Ziel:* Das Auto steht und beobachtet den Weg. Der Kopf schwenkt langsam
  nach links, in die Mitte und nach rechts. Unter 40 cm leuchtet die LED
  rot, und im Serial Monitor steht `Alarm`. Sonst leuchtet sie grün.

  #goalbox(title: "Bibliotheksversionen")[
    FastLED 3.9.15 und Servo 1.2.2 vertragen sich. Bei FastLED 3.10.x
    bricht der Linker mit `multiple definition of __vector_11` ab. Wähle
    im Bibliotheksmanager dann 3.9.15.
  ]

  `lookAt` stellt den Winkel mit `write` ein und wartet 450 Millisekunden.
  Danach steht der Kopf an der neuen Stellung.

  #gap("/code/111_parking_guard/111_parking_guard_exercise/111_parking_guard_exercise.ino", [
    Wähle eine Alarmgrenze zwischen 20 und 60 cm. Wähle einen
    Schwenkbereich zwischen 20 und 160 Grad. Trage die drei Werte ein und
    lade den Sketch hoch.
  ])

  #notespace(lines: 2)

  #solution(
    "/code/111_parking_guard/111_parking_guard_solution/111_parking_guard_solution.ino",
    title: [Parkwächter],
  )

  `scanAt` dreht den Kopf, misst und entscheidet in einem Zug. Die Schleife
  besucht links, Mitte, rechts und noch einmal Mitte. So schaut der Kopf
  nach jeder Runde wieder geradeaus. Fehlt das Echo, zeigt die LED Rot und
  der Kopf bleibt stehen. Bleibt das Echo fünf Sekunden aus, hält das
  Programm ganz an, statt „frei“ anzunehmen.

  #probiere[
    Setze `ALARM_CM` auf 25. Der Wächter meldet sich erst, wenn jemand
    näher kommt. Setze danach `SWEEP_LEFT` auf 60 und `SWEEP_RIGHT` auf
    120. Der Kopf schaut nur noch in einen schmalen Bereich.
  ]

  = Tanzroboter

  *Ziel:* Das Auto tanzt drei Strophen. Jede Strophe fährt, dreht und
  wackelt mit dem Kopf. Die LED zeigt die Farbe der Strophe.

  Jede Strophe ist eine eigene Funktion. `move` fährt eine Zeit lang und
  hält danach an. `wiggleHead` schaut links, rechts und zurück. Die Zeiten
  stehen als Zahlen im Code. Es gibt keinen Zufall: Jeder Lauf sieht gleich
  aus. Musik braucht der Tanz nicht.

  #gap("/code/116_dance/116_dance_exercise/116_dance_exercise.ino", [
    Schreibe `verseFour`. Nimm mindestens zwei Bewegungen aus `move`,
    eine Farbe mit `setLed` und einmal `wiggleHead`. Die vierte Strophe
    wird schon in `loop` aufgerufen.
  ])

  #notespace(lines: 4)

  #solution(
    "/code/116_dance/116_dance_solution/116_dance_solution.ino",
    title: [Tanzroboter],
  )

  `move` bekommt links, rechts und die Dauer in Millisekunden. Ein negativer
  Wert dreht das Rad rückwärts. `loop` spielt alle vier Strophen
  hintereinander und schaltet danach die LED aus. Die vierte Strophe ist
  deine Lösung aus der Aufgabe.

  #probiere[
    Tausche in `verseOne` die Farbe gegen `CRGB::Orange`. Ändere die
    Dauer der ersten Bewegung von 700 auf 1200 Millisekunden. Die Strophe
    wird langsamer und die LED zeigt eine andere Farbe.
  ]

  = Geheimcode

  *Ziel:* Du tippst mit der Fernbedienung 1, dann 2, dann 3. Stimmt die
  Folge, fährt das Auto seine Figur und die LED wird grün. Bei einem
  falschen Zeichen wird sie rot und die Folge beginnt neu.

  `step` merkt sich, welche Ziffer als Nächstes kommt. `SECRET` speichert
  die Folge. `digitFromCommand` liest `decodedIRData.command` aus
  IRremote 4.x und vergleicht die Tasten der Familie A: 1 ist `0x68`,
  2 ist `0x98`, 3 ist `0xB0`. Ein unbekannter Code liefert 0 und wird
  ignoriert. Eine andere Fernbedienung misst du mit Beispiel 086 und
  trägst ihre Werte ein. Die 1 zählt auch als neuer Anfang: Auf
  1-2-1-2-3 folgt die Figur.

  #listing(
    "/code/121_secret_code/121_secret_code_solution/121_secret_code_solution.ino",
    title: [Geheimcode],
  )

  `playFigure` fährt vorwärts, dreht links, fährt vorwärts und dreht rechts.
  Die Figur ist fest gespeichert. Nach der Figur setzt `handleDigit` den
  Schritt auf 0 zurück. Das Start-Gate bleibt Pflicht: Erst Taste, dann
  Countdown, dann nimmt der Loop Codes an.

  #probiere[
    Ändere `SECRET` auf `{3, 1, 2}`. Jetzt öffnet 3-1-2 das Schloss.
    Die Ziffern selbst bleiben dieselben.
  ]

  = Kamera-Mission

  *Ziel:* Dein Auto folgt einem grünen Gegenstand und stoppt unter 25 cm.
  Der fertige Missions-Sketch liegt unter
  `code/106_follow_color_uno/106_follow_color_mission/`
  `106_follow_color_mission_solution/`
  `106_follow_color_mission_solution.ino`. Er ist Beispiel 106 mit
  Ultraschall und lässt sich direkt übersetzen.

  Der ESP32 sucht Grün, genau wie die Lösung von Kapitel 10. Der Uno liest
  `x` und `w`, lenkt mit Totzone und bremst vor Hindernissen. Drei Stellen
  sind wichtig: `STOP_CM = 25`, `readDistanceCm()` gibt bei fehlendem Echo
  `-1` zurück, und `follow` hält bei `cm < 0` oder `cm < STOP_CM` an.
  `setup` richtet `PIN_TRIG` als Ausgang und `PIN_ECHO` als Eingang ein.
  Ohne diese zwei Zeilen misst der Sensor nicht.

  Die zwei wichtigen Stellen stehen hier. Der Rest ist Beispiel 106.

  #block(
    width: 100%,
    fill: surface,
    stroke: 0.5pt + line-color,
    radius: 2pt,
    inset: 8pt,
  )[
    #text(font: font-mono, size: 8.4pt)[
      // in setup, sonst misst der Sensor nicht
      pinMode(PIN_TRIG, OUTPUT); pinMode(PIN_ECHO, INPUT);
      // in follow, vor dem Lenken
      int cm = readDistanceCm();
      if (cm < 0 || cm < STOP_CM) \{
        stopMotors(); setStatus(CRGB::Red); return;
      \}
    ]
  ]

  Beobachte drei Fälle. Ist die grüne Fläche groß genug, folgt das Auto und
  die LED ist grün. Verschwindet sie aus dem Bild, sucht das Auto im Kreis
  und die LED wird blau. Bleibt das Telegramm drei Sekunden aus, hält das
  Auto an. Kommt der Gegenstand unter 25 cm, stoppt es ebenfalls. In beiden
  Fällen wird die LED rot. Der Ultraschall schaut nur geradeaus. Halte den
  Sensor frei und richte ihn nach vorn.

  #fehler((
    ("Compiler: multiple definition of __vector_11.",
      "Wähle im Bibliotheksmanager FastLED 3.9.15. Mit 3.10.x belegen
      Servo und FastLED beide Timer1."),
    ("Die LED bleibt dunkel.",
      "Prüfe GRB in addLeds und rufe FastLED.show() auf."),
    ("Der Geheimcode reagiert nicht.",
      "Drücke zuerst die Taste auf dem Shield und prüfe die Codes mit dem
      Auslese-Sketch."),
    ("Der Parkwächter meldet ohne Hindernis Alarm.",
      "Weiche und schräge Flächen täuschen den Sensor. Richte ihn gerade
      auf eine ebene Fläche."),
  ))

  #merken[
    - FastLED 3.9.15 und Servo 1.2.2 vertragen sich. Mit FastLED 3.10.x
      bricht der Linker mit `__vector_11` ab.
    - `scanAt` verbindet Drehen, Messen und Anzeigen.
    - Jede Tanzstrophe ist eine Funktion. Feste Zeiten machen den Tanz
      wiederholbar.
    - `SECRET` und `step` prüfen eine Ziffernfolge. `digitFromCommand`
      liest die Familie-A-Tasten aus IRremote 4.x; andere misst du mit 086.
    - Die Kamera-Mission nutzt Grün und stoppt unter 25 cm. Der fertige
      Sketch heißt `106_follow_color_mission_solution.ino`.
  ]

  #checklist((
    [Ich baue den Parkwächter und ändere Alarmgrenze und Schwenkbereich.],
    [Ich schreibe eine eigene Tanzstrophe aus `move`, `setLed` und `wiggleHead`.],
    [Ich gebe den Geheimcode ein und sehe die Figur.],
    [Ich lade die grüne Kamera-Mission und prüfe den Stopp unter 25 cm.],
  ))
]
