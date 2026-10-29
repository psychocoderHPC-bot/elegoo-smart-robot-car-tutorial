// Beispiel 066 - Der freie Weg
// Kapitel 5, Aufgabe: Ergaenze nur chooseAndDrive().
// Der Rest des Sketches ist fertig und baut so, wie er ist.
#include <Servo.h>
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_TRIG = 13;   // Ultraschall Senden
const uint8_t PIN_ECHO = 12;   // Ultraschall Empfangen
const uint8_t PIN_SERVO = 10;  // Servo
const int STEP_MS = 400;       // Wartezeit nach jedem Winkel
const int TURN_SPEED = 120;    // Drehgeschwindigkeit, 120 von 255
const int DRIVE_SPEED = 150;   // Fahrgeschwindigkeit, 150 von 255
const int MIN_FREE_CM = 30;    // weniger Platz: nicht fahren
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
void drive(int leftSpeed, int rightSpeed) {
  leftSpeed = constrain(leftSpeed, -255, 255);
  rightSpeed = constrain(rightSpeed, -255, 255);
  digitalWrite(PIN_BIN1, leftSpeed >= 0);
  digitalWrite(PIN_AIN1, rightSpeed >= 0);
  analogWrite(PIN_PWMB, abs(leftSpeed));
  analogWrite(PIN_PWMA, abs(rightSpeed));
  digitalWrite(PIN_STBY, HIGH);
}
int readDistanceCm() {
  digitalWrite(PIN_TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(PIN_TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(PIN_TRIG, LOW);
  unsigned long duration = pulseIn(PIN_ECHO, HIGH, 25000);
  if (duration == 0) {
    return -1;  // kein Echo: ungueltige Messung
  }
  return (int)(duration / 58UL);
}
int lookAndMeasure(int angle) {
  headServo.write(angle);
  delay(STEP_MS);
  return readDistanceCm();
}
void chooseAndDrive(int leftCm, int middleCm, int rightCm) {
  int bestAngle = 90;  // 0 = links, 90 = Mitte, 180 = rechts
  int bestCm = middleCm;
  // TODO: Ist leftCm groesser? Dann bestCm und bestAngle setzen.
  // TODO: Ist rightCm groesser? Dann bestCm und bestAngle setzen.
  // TODO: Kopf auf 90 Grad stellen und STEP_MS warten.
  // TODO: Ist bestCm kleiner als MIN_FREE_CM? Dann stoppen und return.
  // TODO: Sonst in Richtung bestAngle drehen und geradeaus fahren.
  stopMotors();  // Platzhalter, damit der Sketch jetzt schon baut
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT); pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT); pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT); pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_TRIG, OUTPUT); pinMode(PIN_ECHO, INPUT);
  stopMotors();
  headServo.attach(PIN_SERVO);
  headServo.write(90);
  waitForStart();
}
void loop() {
  int leftCm = lookAndMeasure(0);
  int middleCm = lookAndMeasure(90);
  int rightCm = lookAndMeasure(180);
  chooseAndDrive(leftCm, middleCm, rightCm);
}
