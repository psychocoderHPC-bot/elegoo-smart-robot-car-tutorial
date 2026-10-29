// Beispiel 001 - Hallo Arduino
// Kapitel 1: Hallo Arduino, Zaehler im Serial Monitor
const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus

int counter = 0;  // zaehlt die Runden in loop()

void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
}

void setup() {
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  stopMotors();  // Motoren bleiben aus

  Serial.begin(9600);
  Serial.println(F("Hallo! Ich bin der Arduino."));
}

void loop() {
  counter = counter + 1;
  Serial.print(F("Runde "));
  Serial.println(counter);
  delay(500);
}
