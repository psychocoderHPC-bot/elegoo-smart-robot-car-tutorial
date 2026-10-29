// Beispiel 126 - Notbremse mit eigener Klasse
// Kapitel 12, Aufgabe: Nutze die Klasse DistanceSensor.
// Ergaenze die TODO-Zeilen.
#include "DistanceSensor.h"      // Klasse einbinden

const uint8_t PIN_PWMA = 5;      // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;      // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;      // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;      // linker Motor: Richtung
const uint8_t PIN_STBY = 3;      // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;    // Taste auf dem Shield
const uint8_t PIN_TRIG = 13;     // Ultraschall Senden
const uint8_t PIN_ECHO = 12;     // Ultraschall Empfangen
const int STOP_DISTANCE_CM = 20; // naeher heran: anhalten
const int DRIVE_SPEED = 120;     // 120 von 255

// TODO: Lege ein Objekt sensor mit PIN_TRIG und PIN_ECHO an.

void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
}

void drive(int leftSpeed, int rightSpeed) {
  leftSpeed = constrain(leftSpeed, -255, 255);
  rightSpeed = constrain(rightSpeed, -255, 255);
  digitalWrite(PIN_BIN1, leftSpeed >= 0);
  digitalWrite(PIN_AIN1, rightSpeed >= 0);
  analogWrite(PIN_PWMB, abs(leftSpeed));
  analogWrite(PIN_PWMA, abs(rightSpeed));
  digitalWrite(PIN_STBY, HIGH);
}

bool buttonPressed() {
  if (digitalRead(PIN_BUTTON) == LOW) {
    delay(30);                   // Prellen ignorieren
    return digitalRead(PIN_BUTTON) == LOW;
  }
  return false;
}

void waitForStart() {
  Serial.println(F("Bereit. Druecke die Taste auf dem Shield."));
  while (!buttonPressed()) {
    delay(20);
  }
  while (buttonPressed()) {
    delay(20);
  }
  for (int i = 3; i > 0; i--) {
    Serial.print(i);
    Serial.println(F(" ..."));
    delay(1000);
  }
  Serial.println(F("Los!"));
}

void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT);     // Motorpins vorbereiten
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT);
  pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  // TODO: Setze die Sensorpins mit sensor.begin().
  stopMotors();
  waitForStart();
}

void loop() {
  int cm = 0;                    // TODO: mit sensor.readCm() fuellen
  Serial.print(cm);
  Serial.println(F(" cm"));

  if (cm < 0 || cm < STOP_DISTANCE_CM) {
    // TODO: beide Motoren anhalten
  } else {
    // TODO: geradeaus fahren
  }
  delay(200);
}
