// Beispiel 126 - Klasse fuer den Ultraschallsensor
// Kapitel 12: Header mit der Deklaration der Klasse.
#pragma once                     // Datei nur einmal einbinden
#include <Arduino.h>             // uint8_t, pinMode und pulseIn

class DistanceSensor {           // Bauplan fuer einen Sensor
 public:                         // von aussen sichtbar
  DistanceSensor(uint8_t trigPin, uint8_t echoPin);  // Konstruktor
  void begin();                  // Pins als Ein-/Ausgang setzen
  int readCm();                  // Abstand in Zentimetern liefern

 private:                        // nur in der Klasse sichtbar
  uint8_t trigPin;               // Pin zum Senden
  uint8_t echoPin;               // Pin zum Empfangen
};
