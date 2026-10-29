// Beispiel 126 - Klasse fuer den Ultraschallsensor
// Kapitel 12: Hier stehen die Definitionen der Methoden.
#include "DistanceSensor.h"      // passender Header

DistanceSensor::DistanceSensor(uint8_t trigPin, uint8_t echoPin) {
  this->trigPin = trigPin;       // Wert im Objekt speichern
  this->echoPin = echoPin;       // Wert im Objekt speichern
}

void DistanceSensor::begin() {
  pinMode(trigPin, OUTPUT);      // Trigger sendet
  pinMode(echoPin, INPUT);       // Echo empfaengt
}

int DistanceSensor::readCm() {
  digitalWrite(trigPin, LOW);    // Impuls vorbereiten
  delayMicroseconds(2);          // kurze Pause
  digitalWrite(trigPin, HIGH);   // Startbefehl
  delayMicroseconds(10);         // 10 us Impuls
  digitalWrite(trigPin, LOW);    // Impuls beenden
  unsigned long dauer = pulseIn(echoPin, HIGH, 25000);  // warten
  if (dauer == 0) {              // kein Echo
    return -1;                   // -1 = ungueltig, kein Echo
  }
  return (int)(dauer / 58UL);    // Laufzeit in cm
}
