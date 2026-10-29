// Beispiel 021 - Mittelwert
// Kapitel 1: Aufgabe Mittelwert
const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus
int values[3] = {24, 30, 27};  // drei Messwerte in cm
void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
}
// TODO: Ergänze die Funktion average().
float average(int a, int b, int c) {
  // TODO: Summe bilden, durch 3.0 teilen, Ergebnis zurueckgeben.
  return 0;
}
void setup() {
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  stopMotors();
  Serial.begin(9600);
  // TODO: average() mit den drei Array-Werten aufrufen.
  float mean = 0;
  Serial.print(F("Mittelwert: "));
  Serial.print(mean);
  Serial.println(F(" cm"));
}
void loop() {
}
