// Beispiel 121 - Geheimcode: Erst 1, dann 2, dann 3, dann faehrt es.
#include <IRremote.hpp>
#include <FastLED.h>
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_IR = 9;      // IR-Empfaenger
const uint8_t PIN_LED = 4;     // WS2812
const int DRIVE_SPEED = 140;    // 140 von 255
const int TURN_SPEED = 130;     // 130 von 255
const uint8_t SECRET[] = {1, 2, 3};  // geheime Ziffernfolge
const uint8_t SECRET_LEN = 3;  // Laenge der Ziffernfolge
CRGB leds[1];
uint8_t step = 0;  // aktueller Schritt
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
void setLed(CRGB color) {
  leds[0] = color; FastLED.show();
}
// IRremote 4.x: command der Familie A. Andere Fernbedienung mit
// Beispiel 086 messen und die Werte hier eintragen.
uint8_t digitFromCommand(uint8_t cmd) {
  if (cmd == 0x68) return 1;  // Taste 1
  if (cmd == 0x98) return 2;  // Taste 2
  if (cmd == 0xB0) return 3;  // Taste 3
  return 0;
}
void playFigure() {
  drive(DRIVE_SPEED, DRIVE_SPEED); delay(600);
  drive(-TURN_SPEED, TURN_SPEED); delay(450);
  drive(DRIVE_SPEED, DRIVE_SPEED); delay(600);
  drive(TURN_SPEED, -TURN_SPEED); delay(450);
  stopMotors();
}
void handleDigit(uint8_t digit) {
  if (digit == SECRET[step]) {
    step++;
    Serial.print(F("Stufe ")); Serial.println(step);
    if (step == SECRET_LEN) {
      setLed(CRGB::Green);
      Serial.println(F("Offen!"));
      playFigure();
      step = 0;
      setLed(CRGB::Black);
    }
    return;
  }
  step = 0; setLed(CRGB::Red); Serial.println(F("Falsch"));
  delay(600); setLed(CRGB::Black);
  if (digit == SECRET[0]) step = 1;  // die 1 beginnt neu
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT); pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT); pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT); pinMode(PIN_BUTTON, INPUT_PULLUP);
  stopMotors();
  FastLED.addLeds<WS2812, PIN_LED, GRB>(leds, 1);
  FastLED.setBrightness(60);
  setLed(CRGB::Black);
  IrReceiver.begin(PIN_IR, false);  // D13 bleibt frei
  waitForStart();
}
void loop() {
  if (!IrReceiver.decode()) return;
  uint8_t cmd = IrReceiver.decodedIRData.command;
  IrReceiver.resume();
  uint8_t digit = digitFromCommand(cmd);
  if (digit != 0) handleDigit(digit);
}
