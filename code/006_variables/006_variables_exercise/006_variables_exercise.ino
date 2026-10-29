// Beispiel 006 - Vier Typen
// Kapitel 1: Variablen und eine kleine Rechnung
const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus
int distanceLeft = 30;   // cm, linker Messwert
int distanceRight = 42;  // cm, rechter Messwert
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
  float average = (distanceLeft + distanceRight) / 2.0;
  bool freeWay = average > 20;
  char sensor = 'A';
  Serial.print(F("Sensor "));
  Serial.print(sensor);
  Serial.print(F(": "));
  Serial.print(average);
  Serial.println(F(" cm"));
  Serial.print(F("Freie Fahrt? "));
  Serial.println(freeWay ? F("ja") : F("nein"));
}
void loop() {
}
