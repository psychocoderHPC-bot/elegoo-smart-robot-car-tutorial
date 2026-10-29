#import "../lib/components.typ": *

#chapter(12, [Code ordnen und eigene Klassen], goal: [
  Du teilst einen großen Sketch in mehrere Dateien auf.
  Du verstehst, wofür Header, Includes und `#pragma once` gut sind.
  Du verstehst, wie die Klasse `DistanceSensor` aus Header und `.cpp` aufgebaut ist,
  und nutzt sie in der Notbremse aus Kapitel 3.
])[
  #mission[
    Räume deinen Sketch auf: Header, Quelle und Hauptprogramm liegen in
    getrennten Dateien. Den Ultraschallsensor übernimmt die vorgefertigte Klasse `DistanceSensor`.
    Am Ende fährt das Auto mit der Notbremse aus Kapitel 3, nur besser
    sortiert.
  ]

  = Wenn der Sketch wächst

  Am Anfang passt alles in eine Datei. Nach ein paar Kapiteln wird sie lang.
  Oben stehen die Pins, darunter die Motoren, dann der Sensor, dann das
  Start-Gate, und ganz unten kommt `loop`. Wer eine Zeile sucht, scrollt
  lange.

  Eine große Datei hat drei Nachteile:

  - Du findest zusammengehörige Zeilen schwer wieder.
  - Zwei Personen können nicht gut an derselben Datei arbeiten.
  - Du kannst einen Baustein nicht in einem anderen Projekt wiederverwenden.

  Die Lösung heißt: pro Aufgabe eine eigene Datei. Der Ultraschallsensor
  bekommt seinen eigenen Bauplan und seinen eigenen Code. Die `.ino` wird
  dadurch kurz und liest sich wie eine Geschichte: starten, messen,
  entscheiden, fahren.

  = Header und Includes

  Ein C++-Programm besteht aus zwei Sorten von Dateien:

  - Eine *Header-Datei* endet auf `.h`. Sie enthält die *Deklarationen*: Wie
    heißt eine Funktion, welche Parameter nimmt sie, welche Klasse gibt es?
    Der Header zeigt nur den Bauplan, keinen rechenbaren Code.
  - Eine *Quell-Datei* endet auf `.cpp`. Sie enthält die *Definitionen*: Den
    Code, der wirklich rechnet. Zu jedem Eintrag im Header steht hier die
    passende Umsetzung.

  Die `.ino` bindet den Header mit `#include "DistanceSensor.h"` ein. Die
  Anführungszeichen sagen: Suche die Datei zuerst im selben Ordner wie diesen
  Sketch. Bei `#include <Arduino.h>` stehen spitze Klammern. Damit sucht der
  Compiler in den mitgelieferten Bibliotheken, hier nach den Arduino-Funktionen.

  Ganz oben in jeder eigenen Header-Datei steht `#pragma once`. Das ist ein
  Befehl an den Compiler: Lies diese Datei nur ein einziges Mal, auch wenn sie
  an mehreren Stellen eingebunden wird. Ohne diesen Schutz entstehen doppelte
  Definitionen und der Upload bricht ab.

  Ein kurzer Header sieht so aus:

  ```c
  // motor.h - nur der Bauplan
  #pragma once
  #include <Arduino.h>

  void drive(int left, int right);
  void stopMotors();
  ```

  Mehr steht nicht drin. Kein `analogWrite`, keine Schleife, nur die
  Ankündigung. Den Code schreibst du in die `.cpp`. So bleibt der Header kurz
  und du siehst sofort, was ein Baustein kann.

  = Eine Klasse ist ein Bauplan

  Eine *Klasse* bündelt Daten und Funktionen. Die Daten heißen *Member*, die
  Funktionen heißen *Methoden*. Für den Sensor gehören die beiden Pins zu den
  Daten. Das Messen gehört zu den Methoden.

  Eine Klasse hat drei wichtige Teile:

  - Der *Konstruktor* trägt denselben Namen wie die Klasse und hat keinen
    Rückgabetyp. Er läuft einmal, wenn du ein Objekt anlegst, und speichert
    die Startwerte.
  - `public` bedeutet: Von außen sichtbar. Diese Methoden darfst du in
    `setup` und `loop` aufrufen.
  - `private` bedeutet: Nur innerhalb der Klasse sichtbar. Die Pins bleiben
    versteckt, damit niemand sie versehentlich ändert.

  Ein Objekt erzeugst du mit einer Zeile wie
  `DistanceSensor sensor(13, 12);`. Die Zahlen sind die Pins für TRIG und
  ECHO. Danach rufst du `sensor.begin()` und `sensor.readCm()` auf. Der Punkt
  verbindet das Objekt mit seiner Methode.

  #listing("/code/126_classes/126_classes_solution/DistanceSensor.h",
    title: [DistanceSensor.h])

  Der Header zeigt nur den Bauplan. `DistanceSensor` ist der Konstruktor.
  `begin` und `readCm` sind öffentlich. Die beiden Pin-Variablen sind privat.

  #listing("/code/126_classes/126_classes_solution/DistanceSensor.cpp",
    title: [DistanceSensor.cpp])

  In der `.cpp` steht vor jedem Methodennamen `DistanceSensor::`. Das sagt:
  Diese Funktion gehört zu dieser Klasse. Im Konstruktor speichert
  `this->trigPin` den übergebenen Wert im eigenen Objekt. `this` zeigt auf
  das Objekt, das gerade benutzt wird.

  `readCm` enthält dieselbe Messung wie in Kapitel 3: 10 Mikrosekunden
  Trigger, `pulseIn` mit dem Limit 25000 und die Division durch 58. Bei
  einem Timeout liefert die Methode `-1`. Das heißt: keine gültige
  Messung, und das Auto stoppt.

  = Mission: Notbremse mit Klasse

  Jetzt verbindest du beides. Die `.ino` bindet den Header ein, legt ein
  Objekt an und benutzt es in `loop`. Die Pins, `stopMotors`, `drive` und das
  Start-Gate bleiben wie in Kapitel 3.

  #gap("/code/126_classes/126_classes_exercise/126_classes_exercise.ino", [
    Ergänze die `TODO`-Zeilen. Lege zuerst das Objekt `sensor` mit
    `PIN_TRIG` und `PIN_ECHO` an. Rufe dann in `setup` die Methode `begin`
    auf. In `loop` liest du den Abstand mit `sensor.readCm()` und entscheidest
    wie bei der Notbremse: unter 20 cm oder keine Messung: anhalten, sonst fahren.
  ])

  #notespace(lines: 8)

  #solution("/code/126_classes/126_classes_solution/126_classes_solution.ino",
    title: [Notbremse mit Klasse])

  In der Lösung siehst du den Unterschied zur Datei aus Kapitel 3: Die
  Messfunktion ist verschwunden. Stattdessen steht oben ein einziges Objekt,
  und `loop` ruft `sensor.readCm()` auf. Die `.ino` ist kürzer geworden, und
  die Messung steckt wiederverwendbar in der Klasse.

  #probiere[
    Ändere in `loop` die Schwelle von 20 auf 35 cm.
    Ein zweiter Sensor ist nur eine *optionale Erweiterung*. Ein zweites
    HC-SR04 gehört nicht zur Teileliste, und D10 ist schon der Servo.
    Wenn du einen zweiten Sensor hast: Servo abbauen oder D10 freigeben,
    zwei freie Pins wählen, zum Beispiel D11 und A3, und
    `DistanceSensor hinten(11, A3);` anlegen. Rufe `hinten.begin()` in
    `setup` auf und gib beide Werte im Serial Monitor aus.
    Ohne zweiten Sensor übst du nur das Anlegen: Lege
    `DistanceSensor links(PIN_TRIG, PIN_ECHO);` und
    `DistanceSensor rechts(PIN_TRIG, PIN_ECHO);` an. Rufe für `links`
    `readCm()` auf und gib für `rechts` einen festen Testwert aus, etwa
    `int testwert = 40;`. So bleiben zwei getrennte Objekte, ohne dass du
    einen zweiten Sensor brauchst.
  ]

  #fehler((
    ([`DistanceSensor.h: No such file or directory`],
      [Der Header liegt nicht im selben Ordner wie die `.ino`. Prüfe den
      Dateinamen und die Groß- und Kleinschreibung.]),
    ([`multiple definition of ...`],
      [Die Methode steht doppelt: einmal in der `.ino` und einmal in der `.cpp`.
      Lass die Definition nur in der `.cpp` stehen und setze `#pragma once` in den Header.]),
    ([`'sensor' was not declared in this scope`],
      [Das Objekt steht nicht oben bei den Konstanten, oder der Name ist
      falsch geschrieben. Groß- und Kleinschreibung zählt.]),
    ([Der Sensor liefert `-1` oder keine Messung],
      [Es fehlt das Echo. Prüfe, ob `begin()` aufgerufen wurde, ob TRIG und
      ECHO vertauscht sind (D13 und D12) und ob das Kabel sitzt. Das Auto
      stoppt bei `-1` absichtlich.]),
  ))

  #merken[
    Ein Header enthält nur Deklarationen, die `.cpp` die Definitionen.
    `#include "..."` sucht im eigenen Ordner, `#include <...>` in den
    Bibliotheken. `#pragma once` verhindert doppelte Definitionen.
    Eine Klasse bündelt Daten und Methoden. `public` ist von außen sichtbar,
    `private` nur innen. Der Konstruktor hat den Namen der Klasse.
  ]

  #checklist((
    [Ich kann einen Sketch in Header, Quelle und `.ino` aufteilen],
    [Ich weiß, was `#pragma once` verhindert],
    [Ich kann den Unterschied zwischen `public` und `private` erklären],
    [Ich lege ein Objekt an und rufe seine Methoden auf],
    [Meine Notbremse benutzt die Klasse `DistanceSensor`],
  ))
]
