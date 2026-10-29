#import "../lib/components.typ": *

#chapter(3, [Ultraschall], goal: [
  Du misst mit dem Ultraschallsensor den Abstand zu einer Wand.
  Du verstehst, warum man die Laufzeit durch 58 teilt.
  Du baust eine Notbremse, die vor einem Hindernis anhält.
])[
  #mission[
    Baue ein Auto, das den Abstand misst und vor einem Hindernis
    rechtzeitig stehen bleibt.
  ]

  = Wie Schall den Abstand misst

  Der Ultraschallsensor arbeitet wie ein Echo in einer Höhle. Er schickt einen
  kurzen Schallimpuls nach vorn. Der Schall fliegt bis zur Wand, wird dort
  zurückgeworfen und kommt als Echo wieder an. Der Sensor misst die Zeit
  zwischen Senden und Empfangen.

  #align(center)[
    #image("/tutorial/assets/img/kap03_schall.svg", width: 88%)
  ]

  Schall legt in der Luft etwa 34 000 Zentimeter pro Sekunde zurück. Das sind
  0.034 Zentimeter in einer Mikrosekunde. Der Schall fliegt den Weg zweimal:
  hin und zurück. Ein Zentimeter Abstand kostet deshalb
  `2 / 0.034 = 58` Mikrosekunden Laufzeit. Aus der gemessenen Zeit bekommst du
  den Abstand mit einer einzigen Division:

  $ "Abstand in cm" = "Laufzeit in µs" / 58 $

  Der Arduino wartet höchstens 25 000 Mikrosekunden auf das Echo. Das sind
  gut vier Meter. Kommt in dieser Zeit nichts zurück, ist die Messung
  ungültig. Das passiert, wenn das Hindernis den Schall schluckt oder schräg
  wegwirft. Der Sketch gibt dann `-1` zurück, und das Auto hält an.

  = Der Sensor am Auto

  Der Sensor sitzt vorn am Auto. Zwei Pins verbinden ihn mit dem Arduino:
  D13 schickt den Impuls, D12 empfängt das Echo.

  #pinref((
    ("D13", "TRIG: löst einen Schallimpuls aus"),
    ("D12", "ECHO: bleibt HIGH, solange das Echo läuft"),
    ("5V, GND", "Versorgung des Sensors"),
  ))

  = Abstand messen

  Der Sketch misst alle 200 Millisekunden. Damit die Anzeige ruhiger wird,
  mittelt er drei Messungen.

  #listing("/code/041_distance/041_distance_solution/041_distance_solution.ino", title: [Abstand anzeigen])

  Zeile 42 bis 53 enthalten `readDistanceCm`. Zuerst zieht der Arduino TRIG
  für 2 Mikrosekunden auf LOW, dann für 10 Mikrosekunden auf HIGH. Diese
  10 Mikrosekunden sind der Startbefehl für den Sensor.

  Danach misst `pulseIn` in Zeile 48, wie lange ECHO auf HIGH bleibt. Die
  Zahl 25000 ist das Zeitlimit in Mikrosekunden. Ohne eigenes Limit würde
  `pulseIn` etwa eine Sekunde warten. Das ist zu lang für eine Notbremse,
  deshalb steht das kurze Limit hier ausdrücklich im Aufruf.

  Zeile 49 bis 52 prüfen das Ergebnis. Bei 0 gibt der Sensor `-1` zurück.
  Sonst teilt Zeile 52 die Laufzeit durch 58 und schneidet die
  Nachkommastellen ab.

  Zeile 55 bis 66 mitteln drei Messungen. Ist eine davon ungültig, gibt auch
  der Mittelwert `-1` zurück. Zwischen den Messungen wartet der Sketch
  20 Millisekunden, damit der Sensor nicht in sein eigenes Echo hineinhört.
  Zeile 82 bis 91 geben den Wert aus und warten 200 Millisekunden bis zur
  nächsten Runde.

  #probiere[
    Halte deine Hand in verschiedenen Abständen vor den Sensor. Vergleiche die
    Zahlen im Serial Monitor mit einem Lineal. Ändere dann in Zeile 90 die
    Pause von 200 auf 500 Millisekunden.
  ]

  = Wenn die Messung danebenliegt

  Der Sensor ist kein Lineal. Drei Fälle machen ihm zu schaffen:

  - *Weiche Stoffe* wie Wolle oder ein Pullover schlucken einen Teil des
    Schalls. Das Echo ist leise, der Wert wird zu groß.
  - *Schräge Flächen* werfen den Schall zur Seite. Er kommt nicht zum Sensor
    zurück, und der Sketch meldet `-1`.
  - *Unter 2 cm* kann der Sensor Senden und Empfangen nicht trennen. Die
    Messung wird ungenau oder liefert `-1`.

  Für die Notbremse ist das wichtig. Ein fehlendes Echo heißt nicht, dass der
  Weg frei ist. Das Auto behandelt `-1` wie ein Hindernis und hält an. So
  bleibt es auch bei einem weichen oder schrägen Hindernis stehen, statt
  weiterzufahren.

  = Mission: Notbremse

  Jetzt fährt das Auto los und bremst bei 20 cm. Der Übungssketch ist schon
  vollständig. Er misst, entscheidet und fährt. Es fehlen nur die beiden
  `TODO`-Zeilen in `loop()`. Die neuen Konstanten stehen oben bei den Pins.

  Abbildung 3.1 zeigt die Entscheidung: Ist der Abstand kleiner als 20 cm,
  stoppt das Auto. Sonst fährt es weiter und misst in der nächsten Runde neu.

  #figure(
    numbering: none,
    image("/tutorial/assets/img/kap03_ablauf.svg", width: 100%),
    caption: [Abbildung 3.1: Messen und entscheiden. Ein Timeout ist eine ungültige Messung, dann stoppt das Auto.],
  )

  #gap("/code/046_stop_before_wall/046_stop_before_wall_exercise/046_stop_before_wall_exercise.ino", [
    Ergänze die beiden `TODO`-Zeilen. Überlege zuerst: Welche Funktion hält
    das Auto an, welche lässt es fahren? Die Schwelle steht in
    `STOP_DISTANCE_CM`.
  ])

  #notespace(lines: 4)

  #solution("/code/046_stop_before_wall/046_stop_before_wall_solution/046_stop_before_wall_solution.ino",
    title: [Notbremse bei 20 cm])

  #fehler((
    ([Im Monitor steht dauernd "keine Messung".],
      [Prüfe TRIG auf D13 und ECHO auf D12. Halte den Sensor frei und richte
      ihn gerade auf eine Wand. Kommt kein Echo, gibt der Sketch `-1` aus.]),
    ([Die Werte springen wild hin und her.],
      [Mittle drei Messungen wie in `readAverageCm`. Halte mindestens 2 cm
      Abstand und ziele auf eine ebene Fläche.]),
    ([Das Auto bremst nie.],
      [Lies im Monitor mit: Fällt der Wert wirklich unter 20? Sonst erhöhe
      `STOP_DISTANCE_CM` auf 30.]),
  ))

  #merken[
    Der Sensor misst die Laufzeit des Schalls, nicht den Abstand direkt.
    Ein Zentimeter Hin- und Rückweg dauert 58 Mikrosekunden.
    `pulseIn` bekommt hier ein kurzes Zeitlimit. Ohne eigenes Limit wartet
    es etwa eine Sekunde. Weiche und schräge Flächen liefern keine gültige
    Messung. Der Sketch gibt dann `-1` zurück und das Auto hält an.
  ]

  #checklist((
    [Ich kann den Abstand im Serial Monitor ablesen],
    [Ich weiß, warum durch 58 geteilt wird],
    [Ich kann das Zeitlimit von `pulseIn` erklären],
    [Mein Auto hält vor einem Hindernis an],
  ))
]
