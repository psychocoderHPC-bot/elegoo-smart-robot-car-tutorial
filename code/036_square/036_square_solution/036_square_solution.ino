// Beispiel 036 - Quadrat
// Kapitel 2: Loesung Quadrat fahren
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const int DRIVE_SPEED = 130;  // 130 von 255
const int TURN_SPEED = 120;   // 120 von 255
const int SIDE_MS = 1200;     // Zeit fuer eine Seite
const int TURN_MS = 620;      // Zeit fuer 90 Grad
const int LEFT_TRIM = 0;  // Korrektur linker Motor
const int RIGHT_TRIM = 0;  // Korrektur rechter Motor
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
void driveForward(int speed) {
  drive(speed + LEFT_TRIM, speed + RIGHT_TRIM);
}
void turnLeft(int speed) {
  drive(-speed, speed);
}
bool buttonPressed() {
  if (digitalRead(PIN_BUTTON) == LOW) {
    delay(30);
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

void driveOneSide() {
  driveForward(DRIVE_SPEED);
  delay(SIDE_MS);
  stopMotors();
  delay(200);
}

void driveSquare() {
  for (int side = 0; side < 4; side++) {
    driveOneSide();
    turnLeft(TURN_SPEED);
    delay(TURN_MS);
    stopMotors();
    delay(200);
  }
}

void setup() {
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT);
  pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  stopMotors();
  Serial.begin(9600);
}

void loop() {
  waitForStart();
  Serial.println(F("Quadrat startet"));
  driveSquare();
  Serial.println(F("Fertig"));
}
