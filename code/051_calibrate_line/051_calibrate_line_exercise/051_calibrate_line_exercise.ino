// Beispiel 051 - Rohwerte anzeigen
// Kapitel 4: Rohwerte der drei Liniensensoren anzeigen.

const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_LINE_LEFT = A2;  // Linien-Sensor links
const uint8_t PIN_LINE_MIDDLE = A1;  // Linien-Sensor Mitte
const uint8_t PIN_LINE_RIGHT = A0;  // Linien-Sensor rechts

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
  Serial.print(F("links "));
  Serial.print(analogRead(PIN_LINE_LEFT));
  Serial.print(F("  mitte "));
  Serial.print(analogRead(PIN_LINE_MIDDLE));
  Serial.print(F("  rechts "));
  Serial.println(analogRead(PIN_LINE_RIGHT));
  delay(300);
}
