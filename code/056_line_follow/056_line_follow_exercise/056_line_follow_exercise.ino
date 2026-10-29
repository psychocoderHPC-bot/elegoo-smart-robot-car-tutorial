// Beispiel 056 - Der Linie folgen
// Kapitel 4, Aufgabe: Der Linie folgen.
// Ergaenze die TODOs in loop(). Der Rest ist fertig und baut schon.
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_LINE_LEFT = A2;  // Linien-Sensor links
const uint8_t PIN_LINE_MIDDLE = A1;  // Linien-Sensor Mitte
const uint8_t PIN_LINE_RIGHT = A0;  // Linien-Sensor rechts
const int LINE_THRESHOLD = 600;  // kleiner: schwarz
const int BASE_SPEED = 110;      // Grundtempo, 110 von 255
const int STEER_GAIN = 90;       // Lenkstaerke pro Fehlerschritt

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

bool onBlack(uint8_t pin) {
  return analogRead(pin) < LINE_THRESHOLD;
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT);
  pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_LINE_LEFT, INPUT);
  pinMode(PIN_LINE_MIDDLE, INPUT);
  pinMode(PIN_LINE_RIGHT, INPUT);
  stopMotors();
  waitForStart();
}

void loop() {
  bool onLeft = onBlack(PIN_LINE_LEFT);
  bool onMiddle = onBlack(PIN_LINE_MIDDLE);
  bool onRight = onBlack(PIN_LINE_RIGHT);
  // TODO: alle drei weiss: stopMotors(), Meldung, delay, return.
  // TODO: alle drei schwarz: stopMotors(), delay, return.
  int error = 0;
  // TODO: links schwarz ergibt -1, rechts schwarz ergibt +1.
  // TODO: steer berechnen und drive aufrufen.
  stopMotors();  // Platzhalter, damit der Sketch jetzt schon baut
  delay(10);
}
