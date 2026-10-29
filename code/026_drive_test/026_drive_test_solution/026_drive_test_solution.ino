// Beispiel 026 - Vor, zurück und drehen
// Kapitel 2: Erste Fahrt nach dem Start-Gate
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const int TEST_SPEED = 140;  // 140 von 255
const int LEFT_TRIM = 0;     // hier spaeter korrigieren
const int RIGHT_TRIM = 0;    // hier spaeter korrigieren
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
void driveForward(int speed) {
  drive(speed + LEFT_TRIM, speed + RIGHT_TRIM);
}
void driveBackward(int speed) {
  drive(-speed - LEFT_TRIM, -speed - RIGHT_TRIM);
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
  Serial.println(F("Vorwaerts"));
  driveForward(TEST_SPEED);
  delay(1000);
  stopMotors();
  delay(500);
  Serial.println(F("Rueckwaerts"));
  driveBackward(TEST_SPEED);
  delay(1000);
  stopMotors();
  delay(500);
  Serial.println(F("Links drehen"));
  drive(-TEST_SPEED, TEST_SPEED);
  delay(600);
  stopMotors();
  delay(500);
  Serial.println(F("Rechts drehen"));
  drive(TEST_SPEED, -TEST_SPEED);
  delay(600);
  stopMotors();
  Serial.println(F("Fertig. Taste druecken."));
}
