// Beispiel 116 - Tanzroboter (Aufgabe)
// Drei Strophen sind fertig. Schreibe die vierte.
#include <Servo.h>
#include <FastLED.h>
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_SERVO = 10;  // Servo
const uint8_t PIN_LED = 4;     // WS2812
const int DANCE_SPEED = 140;    // 140 von 255
const int TURN_SPEED = 130;     // 130 von 255
const int SERVO_LEFT = 55, SERVO_MIDDLE = 90, SERVO_RIGHT = 125;  // Winkel
Servo headServo;
CRGB leds[1];
void stopMotors() {
  analogWrite(PIN_PWMA, 0); analogWrite(PIN_PWMB, 0);
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
  while (!buttonPressed()) delay(20);
  while (buttonPressed()) delay(20);
  for (int i = 3; i > 0; i--) {
    Serial.print(i); Serial.println(F(" ..."));
    delay(1000);
  }
  Serial.println(F("Los!"));
}
void setLed(CRGB color) {
  leds[0] = color; FastLED.show();
}
void lookAt(int angle) {
  headServo.write(angle);
  delay(450);
}
void wiggleHead() {
  lookAt(SERVO_LEFT); lookAt(SERVO_RIGHT); lookAt(SERVO_MIDDLE);
}
void move(int leftSpeed, int rightSpeed, int ms) {
  drive(leftSpeed, rightSpeed); delay(ms); stopMotors(); delay(150);
}
void verseOne() {
  setLed(CRGB::Red); move(DANCE_SPEED, DANCE_SPEED, 700);
  move(-TURN_SPEED, TURN_SPEED, 500); wiggleHead();
}
void verseTwo() {
  setLed(CRGB::Blue); move(TURN_SPEED, -TURN_SPEED, 500);
  move(DANCE_SPEED, DANCE_SPEED, 900); wiggleHead();
}
void verseThree() {
  setLed(CRGB::Green); move(-DANCE_SPEED, -DANCE_SPEED, 500);
  move(-TURN_SPEED, TURN_SPEED, 800); wiggleHead();
}
void verseFour() {
  // TODO: setLed, move und wiggleHead zu einer Strophe verbinden
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT); pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT); pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT); pinMode(PIN_BUTTON, INPUT_PULLUP);
  headServo.attach(PIN_SERVO); stopMotors();
  FastLED.addLeds<WS2812, PIN_LED, GRB>(leds, 1);
  FastLED.setBrightness(60);
  waitForStart();
}
void loop() {
  verseOne(); verseTwo();
  verseThree(); verseFour();
  setLed(CRGB::Black); delay(1000);
}
