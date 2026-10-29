// Beispiel 016 - Zählen mit for und while
// Kapitel 1: for und while
const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus
void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
}
void setup() {
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  stopMotors();
  Serial.begin(9600);
  Serial.println(F("for-Schleife:"));
  for (int i = 3; i >= 1; i--) {
    Serial.print(i);
    Serial.println(F(" ..."));
  }
  Serial.println(F("while-Schleife:"));
  int battery = 3;
  while (battery > 0) {
    Serial.println(battery);
    battery = battery - 1;
  }
  Serial.println(F("Akku leer."));
}
void loop() {
}
