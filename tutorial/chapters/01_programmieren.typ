#import "../lib/components.typ": *

#chapter(1, [Programmieren lernen], goal: [
  Du lädst dein erstes Programm auf den Arduino. Du siehst, wie `setup` und
  `loop` zusammenarbeiten, und schreibst Zahlen und Texte in den Serial
  Monitor. Du lernst Variablen, Entscheidungen und Schleifen. Am Ende baust du
  eine eigene Funktion, die aus drei Messwerten einen Mittelwert rechnet.
])[

  = Die Arduino IDE in Kürze

  Der Arduino ist ein kleiner Computer ohne Bildschirm. Du schreibst das
  Programm auf dem PC. Ein Klick schiebt es über das USB-Kabel in den Arduino.
  Die Programmdatei heißt Sketch.

  *Board wählen.* Öffne die Arduino IDE. Unter `Werkzeuge > Board` wählst du
  `Arduino Uno`.

  *Port wählen.* Stecke das USB-Kabel an. Unter `Werkzeuge > Port` steht ein
  Eintrag wie `COM3`. Wähle ihn aus.

  *Hochladen.* Drücke den Pfeil nach rechts. Die IDE übersetzt den Sketch
  und schickt ihn zum Arduino. Nach dem Hochladen startet das Programm sofort.

  *Serial Monitor.* Klicke oben rechts auf das Symbol für den Serial Monitor.
  Stelle unten `9600 Baud` ein. Jetzt siehst du die Texte, die der Arduino
  schickt.

  #achtung[
    Auf dem Shield sitzt der Schalter `Upload/Cam`. Für jedes Hochladen steht
    er auf `Upload`. Nur für die Kamera brauchst du `Cam`. Steht der Schalter
    falsch, findet die IDE den Arduino nicht.
  ]

  #mission[
    Bringe den Arduino dazu, im Serial Monitor zu sprechen. Danach rechnest du
    mit Variablen und baust eine Funktion für den Mittelwert aus drei Zahlen.
  ]

  = So ist ein Sketch aufgebaut

  Ein Sketch besteht aus Zeilen. Vier Regeln helfen dir beim Lesen.

  *Kommentare.* Zwei Schrägstriche `//` beginnen einen Kommentar. Der Arduino
  ignoriert alles bis zum Zeilenende. Kommentare erklären, was der Code tut.

  *Anweisungen.* Jede Anweisung endet mit einem Semikolon. Fehlt es, meldet die
  IDE einen Fehler.

  *Blöcke.* Geschweifte Klammern `{` und `}` fassen mehrere Zeilen zusammen.
  Eine Funktion beginnt mit ihrem Namen und einem Block.

  *Funktionen.* `setup` und `loop` sind Funktionen. Du erkennst sie an den runden
  Klammern. Was darin steht, sind Parameter.

  = Dein erstes Programm

  Jeder Sketch hat zwei feste Teile. `setup` läuft genau einmal, direkt nach dem
  Einschalten oder nach dem Hochladen. `loop` heißt Schleife und wiederholt sich
  endlos, solange der Arduino Strom hat.

  #image("../assets/img/kap01_setup_loop.svg", width: 92%)

  #listing("/code/001_hello_world/001_hello_world_solution/001_hello_world_solution.ino", title: [Hallo Arduino])

  Zeile 2 bis 4 legen fest, an welchen Pins die Motoren hängen. Zeile 6 legt
  den Zähler an. Der Zähler startet bei 0.

  Zeile 8 bis 12 schalten die Motoren ab. Diese Funktion rufen wir in `setup`
  auf, damit das Auto beim Üben sicher stehen bleibt. Die Motoren sind hier nur
  vorbereitet, gefahren wird in Kapitel 2.

  Zeile 14 bis 22 sind `setup`. Die drei `pinMode`-Zeilen machen aus den Pins
  Ausgänge. `Serial.begin(9600)` öffnet den Serial Monitor mit 9600 Baud. Die
  nächste Zeile schickt einen Text.

  Zeile 24 bis 29 sind `loop`. Der Arduino zählt eins hoch, schreibt `Runde` und
  die Zahl, dann wartet er 500 Millisekunden. Danach beginnt `loop` von vorn.
  Im Monitor läuft die Zahl deshalb immer weiter.

  #probiere[
    Ändere `delay(500)` in `delay(2000)`. Lade neu hoch. Jetzt kommt nur noch
    alle zwei Sekunden eine neue Runde.
  ]

  = Der Serial Monitor

  Der Monitor zeigt, was der Arduino sendet. `Serial.begin(9600)` legt die
  Geschwindigkeit fest. 9600 Baud bedeutet 9600 Bit pro Sekunde. Bei der
  üblichen Einstellung 8N1 sind das höchstens etwa 960 Zeichen pro Sekunde.
  Unten im Monitor muss dieselbe Zahl stehen, sonst erscheinen seltsame
  Zeichen.

  `Serial.print` schreibt ohne Zeilenumbruch. `Serial.println` beginnt danach
  eine neue Zeile. Deshalb stehen `Runde 1`, `Runde 2` und `Runde 3`
  untereinander. So sieht die Ausgabe aus:

  ```text
  Hallo! Ich bin der Arduino.
  Runde 1
  Runde 2
  Runde 3
  ```

  Der Arduino sendet nur, solange er Strom hat. Ziehe das USB-Kabel ab, dann
  bleibt der Monitor stehen. Nach dem nächsten Hochladen beginnt die Ausgabe
  wieder von vorn.

  #tipp[
    Unten im Monitor gibt es den Schalter `Autoscroll`. Ist er an, springt die
    Anzeige automatisch nach unten. Bei langen Ausgaben schaltest du ihn aus
    und liest in Ruhe.
  ]

  #pagebreak(weak: false)

  = Variablen

  Eine Variable ist ein beschrifteter Platz im Speicher. Sie hat einen Typ, einen
  Namen und einen Wert. Der Typ sagt, welche Art von Wert hineinpasst.

  #listing("/code/006_variables/006_variables_solution/006_variables_solution.ino", title: [Vier Typen])

  Zeile 5 und 6 legen zwei ganze Zahlen an. `int` steht für eine ganze Zahl ohne
  Komma, zum Beispiel 30 oder 42. Die Kommentare nennen die Einheit Zentimeter.

  Zeile 18 rechnet den Mittelwert. `2.0` enthält einen Punkt. Dadurch rechnet
  der Arduino mit Kommazahlen. Bei `2` ohne Punkt würde er abrunden.

  Der Typ entscheidet über das Ergebnis. `30 / 2` ergibt 15. `31 / 2` ergibt
  ebenfalls 15, weil beide Zahlen `int` sind. Der Rest fällt weg. Mit
  `31 / 2.0` kommt 15.5 heraus. Eine Kommazahl im Ausdruck genügt.

  Zeile 19 prüft, ob der Mittelwert größer als 20 ist. Das Ergebnis ist `true`
  oder `false`. Eine `bool`-Variable merkt sich genau diesen Wahrheitswert.

  Zeile 20 legt einen einzelnen Buchstaben an. `char` speichert ein Zeichen und
  steht in einfachen Anführungszeichen. Zeile 27 gibt `ja` oder `nein` aus. Das
  Fragezeichen wählt den passenden Text aus.

  #pinref((
    ([`int`], [ganze Zahl, zum Beispiel 30]),
    ([`float`], [Kommazahl, zum Beispiel 36.0]),
    ([`bool`], [`true` oder `false`]),
    ([`char`], [ein einzelnes Zeichen, zum Beispiel `A`]),
  ))

  #pagebreak(weak: false)

  = Entscheidungen

  Ein Programm trifft Entscheidungen mit `if`. Der Ausdruck in der Klammer wird
  geprüft. Ist er wahr, läuft der Block darunter. Sonst prüft `else if` die
  nächste Bedingung. `else` fängt alle übrigen Fälle auf.

  #listing("/code/011_decisions/011_decisions_solution/011_decisions_solution.ino", title: [Zu nah, passt, weit weg])

  Zeile 5 bis 7 geben drei Werte vor. `distance` ist der Messwert. `NEAR_CM` und
  `FAR_CM` sind die beiden Schwellen. Große Namen in Großbuchstaben zeigen an,
  dass sich der Wert nicht ändert.

  Zeile 19 fragt: Ist `distance` kleiner als 20? Dann ist das Hindernis zu nah.
  Zeile 21 fragt sonst: Ist `distance` kleiner oder gleich 60? Dann passt der
  Abstand. Alles darüber landet im `else`.

  Diese Zeichen vergleichen zwei Werte:

  #table(
    columns: (auto, 1fr),
    table.header([Zeichen], [Bedeutung]),
    [`==`], [gleich],
    [`!=`], [ungleich],
    [`<`], [kleiner],
    [`>`], [größer],
    [`<=`], [kleiner oder gleich],
    [`>=`], [größer oder gleich],
  )

  Zwei Gleichheitszeichen prüfen. Ein einzelnes `=` weist einen Wert zu. Das ist
  der häufigste Tippfehler am Anfang.

  #pagebreak(weak: false)

  = Schleifen

  Eine Schleife wiederholt Befehle. Die `for`-Schleife zählt eine Variable hoch
  oder herunter. Die `while`-Schleife läuft, solange ihre Bedingung wahr ist.

  #listing("/code/016_loops/016_loops_solution/016_loops_solution.ino", title: [Zählen mit for und while])

  Zeile 17 bis 20 sind die `for`-Schleife. `int i = 3` setzt den Start. `i >= 1`
  ist die Bedingung. `i--` zieht nach jeder Runde eins ab. Die Schleife schreibt
  also 3, 2 und 1.

  Zeile 22 legt den Akkustand auf 3. Zeile 23 prüft vor jeder Runde, ob noch
  etwas übrig ist. Zeile 25 zieht eins ab. Bei 0 endet die Schleife.

  #merken[
    `setup` läuft einmal. `loop` läuft immer weiter. Eine `for`-Schleife zählt
    eine feste Anzahl von Runden. Eine `while`-Schleife hängt von einer
    Bedingung ab.
  ]

  #pagebreak(weak: false)

  = Funktionen und Arrays

  Eine Funktion fasst Befehle zusammen und bekommt einen Namen. Du rufst sie mit
  ihrem Namen auf. Ein Array ist eine Reihe von Werten unter einem Namen. Die
  Werte haben Plätze von 0 an gezählt.

  In der Aufgabe liegen drei Messwerte in einem Array. Du schreibst die Funktion
  `average`. Sie nimmt drei ganze Zahlen, addiert sie und teilt die Summe durch
  `3.0`. Das Ergebnis ist eine Kommazahl.

  Das Array `values` hat drei Plätze. `values[0]` ist 24, `values[1]` ist 30,
  `values[2]` ist 27. Die Summe ist 81. Geteilt durch 3.0 ergibt 27.0. Diesen
  Wert gibt die Funktion mit `return` zurück.

  #gap("/code/021_average/021_average_exercise/021_average_exercise.ino", [
    Ergänze die Funktion `average`. Bilde die Summe aus `a`, `b` und `c` und
    teile sie durch `3.0`. Rufe die Funktion danach mit den drei Array-Werten
    auf und speichere das Ergebnis in `mean`.
  ])

  #notespace(lines: 4)

  #solution("/code/021_average/021_average_solution/021_average_solution.ino", title: [Mittelwert])

  Vergleiche deine Lösung mit dem Listing. Die Summe entsteht in Zeile 13,
  geteilt wird in Zeile 14 durch `3.0`. Zeile 22 ruft die Funktion mit den drei
  Array-Plätzen auf.

  #pagebreak(weak: false)

  = Fehler und Merken

  #fehler((
    ([Der Monitor bleibt leer], [Prüfe `Serial.begin(9600)` und stelle unten im Monitor `9600 Baud` ein.]),
    ([`Runde` erscheint ohne Zahl], [Nutze `Serial.println(counter)` statt `Serial.print`.]),
    ([Die Zahl steigt nicht], [Der Zähler muss in `loop` stehen, in `setup` läuft er nur einmal.]),
    ([`average` liefert 0], [Gib `sum / 3.0` zurück. Ein `return 0` bleibt bei 0.]),
  ))

  #merken[
    Jede Anweisung endet mit einem Semikolon. `setup` läuft einmal, `loop`
    wiederholt sich. `int` speichert ganze Zahlen, `float` Kommazahlen. Ein
    Array zählt seine Plätze ab 0.
  ]

  #checklist((
    [Ich kann einen Sketch hochladen und den Port wählen],
    [Ich sehe Texte im Serial Monitor bei 9600 Baud],
    [Ich kenne den Unterschied zwischen `setup` und `loop`],
    [Ich habe eine Funktion mit Rückgabewert geschrieben],
  ))

]
