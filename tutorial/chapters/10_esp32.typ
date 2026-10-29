#import "../lib/components.typ": *

#chapter(10, [ESP32 selbst programmieren], goal: [
  Du spielst ein eigenes Programm auf den ESP32. Es sucht eine Farbe im
  Kamerabild und schickt die Mitte an den Uno. Der Uno fährt dem farbigen
  Punkt nach. Du änderst die Farbe und baust eine ruhige Lenkung ein.
])[
  #mission[
    Baue ein Auto, das einem grünen Gegenstand folgt. Der ESP32 rechnet,
    der Uno lenkt. Zuerst testest du die Erkennung mit einem roten
    Gegenstand, am Ende sucht der Sketch Grün.
  ]

  = Warum eigene Firmware

  Auf dem ESP32 läuft ab Werk eine fertige Firmware. Sie macht das Bild
  für die App und nimmt Befehle vom Handy an. Eine Position schickt sie
  nicht. Für die Farbverfolgung fehlt ihr genau diese Zahl.

  Darum schreibst du ein eigenes Programm. Der ESP32 holt ein Bild,
  sucht die Farbe und schickt zwei Zahlen an den Uno: die Mitte `x` und
  die Breite `w` des Farbflecks. Der Uno muss das Bild nie sehen.

  #achtung[
    *Achtung, dieser Schritt überschreibt die Werksfirmware.* Danach
    gehen App und Kamerabild über WLAN nicht mehr. Ohne die alte Datei
    gibt es keinen einfachen Rückweg. Lass dir dabei helfen und lies
    zuerst den Abschnitt „Werksfirmware zurückholen“ unten.
  ]

  = Firmware aufspielen

  + Öffne die Arduino IDE. Wähle als Board `ESP32 Dev Module`.
  + Stelle die Partition auf `Huge APP (3MB No OTA/1MB SPIFFS)`.
  + Schalte `PSRAM` auf `enabled`.
  + Stelle die Upload-Geschwindigkeit auf `115200`.
  + Schiebe den Schalter am Shield auf `Cam`.
  + Stecke das USB-Kabel am Uno ein. Der Schalter führt die Leitung zum
    ESP32.
  + Drücke auf Hochladen. Der ESP32 startet nach dem Flashen neu.

  = Werksfirmware zurückholen

  Diesen Rückweg *musst du am Gerät testen*, bevor du ihn im Kurs
  einsetzt. Er ist hier nicht am Auto geprüft.

  + Schalter am Shield auf `Cam` schieben. Nur so hängt der USB-Anschluss
    am ESP32.
  + USB-Kabel am Uno lassen und den Port im Arduino IDE unter *Werkzeuge
    > Port* notieren, zum Beispiel `COM3`.
  + Tool: Arduino IDE mit dem Kern `esp32` 2.0.17. Board `ESP32 Dev
    Module`, Partition `Huge APP`, `PSRAM` auf `enabled`, 115200 Baud.
  + Binary im Kit:
    `02 Manual & Main Code & APP/04 Code of Carmer (ESP32)/`
    `ESP32-WROVER-Camera/ESP32_CameraServer_AP_20220120/`
    `ESP32_CameraServer_AP_20220120.ino.bin`.
    Einfacher ist der Quellordner daneben: Öffne dort
    `ESP32_CameraServer_AP_20220120.ino` und lade ihn hoch.
  + Mit `esptool` geht es auch:
    `esptool.py --chip esp32 --port COM3 --baud 115200 write_flash`
    `0x10000 ESP32_CameraServer_AP_20220120.ino.bin`. Das setzt die
    passende Partitionstabelle voraus.
  + Prüfschritt: Schalter auf `Upload`, Serieller Monitor auf 115200.
    Nach dem Neustart erscheint wieder die Kamera-Ausgabe. Ohne diese
    Meldung ist die Firmware nicht zurückgespielt.

  In Stellung `Cam` gehört der USB-Anschluss dem ESP32. Der Serial
  Monitor zeigt dann den ESP32. Der Uno bekommt in dieser Stellung keine
  Zeichen vom USB-Anschluss. Für den Uno-Upload schaltest du wieder auf
  `Upload`.

  = Die Kamera-Pins

  Das Modul ist als `M5STACK_WIDE` verdrahtet. Diese Werte stehen im
  Kit-Sketch in der Datei `camera_pins.h`. Du kopierst sie in deinen
  Sketch. Eine eigene Header-Datei brauchst du nicht.

  #pinref((
    ("PWDN", "nicht benutzt, Wert -1"),
    ("RESET", "15"),
    ("XCLK", "27"),
    ("SIOD / SIOC", "22 / 23"),
    ("D0 bis D7", "32, 35, 34, 5, 39, 18, 36, 19"),
    ("VSYNC / HREF", "25 / 26"),
    ("PCLK", "21"),
  ))

  = Der Algorithmus in fünf Schritten

  + *Bild holen.* `esp_camera_fb_get()` gibt einen Zeiger auf die
    Bilddaten.
  + *Jedes vierte Pixel prüfen.* Bei 320 mal 240 Pixeln sind das
    80 mal 60 Stichproben. Das reicht und spart Zeit.
  + *Farbregel anwenden.* Jedes Pixel wird in Rot, Grün und Blau
    zerlegt. Ein Treffer liegt vor, wenn Rot deutlich stärker ist als
    Grün und Blau.
  + *Mittelpunkt und Breite rechnen.* `x` ist der mittlere Wert aller
    Treffer, `w` der Abstand vom linken zum rechten Treffer.
  + *Senden.* Alle 100 Millisekunden geht `{"x":160,"w":42}` über
    `Serial2` an den Uno. Denselben Wert schreibt der ESP32 als
    `x=160 w=42` auf `Serial`. Das ist die Ausgabe für den Monitor.

  Das Bild bleibt als Rohwert auf dem Chip. Es wird nicht als JPEG
  gepackt und nicht auf dem Uno dekodiert. Der ESP32 erledigt alles
  allein.

  #listing("/code/101_color_track_esp32/101_color_track_esp32_exercise/101_color_track_esp32_exercise.ino",
    title: [Farbe finden auf dem ESP32])

  Zeile 3 bis 8 legen Kamera-Pins und Schwellen fest. Zeile 9 bis 17
  senden die Position auf `Serial` und `Serial2`. Zeile 18 bis 20 prüft
  ein Pixel. Zeile 21 bis 35 baut die Kamera auf. Zeile 36 bis 51 laufen
  über das Bild. Zeile 52 bis 56 rechnen die Mitte und senden.

  #probiere[
    Schalter auf `Cam`, Arduino IDE unter *Werkzeuge > Port* den ESP32
    wählen, Seriellen Monitor mit 9600 Baud öffnen. Halte einen roten
    Gegenstand vor die Kamera. Erfolg: `w=` ist größer als 0, und der
    Wert wandert mit dem Gegenstand. Ein grüner Gegenstand lässt `w=0`.
    Beim grünen Lösungssketch ist es umgekehrt. So prüfst du Rot und
    Grün mit derselben Anzeige.
  ]

  = Aufgabe: Grün statt Rot

  Dein Auto soll einem grünen Gegenstand folgen. Ändere nur die
  Farbregel. Ein grüner Treffer liegt vor, wenn der Grünkanal über 100
  liegt und Grün mindestens 40 über Rot und über Blau. Ersetze die drei
  roten Schwellen durch passende grüne Werte und passe `isTarget` an.

  #goalbox(title: "Deine Aufgabe")[
    Nenne die Schwellen `G_MIN`, `G_OVER_R` und `G_OVER_B`. Prüfe in
    `isTarget`: `g > G_MIN`, `(g - r) > G_OVER_R` und
    `(g - b) > G_OVER_B`. Der Rest des Sketches bleibt gleich.
  ]
  #notespace(lines: 6)

  #v(2.6cm)
  #solution("/code/101_color_track_esp32/101_color_track_esp32_solution/101_color_track_esp32_solution.ino",
    title: [Mission Grün])

  = Der Uno empfängt

  Der Uno liest Zeichen von `Serial`, bis ein `}` kommt. Dann steht ein
  ganzes Telegramm im Puffer. Mit `strchr` sucht er den Buchstaben `x`,
  springt zum Doppelpunkt und wandelt die Zahl mit `atoi` um. Dafür
  braucht er keine JSON-Bibliothek.

  Aus `x` und der Bildmitte 160 wird der Fehler. Geteilt durch 4 ergibt
  er den Lenkanteil. Liegt die Farbe rechts, bekommt der linke Motor
  mehr Tempo und das Auto dreht nach rechts.

  Ist der Fleck schmaler als 12 Pixel, ist der Gegenstand zu weit weg.
  Dann hält das Auto an. Kommt 600 Millisekunden kein Telegramm, sucht
  es im langsamen Bogen. Bleibt das Telegramm 3 Sekunden aus, hält es
  ganz an. Die LED zeigt den Zustand: grün fährt, blau sucht, rot steht.

  #listing("/code/106_follow_color_uno/106_follow_color_uno_exercise/106_follow_color_uno_exercise.ino",
    title: [Dem Farbpunkt folgen])

  Zeile 53 bis 61 lesen ein Telegramm. Zeile 63 bis 69 holen eine Zahl
  aus dem Text. Zeile 70 bis 79 lenken. Zeile 80 bis 86 suchen. Zeile 98
  bis 111 wählen zwischen Folgen, Suchen und Anhalten.

  #achtung[
    Das Start-Gate bleibt Pflicht. Ohne Tastendruck fährt nichts. Lege
    das Auto vor dem Einschalten ruhig hin, damit der ESP32 startet,
    bevor der Uno losfährt.
  ]

  = Aufgabe: Ruhiger lenken

  Bei jeder kleinen Bewegung zappelt das Auto um die Mitte. Baue eine
  Totzone ein: Liegt `x` höchstens 18 Pixel neben der Bildmitte, fährt
  das Auto geradeaus. Außerdem soll die Suche langsamer werden. Setze
  `SEARCH_SPEED` von 70 auf 45.

  #goalbox(title: "Deine Aufgabe")[
    Ergänze die Konstante `DEAD_ZONE = 18`. Setze `steer` zuerst auf 0.
    Nur wenn `abs(error) > DEAD_ZONE` ist, rechnest du
    `steer = error / STEER_DIV`. Ändere danach `SEARCH_SPEED`.
  ]
  #notespace(lines: 5)

  #v(2.6cm)
  #solution("/code/106_follow_color_uno/106_follow_color_uno_solution/106_follow_color_uno_solution.ino",
    title: [Mission Ruhige Lenkung])

  = Grenzen

  - Das Bild kommt mit 10 bis 15 Bildern pro Sekunde. Für ein fahrendes
    Auto reicht das, für schnelle Bewegungen nicht.
  - Die Farberkennung hängt vom Licht ab. Am Fenster wirkt Rot anders
    als unter der Zimmerlampe. Probiere die Schwellen bei deinem Licht.
  - Ähnliche Farben (zum Beispiel grüne Kleidung oder grüne Möbel) stören. Der ESP32 kennt nur Farbe,
    keine Form.
  - 9600 Baud reichen für zwei Zahlen. Ein Bild bräuchte bei dieser
    Leitung mehrere Sekunden.

  #fehler((
    ("Der Serial Monitor bleibt leer.",
     "In Stellung `Cam` zeigt der Monitor den ESP32, nicht den Uno.
      Schalte für den Uno-Upload auf `Upload`."),
    ("Die Kamera startet nicht.",
     "Prüfe `PSRAM = enabled` und die Partition `Huge APP`. Stecke das
      4-Pin-Kabel bei ausgeschaltetem Auto neu ein."),
    ("Das Auto dreht immer zur selben Seite.",
     "Prüfe die Richtung: `x` über 160 heißt rechts. Tausche sonst
      `BASE_SPEED + steer` und `BASE_SPEED - steer`."),
    ("Das Auto hält ständig an.",
     "Der Fleck ist zu schmal. Gehe näher heran oder senke `MIN_WIDTH`
      auf 8. Prüfe auch die Schwellen der Farbe."),
  ))

  #merken[
    - Eigene Firmware ersetzt die Werksfirmware. Der Rückweg steht oben
      und muss am Gerät getestet werden.
    - Der ESP32 rechnet die Position, der Uno lenkt.
    - `PIXFORMAT_RGB565` und `FRAMESIZE_QVGA` geben 320 mal 240 Pixel.
    - Jedes vierte Pixel reicht für die Farbsuche.
    - `{"x":160,"w":42}` sind Mitte und Breite in Pixeln.
  ]

  #checklist((
    [Ich spiele ein Programm auf den ESP32 und stelle den Schalter auf `Cam`.],
    [Ich nenne Board, Partition und PSRAM-Einstellung.],
    [Ich erkläre die fünf Schritte der Farbsuche.],
    [Ich ändere die Schwellen von Rot auf Grün.],
    [Ich lese `x` und `w` ohne Bibliothek aus dem Telegramm.],
    [Ich baue eine Totzone ein und mache die Suche langsamer.],
  ))
]
