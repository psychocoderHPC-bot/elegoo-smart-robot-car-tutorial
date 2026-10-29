// Beispiel 061 - Kopf drehen
// Kopf langsam nach links, geradeaus, rechts und zurueck drehen.
#include <Servo.h>

const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_SERVO = 10;  // Servo
const int STEP_DELAY_MS = 400; // Zeit zwischen zwei Winkeln
Servo headServo;
bool buttonPressed() {
  if (digitalRead(PIN_BUTTON) == LOW) {
    delay(30);  // Prellen ignorieren
    return digitalRead(PIN_BUTTON) == LOW;
  }
  return false;
}
void waitForStart() {
  Serial.println(F("Bereit. Druecke die Taste auf dem Shield."));
  while (!buttonPressed()) {
    delay(20);
  }
  while (buttonPressed()) {  // warten, bis die Taste losgelassen ist
    delay(20);
  }
  for (int i = 3; i > 0; i--) {
    Serial.print(i);
    Serial.println(F(" ..."));
    delay(1000);
  }
  Serial.println(F("Los!"));
}
void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
}
void lookAt(int angle) {
  headServo.write(angle);
  delay(STEP_DELAY_MS);
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT); pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT); pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT); pinMode(PIN_BUTTON, INPUT_PULLUP);
  stopMotors();
  headServo.attach(PIN_SERVO);
  lookAt(90);  // geradeaus starten
  waitForStart();
}
void loop() {
  lookAt(0);    // links
  lookAt(90);   // geradeaus
  lookAt(180);  // rechts
  lookAt(90);   // zurueck in die Mitte
  delay(800);
}
