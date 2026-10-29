#import "../lib/components.typ": *

#chapter(8, [Kamera und WLAN], goal: [
  Du verbindest dein Handy mit der Kamera des Autos. Du siehst das Bild
  im Browser und steuerst das Auto über das WLAN. Danach verstehst du,
  wie Handy, ESP32 und Uno miteinander reden.
])[
  #mission[
    Baue eine Fernsteuerung über das eigene WLAN und fahre das Auto per
    Tastendruck im Serial Monitor. Die Kamera zeigt dir dabei das Bild
    nach vorn.
  ]

  = Ein eigenes WLAN im Auto

  Auf dem Kamera-Modul sitzt ein ESP32-WROVER. Er ist ein eigener
  kleiner Computer mit WLAN. Der ESP32 öffnet einen eigenen
  WLAN-Kreis. Dein Handy verbindet sich direkt damit, ohne Router und
  ohne Internet.

  Der Name des WLANs beginnt mit `ELEGOO-`. Dahinter stehen 12
  Hexzeichen aus der MAC-Adresse des Moduls. Jedes Auto hat einen
  anderen Namen, zum Beispiel `ELEGOO-A1B2C3D4E5F6`. Ein Passwort ist
  ab Werk nicht gesetzt. Der Kanal ist fest auf 9 gestellt.

  #achtung[
    Das WLAN hat kein Passwort. Jeder in Reichweite kann es sehen und
    betreten. Nutze es nur in deinem Zimmer und lasse niemanden
    Fremdes mit dem Auto verbinden.
  ]

  = Mit dem Handy verbinden

  Schalte das Auto ein. Warte, bis der ESP32 gestartet ist. Das dauert
  einige Sekunden. Öffne dann auf dem Handy die WLAN-Einstellungen.
  Suche den Namen `ELEGOO-...` und tippe darauf. Ein Passwort wird nicht
  verlangt.

  Danach öffnest du die App `ElegooKit`. Sie gibt es für Android und
  für das iPhone. Alternativ öffnest du den Browser und rufst
  `http://192.168.4.1/` auf. Dort findest du die Steuerung. Das reine
  Bild zeigt `http://192.168.4.1/Test`. Das Standardbild ist 800 mal
  600 Pixel groß.

  Am Kamera-Modul leuchten zwei kleine LEDs. Ihre Bedeutung hilft beim
  Suchen:

  #pinref((
    ("Rot blinkt", "Die Verbindung ist schlecht. Prüfe das 4-Pin-Kabel
      und stecke es neu."),
    ("Grün blinkt", "Der ESP32 läuft, aber das Handy ist noch nicht
      verbunden."),
    ("Grün leuchtet", "Das Handy ist verbunden. Das Bild kann kommen."),
  ))

  = Der Schalter Upload und Cam

  Auf dem Shield sitzt ein kleiner Schalter mit zwei Stellungen:
  `Upload` und `Cam`. Er entscheidet, wer mit dem USB-Anschluss und der
  Leitung zum Uno spricht.

  In Stellung `Upload` programmiert die Arduino IDE den Uno. Der USB-
  Anschluss gehört dann dem Uno. Jedes Mal, wenn du ein neues Programm
  hochlädst, muss der Schalter auf `Upload` stehen. Sonst meldet die IDE
  einen Fehler oder das Programm landet nicht auf dem Uno.

  In Stellung `Cam` gehört die Leitung dem ESP32. Der ESP32 nimmt die
  Befehle vom Handy an und gibt sie an den Uno weiter. Für die
  Handy-Steuerung und das Kamerabild ist das die richtige Stellung.

  Merke dir die Reihenfolge: erst `Upload` und Programm hochladen, dann
  `Cam` und Handy verbinden. Wenn du später ein neues Programm
  aufspielst, schaltest du wieder auf `Upload`.

  #achtung[
    Stecke das Kamera-Modul nie ab, solange der Akku eingeschaltet ist.
    Schalte das Auto zuerst aus, dann ziehe das 4-Pin-Kabel. Sonst
    können Kamera und Shield Schaden nehmen.
  ]

  = Wie Uno und ESP32 reden

  Der ESP32 und der Uno sind mit einer seriellen Leitung verbunden. Sie
  läuft mit 9600 Baud. Der ESP32 schickt kurze Textstücke im
  JSON-Format. Ein Befehl endet immer mit `}`.

  `N` wählt die Funktion. `D1`, `D2` und `D3` sind Werte für diese
  Funktion. `H` ist eine laufende Nummer, die der ESP32 vergibt. Der
  Uno antwortet mit `{"ID_ok"}` oder einem Messwert.

  #achtung[
    Diese JSON-Befehle gehören zur Werksfirmware auf ESP32 und Uno.
    Deine eigenen Sketches aus diesem Buch, zum Beispiel 096 und 131,
    lesen dieses JSON nicht. Die App steuert sie deshalb nicht
    automatisch. Für eigene Programme nutzt du den Serial Monitor oder
    die eigene ESP32-Firmware aus Kapitel 10.
  ]

  #goalbox(title: "Drei Befehle aus der App")[
    #table(
      columns: (auto, 1fr),
      table.header([Befehl], [Bedeutung]),
      [`{"N":100}`], [Alles anhalten],
      [`{"H":1,"N":1,"D1":0,"D2":128,"D3":1}`],
      [Motor: `D1` 0 = beide, `D2` = 128 von 255, `D3` 1 = vorwärts],
      [`{"H":3,"N":5,"D1":1,"D2":90}`],
      [Servo: `D1` 1 = links/rechts, `D2` = 90 Grad],
    )
  ]

  Die App schickt diese Befehle an die Werksfirmware. Du musst sie
  nicht selbst tippen. Für das Verständnis reicht: Der ESP32 übersetzt
  deinen Fingertipp in JSON, der Uno der Werksfirmware führt ihn aus.
  Ein eigener Sketch wie 096 ignoriert diese Zeilen.

  = Zwei Gehirne im Auto

  Im Auto arbeiten zwei Computer. Der ESP32 sitzt an der Kamera. Er nimmt
  das Bild auf, komprimiert es und schickt es über WLAN an dein Handy.
  Auf Wunsch sucht er auch Gesichter. Der Uno steuert die Motoren und den
  Servo. Vom ESP32 bekommt er nur kurze Befehle.

  #image("../assets/img/kap08_datenfluss.svg", width: 100%)

  #text(size: 8pt)[Der Weg vom Bild zum Befehl.]

  Der ESP32 rechnet, der Uno fährt. Sie tauschen kurze Textbefehle aus.
  Mehr braucht der Uno nicht. Er muss nicht wissen, wie das Bild
  aussieht. Er muss nur wissen, wohin er fahren soll.

  #achtung[
    Kapitel 10 ersetzt die Werksfirmware des ESP32. Danach ist die
    Kamera-App aus diesem Kapitel nicht mehr unverändert nutzbar. Der
    Rückweg mit `esptool` ist im Buch beschrieben, aber noch nicht am
    Gerät getestet. Probiere ihn vorher mit einer erwachsenen Person aus
    und halte die Originaldatei bereit. Ohne getesteten Rückweg behandle
    Kapitel 10 als betreutes Zusatzprojekt.
  ]

  = Warum der Uno kein Bild liest

  Der Uno hat keinen Anschluss für die Kamera. Das Kamerakabel endet am
  ESP32. Selbst mit einem Adapter würde es nicht reichen:

  - Der Uno hat 2 KB RAM. Ein Bild passt nicht hinein.
  - Sein Takt liegt bei 16 MHz. Für Bildverarbeitung ist das zu langsam.
  - Die Leitung schafft 9600 Baud, etwa 1 KB pro Sekunde. Ein JPEG ist
    10 bis 20 KB groß.

  Ein Bild bräuchte also 10 bis 20 Sekunden. So lange kann das Auto nicht
  warten. Der ESP32 erledigt die Bildarbeit und schickt nur das Ergebnis.

  #pagebreak(weak: false)

  = Gesichtserkennung ausprobieren

  Die Kamera-Firmware kann Gesichter finden. Du lädst dafür nichts nach.
  So probierst du es aus:

  + Verbinde dein Handy mit dem WLAN `ELEGOO-...`.
  + Stelle die Bildgröße auf QVGA, also 320 mal 240 Pixel. Die Erkennung
    läuft nur bei einer Bildbreite bis 400 Pixel.
  + Öffne im Browser
    `http://192.168.4.1/control?var=face_detect&val=1`.
  + Öffne danach `http://192.168.4.1/Test`. Gesichter bekommen einen
    Rahmen im Bild.

  Mit `val=0` schaltest du die Erkennung wieder aus. Willst du eine
  Person wiedererkennen, ersetze in der Adresse `face_detect` durch
  `face_recognize`. Danach rufst du die Adresse mit `face_enroll`
  auf. Halte das Gesicht fünf Mal in die Kamera. Mit `face_enroll` und
  `val=0` beendest du das Anlernen. Die gelernten Gesichter liegen nur
  im Arbeitsspeicher. Nach dem Ausschalten lernst du neu an.

  #goalbox(title: "Messaufgabe")[
    Halte dein Gesicht in die Kamera und fülle die Tabelle aus. Probiere
    jede Entfernung bei hellem Licht und im Dunkeln.

    #table(
      columns: (auto, auto, auto, 1fr),
      table.header([Entfernung], [Hell], [Dunkel], [Notizen]),
      [0,5 m], [ja / nein], [ja / nein], [],
      [1 m], [ja / nein], [ja / nein], [],
      [2 m], [ja / nein], [ja / nein], [],
      [3 m], [ja / nein], [ja / nein], [],
    )
  ]

  = Follow nutzt den Ultraschall

  In der App gibt es einen Modus `Follow`. Der Name klingt nach
  Bildverfolgung. Gemeint ist Abstand halten.

  Im Uno-Code heißt die Funktion `ApplicationFunctionSet_Follow`. Sie
  liest den Ultraschallsensor, schwenkt den Servo nach links und rechts
  und fährt in die Richtung, in der es frei ist. Die Kamera kommt darin
  nicht vor. Die App schickt nur den Modusbefehl `N=101` mit `D1=3` und
  wählt damit den Modus aus.

  #goalbox(title: "Ausblick")[
    Eine eigene ESP32-Firmware könnte den Mittelpunkt einer Farbe
    berechnen. Sie schickt dann `{"x":120,"w":40}` an den Uno. `x` ist
    die Mitte in Pixeln, `w` die Breite. Bei QVGA liegt die Bildmitte
    bei 160. Der Uno vergleicht `x` mit 160 und lenkt nach. In Kapitel 10
    bauen wir genau das. In diesem Kapitel bleibt der Uno bei den
    Buchstaben.
  ]

  = Mission: Buchstaben statt JSON

  Im Serial Monitor kannst du den Uno auch ohne ESP32 steuern. Öffne
  den Serial Monitor mit 9600 Baud. Tippe einen Buchstaben und drücke
  Enter:

  - `v` fährt vorwärts
  - `z` fährt rückwärts
  - `l` dreht links
  - `r` dreht rechts
  - `s` hält an
  - `q` macht langsamer, `e` schneller

  Der Sketch liest mit `Serial.read()` genau ein Zeichen. Das Start-Gate
  bleibt Pflicht. Erst Taste auf dem Shield, dann Countdown, dann nimmt
  der Loop Buchstaben an.

  `q` und `e` wirken sofort, auch während der Fahrt. Der Sketch merkt
  sich die aktuelle Richtung in `dirLeft` und `dirRight`. Nach einer
  Tempoänderung gibt er diese Richtung mit dem neuen Tempo erneut aus.
  Du musst also keine Richtungstaste nachdrücken.

  Nach dem letzten gültigen Befehl läuft eine Uhr. Kommt eine Sekunde
  lang nichts, hält der Sketch an. So stoppt das Auto, wenn du das
  Kabel ziehst, und es fährt nicht endlos weiter, wenn die Verbindung
  abreist.

  #listing("/code/096_serial_remote/096_serial_remote_solution/096_serial_remote_solution.ino",
    title: [Fahren mit Buchstaben])

  `setup` richtet den Serial Monitor ein und wartet auf das Gate.
  `loop` liest ein Zeichen, ruft `handleKey` auf und prüft den Watchdog.
  `handleKey` speichert die Richtung und ruft `applyDrive` auf. Bei `l`
  bekommt der linke Motor einen negativen Wert und der rechte einen
  positiven. So dreht das Auto auf der Stelle. Ändert `q` oder `e` das
  Tempo, gibt `applyDrive` die gespeicherte Richtung sofort neu aus.

  #probiere[
    Tippe `v` und warte zwei Sekunden. Tippe dann `s`. Das Auto hält an.
    Tippe `l` und danach `s`. Beobachte, in welche Richtung es sich
    dreht.
  ]

  #pagebreak(weak: false)

  = Aufgabe: Schneller und langsamer

  Jetzt bekommt die Steuerung zwei neue Tasten. `q` macht das Auto um
  20 Stufen langsamer, `e` um 20 Stufen schneller. Das Tempo bleibt
  zwischen 60 und 220. Außerhalb dieser Grenzen passiert nichts.

  #gap("/code/096_serial_remote/096_serial_remote_exercise/096_serial_remote_exercise.ino", [
      Öffne die Übungsdatei. Sie ist vollständig und baut sofort.
      Ergänze in `handleKey` die beiden Fälle für `q` und `e`. Prüfe mit
      `speed > SPEED_MIN` und `speed < SPEED_MAX`, ob die Änderung
      erlaubt ist. Der Watchdog und die gespeicherte Richtung sind schon
      fertig.
    ])
  #notespace(lines: 6)

  #solution("/code/096_serial_remote/096_serial_remote_solution/096_serial_remote_solution.ino",
    title: [Mission Tempo])

  #achtung[
    Datenschutz: Das WLAN ist offen und reicht bis in den Garten. Lass
    das Auto nicht unbeaufsichtigt mit eingeschaltetem WLAN stehen.
    Verbinde nur dein eigenes Handy. Schalte das Auto aus,
    wenn du nicht fährst.
  ]

  #fehler((
    ("Kein WLAN `ELEGOO-...` zu sehen.",
     "Warte 10 Sekunden nach dem Einschalten. Prüfe den Akku und das
      4-Pin-Kabel. Leuchtet keine LED am Modul, startet der ESP32
      nicht."),
    ("Das Bild bleibt schwarz.",
     "Prüfe den Schalter: Für die Handy-Steuerung muss er auf `Cam`
      stehen. Stecke das 4-Pin-Kabel bei ausgeschaltetem Auto neu ein."),
    ("Die App findet das Auto, aber es fährt nicht.",
     "Die App steuert nur die Werksfirmware. Mit 096 oder 131 im Uno
      ignoriert der Sketch das JSON; nutze dann den Serial Monitor. Mit
      Werksfirmware: Drücke die Taste auf dem Shield und prüfe, ob der
      Schalter auf `Cam` steht."),
    ("Der Stream öffnet sich nicht.",
     "Tippe die Adresse genau ein: `http://192.168.4.1/Test`. Achte auf
      `http` und die Punkte. Das Handy muss im WLAN `ELEGOO-...` sein."),
  ))

  #merken[
    - Der ESP32 öffnet ein eigenes WLAN `ELEGOO-` plus 12 Hexzeichen.
    - `Upload` ist für Uno-Programme, `Cam` für Handy und Kamera.
    - Der ESP32 rechnet und erkennt, der Uno fährt.
    - Der Uno kann kein Bild lesen: 2 KB RAM und 9600 Baud reichen nicht.
    - `face_detect=1` schaltet die Gesichtserkennung ein.
    - `Follow` nutzt Ultraschall und Servo, nicht die Kamera.
    - Die App steuert nur die Werksfirmware, nicht eigene Sketches.
    - Ohne neuen Befehl stoppt 096 die Motoren nach einer Sekunde.
    - `q` und `e` wirken sofort, weil die Richtung gespeichert ist.
  ]

  #checklist((
    [Ich verbinde mein Handy mit dem WLAN des Autos.],
    [Ich öffne das Kamerabild im Browser oder in der App.],
    [Ich erkläre den Unterschied zwischen `Upload` und `Cam`.],
    [Ich fahre das Auto mit `v`, `z`, `l`, `r` und `s`.],
    [Ich ändere das Tempo mit `q` und `e`, auch während der Fahrt.],
    [Ich erkläre, dass die App nur die Werksfirmware steuert.],
    [Ich erkläre den Watchdog nach dem letzten Befehl.],
    [Ich erkläre, warum der Uno kein Kamerabild verarbeitet.],
    [Ich schalte die Gesichtserkennung im Browser ein.],
    [Ich schalte den Akku aus, bevor ich das Kamerakabel anfasse.],
  ))
]
