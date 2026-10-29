#import "../lib/components.typ": *

#chapter(4, [Linie folgen], goal: [
  Du liest die Rohwerte von drei Liniensensoren.
  Du wählst eine eigene Schwelle für schwarz und weiß.
  Du baust ein Auto, das einer schwarzen Linie folgt.
])[
  #mission[
    Baue ein Auto, das eine schwarze Linie auf hellem Grund findet und
    ihr bis zum Ende folgt.
  ]

  = Drei Sensoren sehen die Linie

  Unter dem Auto sitzen drei kleine Sensoren nebeneinander. Jeder Sensor hat
  eine Infrarot-LED und einen Fototransistor. Die LED strahlt nach unten. Ein
  heller Untergrund wirft viel Licht zurück, schwarzer Untergrund schluckt
  das meiste davon.

  #align(center)[
    #image("/tutorial/assets/img/kap04_sensoren.svg", width: 88%)
  ]

  Der Arduino liest die Helligkeit als Zahl zwischen 0 und 1023. Auf Schwarz
  liegen die Werte ungefähr zwischen 250 und 850. Auf Weiß sind es etwa 1000.
  Liegen alle drei Werte über 950, sieht kein Sensor eine dunkle Linie. Das
  passiert am Linienende oder wenn du das Auto hochhebst. Diese Zahlen hängen
  von Raum, Akku und Untergrund ab, deshalb misst du sie zuerst selbst.

  = Rohwerte lesen

  Dieser Sketch zeigt die Werte aller drei Sensoren im Serial Monitor. Er
  fährt nicht, sondern wartet nur auf den Start und druckt dann weiter.

  Abbildung 4.1 zeigt schon einmal den ganzen Weg: von den drei Sensoren über
  den Fehlerwert bis zu den beiden Motorgeschwindigkeiten.

  #figure(
    numbering: none,
    image("/tutorial/assets/img/kap04_ablauf.svg", width: 100%),
    caption: [Abbildung 4.1: Linie lesen und lenken. Aus dem Muster wird ein Fehler, aus dem Fehler die Lenkung.],
  )

  #listing("/code/051_calibrate_line/051_calibrate_line_solution/051_calibrate_line_solution.ino", title: [Rohwerte anzeigen])

  Zeile 58 bis 65 bilden den Kern. `analogRead` liest die Spannung am Pin und
  macht daraus eine Zahl. Links steht auf A2, in der Mitte auf A1 und rechts
  auf A0. Die Ausgabe wiederholt sich alle 300 Millisekunden.

  = Die Schwelle wählen

  Lege das Auto auf eine weiße Fläche und lies die drei Werte ab. Schiebe es
  dann so, dass alle drei Sensoren auf der schwarzen Linie stehen, und lies
  wieder ab. Notiere beide Zahlenpaare.

  #goalbox(title: "Deine Messung")[
    Schwarz: links ... · mitte ... · rechts ...\
    Weiß: links ... · mitte ... · rechts ...\
    Meine Schwelle: ...
  ]

  Die Schwelle liegt zwischen Schwarz und Weiß. Bei den Werten aus dem
  Kasten sind das zum Beispiel 600. Alles unter 600 gilt als schwarz. Trage
  deine eigene Zahl als `LINE_THRESHOLD` in den nächsten Sketch ein.

  #achtung[
    Die Schwelle gilt nur für diesen Raum und diesen Akkustand. Ein leerer
    Akku macht die LED dunkler, und alle Werte sinken. Miss deshalb vor jeder
    Fahrt neu und passe `LINE_THRESHOLD` an.
  ]

  = Lenken mit einem Fehlerwert

  Der Sketch rechnet aus der Sensorposition einen Fehlerwert:

  #align(center)[
    #table(
      columns: (auto, auto, 1fr),
      table.header([Sensor], [Fehler], [Bedeutung]),
      [links schwarz], [-1], [die Linie liegt links],
      [mitte schwarz], [0], [die Linie liegt mittig],
      [rechts schwarz], [+1], [die Linie liegt rechts],
    )
  ]

  Aus dem Fehler wird die Lenkung: `steer = error * 90`. Bei Fehler +1 ist
  `steer` gleich 90. Der linke Motor bekommt `110 + 90 = 200`, der rechte
  `110 - 90 = 20`. Das Auto zieht nach rechts. Bei Fehler -1 dreht es sich
  andersherum. Bei 0 fahren beide Motoren gleich schnell geradeaus.

  Abbildung 4.1 zeigt diesen Weg noch einmal als Plan.

  Das nennt man proportionale Lenkung: Je weiter die Linie seitlich liegt,
  desto stärker der Ausschlag. Ein PID-Regler macht das feiner, braucht aber
  Kommazahlen und viel Erklärung. Für den Anfang reicht diese einfache Regel.

  Zwei Sonderfälle bekommen ein festes Verhalten. Sehen alle drei Sensoren
  weiß, ist die Linie zu Ende oder das Auto steht neben ihr. Dann stoppt das
  Auto. Sehen alle drei Sensoren schwarz, kann das eine breite Linie oder eine
  Querlinie sein. Auch dann stoppt das Auto kurz. Das Hochheben des Autos ist
  kein Test für "alle schwarz": In der Luft sehen die Sensoren meist weiß.


  = Mission: Linie folgen

  Der Übungssketch ist vollständig und baut so, wie er ist. Es fehlen nur die
  `TODO`-Zeilen in `loop()`.

  #gap("/code/056_line_follow/056_line_follow_exercise/056_line_follow_exercise.ino", [
    Ergänze die `TODO`-Zeilen in `loop()`. Setze den Fehlerwert und berechne
    daraus `steer`. Welche Geschwindigkeit bekommt links, welche rechts?
    Lege fest: Alle drei Sensoren weiß heißt Linienende, das Auto stoppt.
  ])

  #notespace(lines: 6)

  #solution("/code/056_line_follow/056_line_follow_solution/056_line_follow_solution.ino",
    title: [Der Linie folgen])

  #probiere[
    Ändere `BASE_SPEED` von 110 auf 150. Verschiebe danach
    `LINE_THRESHOLD` um 100 nach oben und beobachte die Fahrt.
  ]

  #fehler((
    ([Das Auto dreht sich im Kreis.],
      [Links und rechts sind vertauscht. Prüfe, ob A2 wirklich links und A0
      wirklich rechts sitzt.]),
    ([Das Auto fährt über die Linie hinaus.],
      [Die Schwelle passt nicht. Lies die Rohwerte neu und wähle eine Zahl
      zwischen Schwarz und Weiß.]),
    ([Das Auto hält an und meldet "keine Linie".],
      [Alle drei Sensoren sehen weiß. Das ist das Linienende. Setze das Auto
      wieder auf die Linie oder starte neu.]),
    ([Das Auto hält auf einer breiten Linie an.],
      [Alle drei Sensoren sehen schwarz. Das kann eine breite Linie oder eine
      Querlinie sein. Das Anhalten ist so gewollt.]),
  ))

  #merken[
    Schwarz schluckt Infrarotlicht, Weiß wirft es zurück. Die Schwelle liegt
    zwischen beiden Werten. Der Fehler -1, 0, +1 sagt, wo die Linie liegt,
    und `steer = error * 90` macht daraus eine Lenkbewegung. Sehen alle drei
    Sensoren weiß, ist die Linie zu Ende, und das Auto stoppt.
  ]

  #checklist((
    [Ich kann die drei Rohwerte im Monitor lesen],
    [Ich habe eine eigene Schwelle gemessen und kenne den Fehlerwert],
    [Mein Auto folgt der Linie über eine Kurve],
  ))
]
