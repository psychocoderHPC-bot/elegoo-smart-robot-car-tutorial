// Beispiel 111 - Parkwaechter
// Der Kopf schwenkt, der Abstandswaechter meldet Alarm.
#include <Servo.h>
#include <FastLED.h>
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_TRIG = 13;   // Ultraschall Senden
const uint8_t PIN_ECHO = 12;   // Ultraschall Empfangen
const uint8_t PIN_SERVO = 10;  // Servo
const uint8_t PIN_LED = 4;     // WS2812
const int ALARM_CM = 40;        // naeher heran: Alarm
const int SWEEP_LEFT = 30;      // Grad
const int SWEEP_MIDDLE = 90;    // Grad
const int SWEEP_RIGHT = 150;    // Grad
const unsigned long SENSOR_LOST_MS = 5000;  // ohne Echo: Stopp
Servo headServo;
CRGB leds[1];
unsigned long lastValid = 0;  // letzte gueltige Messung
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
  while (buttonPressed()) {  // warten, bis die Taste losgelassen ist
    delay(20);
  }
  for (int i = 3; i > 0; i--) {
    Serial.print(i);
    Serial.println(F(" ..."));
    delay(1000);
  }
  Serial.println(F("Los!"));
}
void lookAt(int angle) {
  headServo.write(angle);
  delay(450);
}
int readDistanceCm() {
  digitalWrite(PIN_TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(PIN_TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(PIN_TRIG, LOW);
  unsigned long duration = pulseIn(PIN_ECHO, HIGH, 25000);
  if (duration == 0) {
    return -1;  // kein Echo: ungueltig, nicht "frei"
  }
  return (int)(duration / 58UL);
}
bool scanAt(int angle) {
  lookAt(angle);
  int cm = readDistanceCm();
  if (cm < 0) {  // Messung ungueltig: stehen bleiben
    leds[0] = CRGB::Red;
    FastLED.show();
    Serial.println(F("Alarm Sensorfehler"));
    return false;
  }
  lastValid = millis();
  bool alarm = cm < ALARM_CM;
  leds[0] = alarm ? CRGB::Red : CRGB::Green;
  FastLED.show();
  Serial.print(alarm ? F("Alarm ") : F("Frei "));
  Serial.print(cm); Serial.println(F(" cm"));
  return true;
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT); pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_STBY, OUTPUT); pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_TRIG, OUTPUT); pinMode(PIN_ECHO, INPUT);
  headServo.attach(PIN_SERVO);
  stopMotors();
  FastLED.addLeds<WS2812, PIN_LED, GRB>(leds, 1);
  FastLED.setBrightness(60);
  lastValid = millis();
  waitForStart();
}
void loop() {
  if (millis() - lastValid > SENSOR_LOST_MS) {
    stopMotors();
    leds[0] = CRGB::Red;
    FastLED.show();
    Serial.println(F("Sensor weg - Stopp"));
    return;  // Kopf bleibt stehen
  }
  if (!scanAt(SWEEP_LEFT)) return;
  if (!scanAt(SWEEP_MIDDLE)) return;
  if (!scanAt(SWEEP_RIGHT)) return;
  if (!scanAt(SWEEP_MIDDLE)) return;
  delay(300);
}
