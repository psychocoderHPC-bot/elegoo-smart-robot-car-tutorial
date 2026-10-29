#import "../lib/components.typ": *

#chapter(13, [Cheatsheet], goal: [
  Hier findest du alles Wichtige auf einen Blick: das Grundgeruest, die
  Sensoren, die Pins, die IR-Codes und die haeufigsten Fehler. Nutze das
  Kapitel zum Nachschlagen, wenn du einen Sketch baust oder etwas nicht
  funktioniert.
])[

  = Grundgeruest und Serial Monitor

  Jeder Sketch hat `setup` (laeuft einmal) und `loop` (laeuft endlos).
  `Serial.begin(9600)` oeffnet den Monitor. `F("...")` legt den Text in den
  Flash, damit der knappe RAM frei bleibt. `//` beginnt einen Kommentar.

  ```c
  void setup() {
    Serial.begin(9600);          // 9600 Baud im Monitor einstellen
    Serial.println(F("Bereit."));// F(): Text liegt im Flash
  }
  void loop() {
    // laeuft immer wieder
  }
  ```

  = Datentypen und Operatoren

  #text(size: 9pt)[
    #table(
      columns: (auto, 1fr, auto, 1fr),
      table.header([Typ], [Bedeutung], [Operator], [Bedeutung]),
      [`int`], [ganze Zahl, z. B. 30], [`=`], [zuweisen],
      [`float`], [Kommazahl, z. B. 36.5], [`==`], [gleich],
      [`bool`], [`true` oder `false`], [`!=`], [ungleich],
      [`char`], [ein Zeichen, z. B. `'A'`], [`<`, `>`], [kleiner, groesser],
      [`String`], [Text, z. B. `"Hallo"`], [`&&`, `||`], [und, oder],
      [ ], [ ], [`%`], [Rest einer Division],
    )
  ]

  `31 / 2` ergibt 15, weil beide Zahlen `int` sind. `31 / 2.0` ergibt 15.5.
  Ein einzelnes `=` weist zu, zwei `==` vergleichen.

  = Ablauf: Bedingungen, Schleifen, Funktionen

  ```c
  if (cm < 20) { stopMotors(); }        // sonst else
  else if (cm < 60) { drive(80, 80); }
  for (int i = 0; i < 4; i++) { }       // feste Anzahl
  while (!buttonPressed()) { delay(20); } // solange wahr
  int readDistanceCm() { return 42; }    // Rueckgabetyp vor dem Namen
  int werte[5] = {10, 20, 30, 40, 50};   // Array, Index ab 0
  ```

  `for` zaehlt eine feste Zahl von Runden. `while` laeuft, solange die
  Bedingung wahr ist. Eine Funktion mit Rueckgabe nennt ihren Typ vorne und
  beendet sich mit `return`.

  = Immer wieder gebraucht

  Diese Bausteine stehen in fast jedem Sketch. Kopiere sie aus dem
  jeweiligen Kapitel, hier stehen nur die Signaturen und die Kernzeilen.

  ```c
  const uint8_t PIN_PWMA=5, PIN_PWMB=6;  // Tempo
  const uint8_t PIN_AIN1=7, PIN_BIN1=8;  // Richtung
  const uint8_t PIN_STBY=3, PIN_BUTTON=2;

  void stopMotors();                 // beide PWM auf 0, STBY auf LOW
  void drive(int left, int right);   // -255 bis 255, Vorzeichen = Richtung
  bool buttonPressed();              // INPUT_PULLUP: gedrueckt = LOW
  void waitForStart();               // Taste, Loslassen, Countdown 3-2-1
  ```

  `drive` klemmt beide Werte mit `constrain(..., -255, 255)`, setzt die
  Richtungspins auf `>= 0` und schreibt `abs(...)` auf die PWM-Pins.
  `waitForStart` blockiert `loop`, bis du die Taste auf dem Shield drueckst.

  = Sensoren und Aktoren

  #text(size: 8.8pt)[
    #table(
      columns: (auto, auto, 1fr),
      table.header([Bauteil], [Aufruf / Wert], [Was du wissen musst]),
      [Ultraschall], [`readDistanceCm()`], [58 Mikrosekunden pro cm; `pulseIn` mit Timeout 25000; kein Echo = -1 (ungültig); das Auto stoppt],
      [Linie], [`analogRead(A2/A1/A0)`], [schwarz 250 bis 850, weiss etwa 1000; eigene Schwelle messen; alle drei weiß = Linienende → Stopp],
      [Servo], [`attach(D10)`, `write(winkel)`], [0 bis 180 Grad; nach dem Drehen 400 ms warten],
      [MPU6050], [`getEvent()`], [`RAD_TO_DEG = 57.2958`; Gyro in rad/s, danach deg/s; Adresse `0x68`],
      [LED], [`CRGB`, `addLeds<WS2812,4,GRB>`], [`show()` senden; jede Farbe 0 bis 255; Pin D4],
      [IR], [`begin(PIN_IR, DISABLE_LED_FEEDBACK)`], [`decodedIRData.command` lesen, dann `resume()`; `DISABLE_LED_FEEDBACK` haelt D13 frei],
      [Kamera], [`{"x":160,"w":42}`], [`x` ist die Mitte, `w` die Breite in Pixeln],
    )
  ]

  = IR-Codetabelle

  Jede Taste sendet ein 8-Bit-`command`. Das Kit kennt zwei Familien. Lies
  deine Codes mit Beispiel 086 aus; manche Fernbedienungen weichen ab.

  #text(size: 8.4pt)[
    #table(
      columns: (auto, auto, 1fr),
      table.header([Taste], [Befehl], [Wirkung]),
      [hoch], [`0x62`], [vorwärts],
      [runter], [`0xA8`], [rückwärts],
      [links], [`0x22`], [links drehen],
      [rechts], [`0xC2`], [rechts drehen],
      [OK], [`0x02`], [anhalten],
      [1], [`0x68`], [noch frei],
      [2], [`0x98`], [noch frei],
      [3], [`0xB0`], [noch frei],
      [4], [`0x30`], [noch frei],
      [5], [`0x18`], [noch frei],
      [6], [`0x7A`], [noch frei],
      [7], [`0x10`], [noch frei],
      [8], [`0x38`], [noch frei],
      [9], [`0x5A`], [noch frei],
    )
  ]

  `0x` gehoert vor jede Zahl. Familie B sendet andere Werte; miss sie mit
  Beispiel 086 und trage sie an der einen `CMD_...`-Stelle im Sketch ein.

  = Pin-Tabelle

  #text(size: 9pt)[
    #table(
      columns: (auto, 1fr, auto, 1fr),
      table.header([Pin], [Bedeutung], [Pin], [Bedeutung]),
      [D2], [Taste auf dem Shield], [D9], [IR-Empfaenger],
      [D3], [STBY, Treiber ein/aus], [D10], [Servo],
      [D4], [WS2812-LED], [D12], [Ultraschall ECHO],
      [D5], [PWM rechter Motor], [D13], [Ultraschall TRIG],
      [D6], [PWM linker Motor], [A0], [Linie rechts],
      [D7], [Richtung rechter Motor], [A1], [Linie mitte],
      [D8], [Richtung linker Motor], [A2], [Linie links],
      [ ], [ ], [A4/A5], [I2C: SDA / SCL],
    )
  ]

  = Fehlerbilder

  #fehler((
    ([COM-Port fehlt.],
      [USB-Kabel neu stecken, Schalter auf `Upload` stellen, Auto aus- und
      wieder einschalten.]),
    ([Upload bricht mit `stk500_recv` ab.],
      [Port und Schalter pruefen: `Upload` waehlen, den richtigen COM-Port
      nehmen, Auto aus- und wieder einschalten, dann erneut hochladen.]),
    ([Auto faehrt rueckwaerts.],
      [D7 und D8 sind vertauscht. Tausche `PIN_AIN1` und `PIN_BIN1` in
      `drive`.]),
    ([Ultraschall liefert keine Messung / -1.],
      [Das ECHO-Signal fehlt, oft durch ein loses Kabel an D12/D13. Das
      Auto stoppt absichtlich, statt mit einem Ersatzwert weiterzufahren.
      Kabel pruefen, Sensor gerade auf eine Wand richten.]),
    ([Linie zittert.],
      [Schwelle neu messen und `LINE_THRESHOLD` anpassen. Fuer gleichmaessiges
      Licht sorgen.]),
    ([IR ohne Reaktion.],
      [Start-Gate gedrueckt? Sonst mit Beispiel 086 den Befehl auslesen und
      die `CMD_...`-Zahlen an der einen markierten Stelle im Sketch
      ersetzen. Nicht die `case`-Zeilen einzeln aendern.]),
    ([Kamera-WLAN fehlt.],
      [Schalter auf `Cam`, Kamerakabel pruefen, Akku laden.]),
    ([Linkerfehler `__vector_11`.],
      [FastLED 3.10.x vertraegt sich nicht mit Servo. Nimm 3.9.15.]),
    ([Auto stoppt nach kurzer Zeit ohne neue Daten.],
      [Das ist der Watchdog: 091/096 stoppen nach 1 s ohne Befehl, 106 nach
      3 s ohne Kamera, 111 nach 5 s ohne gueltiges Echo, 131 nach 30 s ohne
      Kreuzung.]),
  ))

  = Bibliotheksversionen

  Diese Versionen passen zusammen und sind getestet.

  #text(size: 9pt)[
    #table(
      columns: (1fr, auto),
      table.header([Bibliothek / Core], [Version]),
      [FastLED], [3.9.15],
      [IRremote], [4.7.1],
      [Adafruit MPU6050], [2.2.9],
      [Servo], [1.2.2],
      [ESP32-Core (nur Kamera)], [2.0.17],
    )
  ]

  #achtung[
    Nutze bei FastLED die 3.9.15. Die 3.10.x-Reihe kollidiert mit der
    Servo-Bibliothek und bricht mit `multiple definition of __vector_11` ab.
  ]

  = Glossar

  #text(size: 9pt)[
    #table(
      columns: (auto, auto, 1fr),
      table.header([Deutsch], [Englisch], [Bedeutung]),
      [Schleife], [`loop`], [wiederholt sich endlos],
      [Variable], [variable], [beschrifteter Platz im Speicher],
      [Funktion], [function], [benannter Block, der eine Aufgabe loest],
      [Bedingung], [condition], [Ausdruck, der `true` oder `false` liefert],
      [Sensor], [sensor], [misst etwas, z. B. Abstand oder Helligkeit],
      [Aktor], [actuator], [bewegt etwas, z. B. Motor oder Servo],
      [Sketch], [sketch], [das Arduino-Programm],
      [Bibliothek], [library], [fertiger Code, den du einbindest],
    )
  ]

  = Beispielnummern

  Alle Sketches liegen unter `code/`. Die Nummer steht im Ordnernamen und
  im ersten Kommentar der `.ino`-Datei.

  #text(size: 8.4pt)[
    #table(
      columns: (auto, auto, auto, auto),
      table.header([Nr.], [Kap.], [Nr.], [Kap.]),
      [001], [1], [071], [6],
      [006], [1], [076], [6],
      [011], [1], [081], [7],
      [016], [1], [086], [7],
      [021], [1], [091], [7],
      [026], [2], [096], [8],
      [031], [2], [101], [10],
      [036], [2], [106], [10],
      [041], [3], [111], [11],
      [046], [3], [116], [11],
      [051], [4], [121], [11],
      [056], [4], [131], [9],
      [061], [5], [126], [12],
      [066], [5], [106 Mission], [11],
    )
  ]

  #merken[
    `setup` laeuft einmal, `loop` endlos. Ein `=` weist zu, `==` vergleicht.
    Vor jeder Fahrt steht das Start-Gate. Sensoren liefern Rohwerte, die du
    selbst kalibrierst. Pruefe bei Problemen zuerst Kabel, Schalter und
    Bibliotheksversion.
  ]
]
