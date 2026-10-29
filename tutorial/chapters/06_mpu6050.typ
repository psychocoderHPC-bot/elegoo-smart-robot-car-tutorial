#import "../lib/components.typ": *

#chapter(6, [MPU6050], goal: [
  Der MPU6050 ist ein Chip mit zwei Sensoren. Der eine misst Beschleunigung,
  der andere die Drehung. Du liest beide über zwei dünne Kabel aus.
  Am Ende zeigt dein Auto seine Neigung an und warnt bei einem kräftigen
  Stoß mit roter LED.
])[
  #mission[
    Baue einen Neigungsmesser und einen Stoßalarm. Der Bildschirm zeigt Roll
    und Pitch in Grad. Bei einem Stoß leuchtet die LED zwei Sekunden lang.
  ]

  = Zwei Sensoren in einem Chip

  Der MPU6050 steckt auf einer kleinen Platine, dem GY-521-Modul. In seinem
  Gehäuse arbeiten zwei Sensoren.

  Der Beschleunigungssensor misst, wie stark das Auto beschleunigt wird. Er
  spürt auch die Erdanziehung. Ein Auto in Ruhe misst deshalb nicht 0,
  sondern etwa 9,8 Meter pro Sekunde zum Quadrat, kurz m/s². Das ist die
  Fallbeschleunigung `g`.

  Der Gyrosensor misst, wie schnell sich das Auto dreht. Die Adafruit-
  Bibliothek liefert diesen Wert in Radiant pro Sekunde, kurz rad/s. Der
  nächste Abschnitt zeigt, was Radiant bedeutet.

  = Anschluss und Adresse

  Das Modul hängt am I2C-Bus. I2C braucht nur zwei Datenleitungen. Beim Uno
  sind das A4 und A5. A4 ist `SDA` und trägt die Daten. A5 ist `SCL` und gibt
  den Takt vor. Das Shield verbindet beide Leitungen mit dem MPU6050.

  Jedes I2C-Gerät hat eine Adresse. Der MPU6050 antwortet auf `0x68`. Diese
  Zahl steht in der Bibliothek als Standardwert, du musst sie nicht selbst
  setzen.

  #tipp[
    `0x68` ist eine Hexadezimalzahl. Hex-Zahlen haben 16 Ziffern: erst 0 bis 9,
    dann A, B, C, D, E und F. Dabei ist A gleich 10, B gleich 11 und so weiter
    bis F gleich 15. Die zwei Zeichen `0x` zeigen nur: Diese Zahl ist zur
    Basis 16 geschrieben. `0x68` heißt also 6 mal 16 plus 8, das sind 104.
    Für den Sketch musst du nichts umrechnen. Du tippst die Adresse genau so
    ab, wie sie in der Bibliothek steht.
  ]

  #pinref((
    ("A4", "SDA, Datenleitung"),
    ("A5", "SCL, Taktleitung"),
    ("0x68", "I2C-Adresse des MPU6050"),
  ))

  = Grad statt Bogenmaß

  Ein Winkel lässt sich auf zwei Arten schreiben: in Grad oder in
  Bogenmaß. Das Bogenmaß benutzt die Länge des Kreisbogens. Ein Bogen
  der Länge r spannt den Winkel 1 rad auf.

  Eine volle Drehung sind 360 Grad. Als Bogenmaß sind das 2 pi rad, also
  6,28 rad. Daraus folgt: 1 rad sind rund 57,3 Grad.

  #figure(
    numbering: none,
    image("../assets/img/kap06_grad_rad.svg", width: 100%),
    caption: [Abbildung 6.1: Ein Bogen der Länge r ergibt 1 rad. 90 Grad sind 1,57 rad, 180 Grad sind 3,14 rad, 360 Grad sind 6,28 rad.],
  )

  Zwei Merksätze reichen:
  - 360 Grad = 2 pi rad = 6,28 rad.
  - 1 rad = 57,3 Grad.

  In Abbildung 6.1 siehst du beide Schreibweisen nebeneinander. Der Sketch
  rechnet die Gyro-Werte mit `GYRO_RAD_TO_DEG` um. In der Ausgabe steht dann
  `deg/s` statt `rad/s`.

  = Neigung messen

  Das erste Programm liest den Sensor alle 200 Millisekunden. Aus den drei
  Beschleunigungswerten `ax`, `ay` und `az` berechnet es zwei Winkel. Roll
  kippt nach links oder rechts. Pitch hebt oder senkt die Nase.

  #listing("/code/071_tilt/071_tilt_solution/071_tilt_solution.ino", title: [Roll und Pitch])

  Zeile 2 bis 4 binden die Bibliotheken ein. Zeile 15 erzeugt das Objekt
  `mpu`, Zeile 16 drei Speicher für die Messwerte. Ab Zeile 59 startet
  `mpu.begin()` den Sensor. Schlägt das fehl, bleibt das Programm in einer
  Endlosschleife und schreibt eine Meldung auf den seriellen Monitor.

  Zeile 73 holt einen neuen Satz Messwerte. `getEvent()` füllt
  `accel`, `gyro` und `temp` auf einmal. Die drei Beschleunigungswerte stehen
  in Zeile 75 bis 77. Zeile 80 rechnet Roll, Zeile 82 rechnet Pitch. Beide
  Formeln nutzen `atan2()`, eine Umkehrfunktion des Tangens.

  Zeile 84 bis 100 rechnen die Drehrate in Grad pro Sekunde um. Die drei
  Werte stehen als `deg/s` im seriellen Monitor.

  Die Achsen hängen vom Einbau ab. Hier gilt: x zeigt nach vorn, y nach
  links, z nach oben. Liegt das Auto gerade, zeigt `az` ungefähr 9,8 und die
  beiden anderen Werte liegen bei 0. Kippst du zur Seite, ändert sich `ay`.

  #achtung[
    `mpu.begin()` kalibriert den Sensor nicht auf die aktuelle Lage. Es startet
    nur die Kommunikation. Die angezeigten Winkel sind immer eine frische
    Messung. Lege das Auto für einen festen Nullpunkt gerade hin und notiere
    die Werte als Vergleich. Bewege das USB-Kabel nicht, es zieht am Auto.
  ]

  #probiere[
    Kippe das Auto langsam nach vorn. Beobachte, wie Pitch größer wird.
    Tausche dann in Zeile 78 `ay` und `az`. Schon zeigt Roll etwas anderes.
    Mit diesem Tausch findest du heraus, wie dein Modul eingebaut ist.
  ]

  = Zittern und Driften

  Der Beschleunigungssensor ist für Neigung gut geeignet. Der Gyrosensor
  misst Drehungen, doch sein Wert ist nie exakt null. Kleine Fehler summieren
  sich auf, wenn du ihn über die Zeit addierst. Man nennt das Driften.

  Mit dem Gyro könntest du eine 90-Grad-Drehung abschätzen. Dazu müsstest
  du die Drehgeschwindigkeit jeden Moment mit der Zeit multiplizieren und
  alles aufaddieren. Nach wenigen Sekunden wäre das Ergebnis sichtbar falsch.
  Deshalb bauen wir diese Drehung nicht. Für eine gerade Fahrt und für
  Neigung reicht der Sensor trotzdem gut aus.

  = Mission: Stoßalarm

  Jetzt misst das Programm die Länge des Beschleunigungsvektors. Dafür
  quadriert es `ax`, `ay` und `az`, addiert die drei Quadrate und zieht die
  Wurzel. In Ruhe ergibt das etwa 9,8 m/s². Ein kräftiger Stoß treibt den
  Wert über 14 m/s².

  #gap("/code/076_shake/076_shake_exercise/076_shake_exercise.ino", [
    Berechne `total` mit der Wurzel aus den drei Quadraten. Vergleiche den
    Wert mit `SHAKE_LIMIT`. Ist er größer, rufe `warnTwoSeconds(total)` auf.
  ])

  #notespace(lines: 4)

  #solution(
    "/code/076_shake/076_shake_solution/076_shake_solution.ino",
    title: [Mission Stoßalarm],
  )

  Die Schwelle steht in Zeile 13. Zeile 49 bis 60 zeigen die Warnung: rote
  LED, Meldung auf dem seriellen Monitor, zwei Sekunden warten, LED aus. Die
  Zeit misst das Programm mit `millis()`.
  Zeile 99 berechnet die Länge, Zeile 100 vergleicht sie mit der Schwelle.

  Die LED auf dem Shield ist ein WS2812. Sie braucht die Bibliothek FastLED,
  die du im Lichtkapitel genauer kennenlernst.

  #fehler((
    ("Der Monitor zeigt: MPU6050 nicht gefunden.", "Prüfe die Kabel. A4 muss an SDA liegen, A5 an SCL. Sitzt das Modul fest auf dem Shield?"),
    ("Roll und Pitch springen wild.", "Das USB-Kabel wackelt oder das Auto steht nicht ruhig. Lege das Kabel locker und starte neu."),
    ("Der Stoßalarm löst nie aus.", "Die Schwelle ist zu hoch. Setze `SHAKE_LIMIT` auf 12 und klopfe leicht gegen das Gehäuse."),
    ("Die LED bleibt rot.", "Das Programm hängt in der Warteschleife. Prüfe, ob `WARN_MS` eine ganze Zahl ist und ob `FastLED.show()` aufgerufen wird."),
  ))

  #merken[
    Der MPU6050 enthält einen Beschleunigungssensor und einen Gyrosensor.
    Er hängt an A4 (SDA) und A5 (SCL) und antwortet auf Adresse `0x68`.
    `getEvent()` liefert Beschleunigung, Drehung und Temperatur.
    Aus `ax`, `ay` und `az` berechnest du Roll und Pitch.
    Der Gyro driftet. Eine Drehung per Addition über die Zeit wird ungenau.
  ]

  #checklist((
    [Ich kann den MPU6050 anschließen und im seriellen Monitor auslesen.],
    [Ich weiß, was Beschleunigung und was Drehgeschwindigkeit ist.],
    [Ich kann Roll und Pitch in Grad berechnen.],
    [Ich kann einen Stoß erkennen und zwei Sekunden warnen.],
  ))
]
