// Beispiel 096 - Fahren mit Buchstaben
// Fahre mit Buchstaben. q und e aendern das Tempo sofort.
const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;  // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;  // linker Motor: Richtung
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield

const int SPEED_STEP = 20;  // Schrittweite pro Tastendruck
const int SPEED_MIN = 60;  // kleinstes Tempo
const int SPEED_MAX = 220;  // groesstes Tempo
const unsigned long REMOTE_TIMEOUT_MS = 1000;  // Stopp ohne Befehl

int speed = 140;  // aktuelles Tempo
int8_t dirLeft = 0;   // -1 zurueck, 0 halt, 1 vor
int8_t dirRight = 0;  // -1 zurueck, 0 halt, 1 vor
unsigned long lastCommand = 0;  // Zeit des letzten gueltigen Befehls

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
// Gespeicherte Richtung mit dem aktuellen Tempo erneut ausgeben.
void applyDrive() {
  if (dirLeft == 0 && dirRight == 0) {
    stopMotors();
  } else {
    drive(dirLeft * speed, dirRight * speed);
  }
}
bool moving() {
  return dirLeft != 0 || dirRight != 0;
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
void handleKey(char c) {
  if (c == 'v') {
    dirLeft = 1; dirRight = 1;
  } else if (c == 'z') {
    dirLeft = -1; dirRight = -1;
  } else if (c == 'l') {
    dirLeft = -1; dirRight = 1;
  } else if (c == 'r') {
    dirLeft = 1; dirRight = -1;
  } else if (c == 's') {
    dirLeft = 0; dirRight = 0;
  } else if (c == 'q') {
    if (speed > SPEED_MIN) speed -= SPEED_STEP;
  } else if (c == 'e') {
    if (speed < SPEED_MAX) speed += SPEED_STEP;
  } else {
    return;
  }
  // q und e wirken auch waehrend der Fahrt sofort.
  applyDrive();
  lastCommand = millis();
  Serial.print(F("Tempo: "));
  Serial.println(speed);
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_BUTTON, INPUT_PULLUP); pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT); pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_PWMA, OUTPUT); pinMode(PIN_PWMB, OUTPUT);
  stopMotors();
  Serial.println(F("v vor, z zurueck, l links, r rechts, s stop"));
  Serial.println(F("q langsamer, e schneller"));
  waitForStart();
}
void loop() {
  int c = Serial.read();
  if (c > 0) handleKey((char)c);
  // Watchdog: ohne neuen Befehl nach kurzer Zeit anhalten.
  if (moving() && millis() - lastCommand > REMOTE_TIMEOUT_MS) {
    dirLeft = 0; dirRight = 0;
    stopMotors();
    Serial.println(F("Stopp: kein Befehl."));
  }
}
