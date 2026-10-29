// Beispiel 011 - Zu nah, passt, weit weg
// Kapitel 1: Entscheidungen mit if und else
const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus
const int distance = 25;  // cm, angenommener Messwert
const int NEAR_CM = 20;   // naeher als das ist zu nah
const int FAR_CM = 60;    // weiter als das ist weit weg
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
  if (distance < NEAR_CM) {
    Serial.println(F("Zu nah!"));
  } else if (distance <= FAR_CM) {
    Serial.println(F("Passt."));
  } else {
    Serial.println(F("Weit weg."));
  }
}
void loop() {
}
