// Beispiel 081 - Vier Farben und einmal aus
// Eine RGB-LED an D4: Rot, Gruen, Blau, Orange, Aus.
#include <FastLED.h>
const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus
const uint8_t PIN_LED = 4;  // WS2812-LED
CRGB leds[1];
CRGB colors[] = {CRGB::Red, CRGB::Green, CRGB::Blue,
                 CRGB(255, 120, 0), CRGB::Black};
void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
}
void setup() {
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  stopMotors();
  FastLED.addLeds<WS2812, PIN_LED, GRB>(leds, 1);
  FastLED.setBrightness(60);
}
void loop() {
  for (uint8_t i = 0; i < 5; i++) {
    leds[0] = colors[i];
    FastLED.show();
    delay(500);
  }
  delay(1000);
}
