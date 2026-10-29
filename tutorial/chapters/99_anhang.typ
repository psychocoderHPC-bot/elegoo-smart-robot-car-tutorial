#import "../lib/components.typ": chapter, tipp, achtung, merken

#chapter("A", [Anhang])[

= Fuer Eltern und Lehrkraefte

Das Buch ist fuer Kinder ab 12 geschrieben, die es allein lesen koennen.
Die Mission am Kapitelanfang sagt, was das Kind am Ende gebaut hat.

#table(
  columns: (auto, 1fr, auto),
  table.header([Kapitel], [Das kannst du danach], [Zeit]),
  "1", [Erstes Programm, Variablen, Schleifen und Funktionen], [2 Termine],
  "2", [Beide Motoren steuern, nach vorn und zurueck fahren], [2 Termine],
  "3", [Notbremse vor einem Hindernis, stoppt bei ungueltiger Messung (-1)], [2 Termine],
  "4", [Auto folgt der Linie mit eigener Schwelle, stoppt am Linienende (alle weiss)], [2 Termine],
  "5", [Servo dreht den Kamera-Kopf nach Links und Rechts], [1 Termin],
  "6", [MPU6050 erkennt Neigung und Stoesse, loest Neigungs- und Stossalarm aus], [2 Termine],
  "7", [WS2812 leuchtet, IR-Taste macht das Auto fuehrbar], [2 Termine],
  "8", [Kamera-WLAN sendet ein Bild, JSON-Steuerbefehle], [2 Termine],
  "9", [Alle Bauteile zusammen: Linien- und Hindernis-Verhalten], [2 Termine],
  "10", [Eigene ESP32-Firmware, ueberschreibt die Werksfirmware; Rueckweg erst am Geraet testen], [1 Termin],
  "11", [Eigene Projekte planen und umsetzen], [2 Termine],
  "12", [Code in Dateien ordnen, eine Klasse lesen und nutzen], [2 Termine],
  "13", [Alles nachschlagen: Pins, Befehle, Fehler], [1 Termin],
)

So laeuft ein realistischer Zeitplan: etwa 12 Wochen mit zwei Terminen von je
45 Minuten pro Woche. Ein Termin hat zwei Aufgaben. Die Lueckenaufgabe
laeuft zuerst, die Loesung kommt erst am Ende. Am letzten Tag steht das
Auto, wenn alles gut gelaufen ist.

#tipp[
  Hilfe ohne Loesung: Das Kind liest die Zeilen selbst, du fragst nur.
  "Was macht diese Zeile?" oder "Wo fehlt der Abschluss?" reicht fast
  immer. Die Loesung auf der naechsten Seite vergleicht das Kind erst
  nach dem eigenen Versuch.
]

#achtung[
  Upload/Cam-Schalter: Bevor du einen Sketch auf das Auto loedst,
  stellst du den Schalter auf "Upload". Beim Flashen steht das Auto
  still, das ist normal. Nach dem Flashen stellst du ihn zurueck auf
  "Cam", dann ist das WLAN der Kamera wieder erreichbar.
]

#merken[
  Am Anfang: Auto ruhig auf den Boden stellen und erst dann die
  Spannung einschalten. Der GY-521 kalibriert sich nicht von selbst:
  Vor der Neigungsmessung brauchst du eine ebene Referenz. Das Servo
  nicht mit der Hand drehen,
  wenn das Auto Strom hat.
]

= Wenn nichts geht

Die Tabelle zeigt, was du zuerst schaust. Jede Zeile ist ein reales
Fehlerbild aus dem Kit.

#table(
  columns: (auto, 1fr, 1fr),
  table.header([Symptom], [Ursache], [Loesung]),
  [COM-Port taucht nicht auf],
  [USB-Kabel ist nicht angeschlossen oder der Schalter steht auf "Cam"],
  [Kabel neu an die Buchse stecken, Schalter auf "Upload" stellen, Auto kurz aus- und wieder ein.],
  [Upload bricht mit "stk500_recv" ab],
  [Falscher Port gewaehlt, der Schalter steht nicht auf "Upload", oder der Reset beim Upload schlaegt fehl.],
  [Port in der IDE pruefen, Schalter auf "Upload" stellen, Auto aus- und wieder einschalten, Upload erneut starten.],
  [Auto faehrt zurueck],
  [Die Richtungs-Bits D8 und D7 (BIN1, AIN1) sind vertauscht.],
  [Die beiden Pin-Kabel an einem Motor umdrehen, dann testen.],
  [Ultraschall zeigt -1 oder keine Messung],
  [Das ECHO-Signal kommt nicht an, meist ein loses Kabel an D12/D13.],
  [Kabel D12/D13 neu stecken, Sensor gerade ausrichten; das Auto stoppt bei -1 absichtlich.],
  [Linienfolger zittert],
  [Die Schwelle passt nicht zu deiner Bahn, das Licht ist anders.],
  [`LINE_THRESHOLD` im Sketch anpassen (nicht die App-Schwelle N=104), die Bahn gleichmaessig beleuchten.],
  [IR reagiert nicht oder stoppt nach 1 s],
  [Die Taste deiner Fernbedienung nutzt die andere Familie; der Sketch prueft die Familie-A-`CMD_...`-Werte. Der Watchdog stoppt ohne neuen Befehl nach 1 s.],
  [Familie A steht in der Cheatsheet-Tabelle; andere Werte mit Beispiel 086 messen und die `CMD_...`-Zahlen ersetzen.],
  [Kamera-WLAN taucht nicht auf],
  [Schalter steht auf "Upload", das Kabel zur Kamera ist lose, oder der Akku ist zu schwach.],
  [Schalter auf "Cam" stellen, Kamera-Kabel neu stecken, Auto kurz aus- und wieder ein.],
)

= Teileliste

Die Teileliste zeigt, was im Kit liegt und wofuer es ist.

#table(
  columns: (auto, 1fr),
  table.header([Teil], [Wofuer es ist]),
  [Arduino Uno],
  [Der Rechner, den du programmierst. Laeuft alle Programme.],
  [Smart-Robot-Shield (TB6612) mit GY-521],
  [Der TB6612 treibt die beiden Motoren. Der GY-521 misst die Drehung.],
  [HC-SR04 Ultraschallsensor],
  [Misst die Distanz in Zentimetern, bis zu 200 cm.],
  [3x Linienfolger (ITR20001)],
  [Erkennen, ob der Sensor ueber der schwarzen Linie ist.],
  [SG90 Servo],
  [Dreht den Kamera-Kopf nach Links und Rechts.],
  [WS2812 LED],
  [Eine RGB-LED, die du in jeder Farbe leuchten lassen kannst.],
  [IR-Empfaenger mit Fernbedienung],
  [Empfaengt die Infrarot-Signale der Fernbedienung.],
  [ESP32-WROVER mit Kamera],
  [Sendet ueber WLAN ein Bild an das Handy.],
  [2x Getriebemotor],
  [Treiben die beiden Räder.],
  [Lithium-Akku (in der Akku-Box) mit Ladekabel],
  [Laedt ueber USB, reicht fuer den Betrieb.],
  [Jumper-Kabel, Stecker, Schrauben],
  [Verbinden die Module mit dem Shield.],
)

= Beispielverzeichnis

Alle Programme aus `code/` mit Kapitel und Art. Demo heisst: Skelett und
Loesung sind gleich. Aufgabe heisst: das Skelett hat Luecken.

#text(size: 8.5pt)[
  #table(
    columns: (auto, 1fr),
    table.header([Nr.], [Titel, Kapitel, Art]),
    [001], [Hallo Arduino · Kap. 1 · Demo],
    [006], [Vier Typen · Kap. 1 · Demo],
    [011], [Zu nah, passt, weit weg · Kap. 1 · Demo],
    [016], [Zaehlen mit for und while · Kap. 1 · Demo],
    [021], [Mittelwert · Kap. 1 · Aufgabe],
    [026], [Vor, zurueck und drehen · Kap. 2 · Demo],
    [031], [Rampe von 0 bis 255 · Kap. 2 · Demo],
    [036], [Quadrat · Kap. 2 · Aufgabe],
    [041], [Abstand anzeigen · Kap. 3 · Demo],
    [046], [Notbremse vor einem Hindernis · Kap. 3 · Aufgabe],
    [051], [Rohwerte anzeigen · Kap. 4 · Demo],
    [056], [Der Linie folgen · Kap. 4 · Aufgabe],
    [061], [Kopf drehen · Kap. 5 · Demo],
    [066], [Der freie Weg · Kap. 5 · Aufgabe],
    [071], [Roll und Pitch · Kap. 6 · Demo],
    [076], [Mission Stossalarm · Kap. 6 · Aufgabe, hochladbar],
    [081], [Vier Farben und einmal aus · Kap. 7 · Demo],
    [086], [Codes auslesen · Kap. 7 · Demo],
    [091], [Mission Fernbedienung · Kap. 7 · Aufgabe, hochladbar],
    [096], [Fahren mit Buchstaben · Kap. 8 · Aufgabe, hochladbar],
    [101], [Farbe suchen: erst rot, dann gruen (ESP32) · Kap. 10 · Aufgabe],
    [106], [Dem farbigen Punkt folgen (Uno) · Kap. 10 · Aufgabe],
    [106 Mission], [Gruenem Punkt folgen (Mission) · Kap. 11 · Mission],
    [111], [Parkwaechter · Kap. 11 · Aufgabe, hochladbar],
    [116], [Tanzroboter · Kap. 11 · Aufgabe, hochladbar],
    [121], [Geheimcode · Kap. 11 · Loesung],
    [126], [Notbremse mit Klasse · Kap. 12 · Aufgabe],
    [131], [Rettungsrover · Kap. 9 · Aufgabe]
  )
]

#tipp[
  Wer die Werksfirmware des ESP32 zurueckholen muss, folgt der Checkliste in
  Kapitel 10: Schalter auf `Cam`, richtigen Port waehlen, Arduino IDE mit
  ESP32-Core 2.0.17, Binary-Pfad aus dem Kit, dann der Pruefschritt im
  Seriellen Monitor. Dieser Rueckweg ist noch nicht am Geraet getestet.
]

= Änderungen in Version 1.1

#list(
  [Sensoren und Verbindungen stoppen jetzt nach einer festen Zeit ohne
  gueltige Daten: 091/096 nach 1 s, 106 nach 3 s, 111 nach 5 s, 131 nach
  30 s.],
  [IR-Codes nutzen IRremote 4.x mit `decodedIRData.command` und 8-Bit-
  `CMD_...`-Werten; Familie B wird mit Beispiel 086 gemessen.],
  [Die hochladbaren Uebungssketches sind vollstaendig und werden mitgeprueft;
  einzelne Ausschnitte bleiben bewusst aussen vor.],
  [Die Kamera-Mission gibt ueber die LED Rueckmeldung: gruen folgt, blau
  sucht, rot stoppt.],
  [`0x` und die Hex-Schreibweise werden ausfuehrlich erklaert.],
  [Das Layout ist fuer den beidseitigen Druck (Duplex) gesetzt.],
  [Die Sicherheitstexte zu Akku, Servo und Upload-Schalter sind klarer.],
)

= Quellen und Weiterlesen

#enum(
  [Elegoo Smart Robot Car Kit V4.0: User Manual und Tutorial-PDFs im Ordner
  "02 Manual & Main Code & APP" des Kits.],
  [Elegoo Smart Robot Car Kit V4.0: Firmware und Bibliotheken im Ordner
  "02 Manual & Main Code & APP/02 Main Program (Arduino UNO)".],
  [Elegoo Smart Robot Car Kit V4.0: Kommunikationsprotokoll
  ("04 Related chip information/Communication protocol for Smart Robot Car.pdf").],
  [Arduino-Referenz: https://www.arduino.cc/reference/en/libraries/],
  [Adafruit MPU6050 Guide: https://learn.adafruit.com/mpu6050-6-dof-accelerometer-and-gyro/arduino],
  [Adafruit_MPU6050 Bibliothek: https://github.com/adafruit/Adafruit_MPU6050],
  [IRremote Bibliothek (4.x): https://github.com/Arduino-IRremote/Arduino-IRremote],
  [FastLED Bibliothek: https://github.com/FastLED/FastLED],
  [NewPing Bibliothek: https://github.com/teckel1/ARDUINO-NewPing],
  [Elegoo offizielles GitHub-Projekt: https://github.com/elegooofficial/ELEGOO-Smart-Robot-Car-Kit-V4.0],
  [ArjanOnwezen: Firmware mit strukturierten Ordnern: https://github.com/ArjanOnwezen/ElegooSmartRobotCarV4.0],
  [antonioastro/Elegoo-SmartCar mit IR-Werten fuer ein TV-Gerat: https://github.com/antonioastro/Elegoo-SmartCar],
  [raccrobotics/libelegoo-edu, eine Lern-Bibliothek: https://github.com/raccrobotics/libelegoo-edu],
  [Toremetal/ESP32-Kamera-Beispiele, angepasst an Arduino IDE 2.1.0: https://github.com/Toremetal/ESP32_Examples-ESP32-Camera-CameraWebServer],
)

Am Ende des Anhangs steht das Auto, der Rest ist deine Sache.
]
