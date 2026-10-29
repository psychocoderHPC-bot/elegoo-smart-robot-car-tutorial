# Review des Elegoo-Smart-Robot-Car-Tutorials

Stand: 29. Oktober 2026. Geprüft wurden die Typst-Quellen, die erzeugte PDF,
die Sketches, die vorhandenen Build-Logs und passende Dateien aus dem
Elegoo-Originalmaterial. **Ein Test am echten Auto fand nicht statt.**

## Kurzurteil

Das Buch hat eine gute Lernfolge: erst sichtbare Ausgaben, dann Motoren und
Sensoren, zuletzt eigene Projekte. Start-Taste und Countdown, kleine Missionen
und Lösungen auf Folgeseiten helfen Kindern beim Dranbleiben. Die Wiederholung
von Pins, `setup`/`loop` und Sicherheitsregeln ist für Zwölfjährige sinnvoll;
bitte nicht aus Stilgründen entfernen. Die Pinbelegung für die ausdrücklich
genannte Variante **TB6612 + GY-521/MPU6050** stimmt mit der Elegoo-Firmware
überein. Vor einer Weitergabe sollten die folgenden Funktions- und
Sicherheitsfehler behoben werden.

**Prüfstand:** `dist/build-report.md` meldet 27 erfolgreiche Builds der
`_solution`-Sketches (26 Uno, 1 ESP32). Ich habe zusätzlich die
`_exercise`-Sketches 101 und 106 kompiliert; beide bauen. Der
`_exercise`-Sketch 111 baut nicht, weil er nur ein Ausschnitt ist. Typst
rendert die Quellen zu 122 Seiten; die vorhandene PDF hat ebenfalls 122 Seiten.
Ein erfolgreicher Build bestätigt weder Motor- und Sensorverhalten noch die
Fernbedienungscodes.

## Erforderliche Änderungen

### 1. IR-Codes auf IRremote 4.x umstellen (hoch)

**Befund:** Die Codetabellen in `tutorial/chapters/07_licht.typ` und
`13_cheatsheet.typ` sowie die Vergleiche in `code/091_ir_drive/..._solution.ino`
und `code/121_secret_code/..._solution.ino` verwenden Werte aus Elegoos alter
`results.value`-API. Die verwendete IRremote-Version 4.7.1 liefert für NEC in
`decodedIRData.decodedRawData` dagegen LSB-first-Werte. Beispiel:
`0x00FF629D` (alt, „hoch“) wird `0xB946FF00` (neu). Die Bibliothek erklärt
die Umkehr in ihrer README unter „How to convert old MSB first 32 bit IR data
codes“. Damit treffen die fest kodierten `case`-Werte bei Familie A nicht zu;
das Auto reagiert trotz erfolgreichem Build nicht wie beschrieben. Familie B
am Gerät messen, statt ihre Werte ungeprüft umzurechnen.

**Auftrag:** 086 als Messsketch behalten, 091 und 121 mit den tatsächlich von
4.7.1 gelieferten Werten oder mit `protocol`/`address`/`command` auswerten.
Codetabellen, Erklärungen und Beispiele gemeinsam korrigieren. Einen kurzen
Abgleich „gedrückte Taste → angezeigter Wert → Aktion“ für beide
Fernbedienungsvarianten dokumentieren. Die IRremote-Alt-API-Warnungen
aus den Build-Logs nach Möglichkeit durch `#include <IRremote.hpp>` beseitigen.

### 2. Fahrende Programme bei Sensorausfall und Verbindungsverlust anhalten (hoch)

**Befund:** `readDistanceCm()` setzt einen Ultraschall-Timeout auf `400 cm`.
Damit fährt die „Notbremse“ in `code/046_stop_before_wall/..._solution.ino`
bei abgezogenem oder ungünstig ausgerichtetem Sensor weiter. Dasselbe Muster
steht in 066, 111, 126 und 131. `tutorial/chapters/03_ultraschall.typ` nennt
weiche und schräge Flächen für die Notbremse sogar „kein Problem“; genau dort
kann ein Echo fehlen. 066 fährt nach dem Scan außerdem 700 ms vorwärts, selbst
wenn alle drei Richtungen blockiert sind. 091 und 096 halten nach dem letzten
Fahrbefehl nicht von selbst an; 106 dreht bei ausbleibenden Kameradaten ohne
Zeitgrenze weiter.

**Auftrag:** Timeout als ungültige Messung behandeln und bei der Notbremse
anhalten, statt „frei“ anzunehmen. 066 nur fahren lassen, wenn der gewählte
Abstand eine Mindestgrenze überschreitet. Für Fernsteuerung und Kamerasuche
einen begrenzten Fahrbefehl oder einen gut erklärten Stopp-/Watchdog-Mechanismus
einbauen. Text, Diagramme und Cheatsheet an das neue Verhalten anpassen.
Akzeptanzfälle: Echo-Leitung abziehen, Hindernis direkt vor den Sensor stellen,
IR-/Seriell-/Kameraverbindung während der Fahrt unterbrechen. In allen Fällen
bleiben die Motoren nach kurzer, festgelegter Zeit stehen.

### 3. Übungsdateien und Lösungswege deckungsgleich machen (hoch)

**Befund:** `code/066_look_around/..._exercise.ino` verlangt eine Funktion
`chooseAndDrive()`, die in der Lösung nicht vorkommt. Die Lösung trifft die
Entscheidung direkt in `loop()`. Das Kapitel behauptet, Messung und Fahren
stünden „im Listing oben“; dort steht jedoch nur der Servo-Sweep aus 061.
Die Übungsdateien 046, 056, 076, 091, 096, 111 und 116 sind ebenfalls nur
Ausschnitte. Besonders Kapitel 11 sagt „Kopiere den Ordner, öffne die `.ino`
und lade sie hoch“, was bei 111 und 116 nicht funktioniert. Der Build-Bericht
prüft nur Lösungen und deckt das nicht auf.

**Auftrag:** Pro Mission entweder einen vollständig kompilierbaren
`_exercise`-Sketch mit TODOs bereitstellen oder den Kopier-/Einfügeschritt
aus dem vorherigen Sketch mit konkretem Dateinamen und genauer Stelle
beschreiben. 066 muss dieselbe Funktion in Aufgabe und Lösung benutzen.
Jedes Kind soll den Übungsstand öffnen, eine kleine Änderung machen und danach
ohne versteckte Vorarbeit ein Erfolgserlebnis beim Upload haben. Zusätzlich
die vervollständigten Übungen in `tools/validate.sh` prüfen.

### 4. Kamera-Erfolgsausgabe in Kapitel 10 tatsächlich anzeigen (hoch)

**Befund:** `tutorial/chapters/10_esp32.typ` fordert dazu auf, die Zahl hinter
`"w"` im Serial Monitor zu beobachten. `code/101_color_track_esp32` sendet
`{"x":...,"w":...}` aber ausschließlich über `Serial2` an den Uno. Auf
`Serial` erscheinen nur „Kamera bereit“ oder ein Startfehler. Das erste
Kamera-Experiment hat deshalb kein sichtbares Feedback.

**Auftrag:** Die Position zusätzlich auf `Serial` ausgeben oder eine andere
konkrete Beobachtungsmethode beschreiben. Zeigen, welcher Monitor und welcher
Schalterstand nötig sind. Den Test mit rotem und grünem Gegenstand als
kurze Erfolgskontrolle formulieren.

### 5. Kamera-Mission in Kapitel 11 lauffähig machen (hoch)

**Befund:** Die Mission verlangt einen *roten* Gegenstand, verweist aber auf
Beispiel 106 nach Kapitel 10, dessen ESP32-Lösung 101 bereits *Grün* sucht.
Der vorgeschlagene Einzeiler `readDistanceCm()` ist in 106 nicht definiert;
die Aufgabe nennt Pins und Funktion, aber nicht die nötigen `pinMode`-Aufrufe
für TRIG und ECHO. Eine ergänzte Funktion ohne Pin-Einrichtung kann nicht
zuverlässig messen. Der neue Code wird ebenfalls nicht gebaut.

**Auftrag:** Farbwahl zwischen 101, Kapitel 10 und der Kamera-Mission
vereinheitlichen. Einen vollständigen, baubaren Missionssketch samt
Sensor-Initialisierung und Timeout-Verhalten bereitstellen und in die
Validierung aufnehmen. Erst dann „hält 25 cm davor an“ versprechen.

### 6. Einstieg und Hardware-Variante für das Kind absichern (hoch)

**Befund:** Das Buch startet direkt mit „Öffne die Arduino IDE“. Installation
der IDE, Auswahl der benötigten Bibliotheken, Öffnen eines Sketch-Ordners und
eine erste sichere Aufbauprüfung stehen nur teilweise in `README.md` und
den Entwickler-Skripten, nicht als nutzbare Kinderanleitung in der PDF.
Das Originalmaterial enthält Varianten mit DRV8835 sowie TB6612 mit
MPU6050 *oder* QMI8658C. Die Sketches setzen TB6612 + MPU6050 voraus; bei
anderer Platine scheitern insbesondere Motor- und Kapitel-6-Versuche.

**Auftrag:** Vor Kapitel 1 eine kurze Checkliste ergänzen: Platinenaufschrift
und Sensorchip identifizieren, nur die passende Variante verwenden, Akku und
Kabel prüfen, Arduino IDE/Board/Port einrichten, Bibliotheken mit den
getesteten Versionen installieren. Ein Foto oder eine eindeutige Beschriftung
für die passende Platine wäre hilfreich. Für andere Varianten klar auf die
Originalunterlagen verweisen, statt Kompatibilität anzudeuten.

### 7. Werksfirmware, App und eigene Programme sauber trennen (mittel)

**Befund:** Kapitel 8 erklärt App-Steuerbefehle der Elegoo-Werksfirmware.
Eigene Uno-Sketches wie 096 oder 131 lesen dieses JSON nicht. Die Fehlertabelle
legt dennoch nahe, dass bei „App findet Auto, aber es fährt nicht“ nur die
Start-Taste fehle. Kapitel 10 ersetzt zusätzlich die ESP32-Werksfirmware,
liefert zum versprochenen Rückweg mit `esptool` aber keinen ausführbaren,
getesteten Ablauf. Das Original-Binary ist vorhanden, doch Dateiname allein
genügt einem Kind nicht zum Zurückspielen.

**Auftrag:** Kapitel 8 ausdrücklich auf die Werksfirmware begrenzen und
erklären, dass die App eigene Uno-Programme nicht automatisch steuert.
Vor dem Überschreiben des ESP32 einen geprüften Wiederherstellungsweg mit
Schalterstellung, Port, benötigtem Tool, Binary-Pfad und Prüfschritt anbieten;
sonst Kapitel 10 als betreutes Zusatzprojekt kennzeichnen. Den Rückweg vor
Veröffentlichung einmal am Gerät testen.

### 8. Falsche oder irreführende Erklärungen berichtigen (mittel)

- `01_programmieren.typ`: „9600 Baud bedeutet 9600 Zeichen pro Sekunde“ ist
  falsch. Bei üblichem 8N1 sind es 9600 Bit/s bzw. höchstens etwa 960
  Zeichen/s. Nur die Einheit muss korrigiert werden; die einfache Erklärung
  des Uploads kann bleiben.
- `03_ultraschall.typ`: `pulseIn` wartet ohne *angegebenes* Zeitlimit nicht
  endlos, sondern verwendet standardmäßig ein Timeout von etwa einer Sekunde.
  Die expliziten 25 ms sind trotzdem sinnvoll.
- `06_mpu6050.typ` und `99_anhang.typ`: `mpu.begin()` und die Pause kalibrieren
  den GY-521 nicht automatisch auf die aktuelle Lage. Die Aussage über einen
  „falschen Startwert“ beim Wackeln und die Einschaltkalibrierung streichen
  oder durch eine echte Kalibrierroutine mit Messschritt ersetzen.
- `99_anhang.typ`: Die Eltern-Tabelle beschreibt Kapitel 3 als
  Hindernis-*Ausweichen*, Kapitel 6 als geradere Fahrt und Kapitel 10 als
  Werkzeugliste. Tatsächlich bauen diese Kapitel Notbremse, Neigung/Stoßalarm
  und eigene ESP32-Firmware. Auch die Fehlersuche „`stk500_recv` durch nicht
  stillstehendes Auto“ und „Linien-Schwelle per App ändern“ passt nicht zu den
  eigenen Sketches. Tabelle und Fehlersuche am Buchinhalt neu ausrichten.

### 9. Sicherheitsanweisung für den ersten Motortest korrigieren (mittel)

`02_motoren.typ` rät, das USB-Kabel beim Drehen „stramm“ zu halten. Ein straffes
Kabel zieht am Auto und kann es samt Kiste herunterreißen. Einen sicheren,
stabilen Stand mit frei drehenden Rädern, losem Kabel und freier Hand am
Ein-/Aus-Schalter beschreiben. Den Countdown nicht als Garantie ausgeben, dass
man ein fahrbereites Auto in drei Sekunden sicher vom PC auf den Boden bringt.

### 10. Behauptete Steuerwirkung und Linienende an den Code anpassen (mittel)

In 096 ändern `q` und `e` nur die Variable `speed`; bei schon fahrenden
Motoren ändert sich der PWM-Wert erst nach einem weiteren Richtungsbefehl.
`08_kamera.typ` verspricht dagegen sofort „langsamer“ und „schneller“.
Entweder die aktuelle Fahrtrichtung speichern und neu ausgeben oder den
zusätzlichen Tastendruck erklären. In 056 führt „alle Sensoren weiß“ zu
`error = 0` und damit geradeaus weiterfahren, obwohl `04_linie.typ` die
Frage nach diesem Fall stellt und eine Linie bis zum Ende verspricht.
Hier ein klares Verhalten wählen (Stopp oder kurze Suche) und Aufgabe,
Lösung sowie Fehlertabelle angleichen. „Alle drei schwarz“ kann auch eine
breite Linie oder Querlinie sein; das Hochheben des Autos ist kein Test dafür.

### 11. Nicht vorhandenen zweiten Sensor in Kapitel 12 nicht voraussetzen (mittel)

`12_klassen.typ` empfiehlt `DistanceSensor hinten(11, 10)`. Ein zweiter
HC-SR04 gehört nicht zur Teileliste, und D10 ist bereits für den Servo
reserviert. Die Übung als optionale Erweiterung **mit zusätzlichem Sensor**
kennzeichnen, freie Pins und den Ausbau/Verzicht auf den Servo erklären oder
stattdessen zwei Objekte mit einem simulierten Sensorwert üben.

## Optionale Änderungen für Motivation und Lesbarkeit

1. Nach jeder neuen Baugruppe einen kleinen „Das solltest du jetzt sehen“-Kasten
   mit konkretem Bild, LED-Zustand oder Monitorzeile einfügen. Besonders bei
   051 (Schwarz/Weiß-Messung), 086 (IR-Code) und 101 (Farbpunkt) hilft das,
   den Erfolg zu erkennen, bevor der nächste lange Sketch kommt.
2. Die ASCII-Umschriften `ae`, `oe`, `ue` und `ss` in den Fließtexten von
   Kapitel 5, 6, 10, 13 und Anhang in normale deutsche Schreibweise ändern.
   Bezeichner und Sketch-Kommentare dürfen unverändert bleiben.
3. Vor den großen Listings 066, 101 und 131 eine kleine Stufenfolge anbieten:
   zuerst nur messen/anzeigen, dann Entscheidung prüfen, zuletzt Motoren
   einschalten. Das senkt die Frustration, wenn ein Teil nicht funktioniert.
4. Die drei Varianten „Demo“, „Ausschnitt zum Einfügen“ und „fertige Übung“
   sichtbar kennzeichnen. Kinder wissen dann, ob sie einen Ordner direkt
   hochladen können. Die bewusste Wiederholung der Grundlagen beibehalten.
5. Nach den Korrekturen PDF-Seiten mit langen Codeblöcken und Tabellen noch
   einmal stichprobenartig am Bildschirm und als Schwarz-Weiß-Ausdruck prüfen.

## Abnahme für den nächsten Agenten

- Alle `_solution`-Sketches und alle als „direkt hochladbar“ markierten
  `_exercise`-Sketches kompilieren mit den in `tools/VERSIONS.txt` genannten
  Versionen.
- Die Aufgaben 066, 096, 111 und 116 lassen sich vom genannten Ausgangssketch
  aus ohne Nachschlagen in der Lösung fertigstellen.
- PDF neu rendern; Aussagen, Code und Cheatsheet stimmen überein.
- Am passenden Elegoo-Auto IR-Tasten, Ultraschall-Timeout, Start-Gate,
  ESP32-Farbtelegramm, Not-Stopp und Wiederherstellung der Werksfirmware
  prüfen. Bis dahin diese Punkte im Buch nicht als hardwaregetestet ausgeben.
