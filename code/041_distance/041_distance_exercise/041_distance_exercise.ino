// Beispiel 041 - Abstand anzeigen
// Kapitel 3: Abstand messen und im Serial Monitor anzeigen.

const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_TRIG = 13;   // Ultraschall Senden
const uint8_t PIN_ECHO = 12;   // Ultraschall Empfangen

void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
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

int readAverageCm() {
  long sum = 0;
  for (int i = 0; i < 3; i++) {
    int cm = readDistanceCm();
    if (cm < 0) {
      return -1;  // eine ungueltige Messung genuegt
    }
    sum += cm;
    delay(20);
  }
  return (int)(sum / 3);
}

void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT);
  pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_TRIG, OUTPUT);
  pinMode(PIN_ECHO, INPUT);
  stopMotors();
  waitForStart();
}

void loop() {
  int cm = readAverageCm();
  if (cm < 0) {
    Serial.println(F("keine Messung"));
  } else {
    Serial.print(cm);
    Serial.println(F(" cm"));
  }
  delay(200);
}
