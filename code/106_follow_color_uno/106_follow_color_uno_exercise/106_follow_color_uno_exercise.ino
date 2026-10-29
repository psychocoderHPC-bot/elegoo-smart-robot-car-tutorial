// Beispiel 106 - Dem farbigen Punkt folgen
#include <FastLED.h>
const uint8_t PIN_PWMA=5, PIN_AIN1=7;   // rechter Motor
const uint8_t PIN_PWMB=6, PIN_BIN1=8;   // linker Motor
const uint8_t PIN_STBY=3, PIN_BUTTON=2, PIN_LED=4;  // Treiber, Taste, LED
const int IMG_CENTER=160, MIN_WIDTH=12, STEER_DIV=4;  // Bild/Breite/Lenkung
const int BASE_SPEED=120, SEARCH_SPEED=70, SEARCH_FLIP_MS=1200;  // Tempo
const unsigned long LOST_MS=600;  // Ziel kurz weg: suchen
const unsigned long CAM_LOST_MS=3000;  // keine Kamera: anhalten
CRGB leds[1]; char buf[48]; int bufLen=0, searchDir=1;  // Puffer/Laenge
unsigned long lastSeen=0, lastFlip=0;  // letzte Sicht/Drehung

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
void setStatus(CRGB color) {
  leds[0] = color;
  FastLED.show();
}
bool readTelegram() {
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '{') { bufLen = 0; }
    else if (c == '}') { buf[bufLen] = '\0'; return true; }
    else if (bufLen < (int)sizeof(buf) - 1) { buf[bufLen++] = c; }
  }
  return false;
}
// Sucht "x":160 in text und gibt 160 zurueck. Sonst -1.
int readValue(const char *text, char key) {
  const char *p = strchr(text, key);
  if (p == NULL) return -1;
  p = strchr(p, ':');
  if (p == NULL) return -1;
  return atoi(p + 1);
}
void follow(int x, int w) {
  if (w < MIN_WIDTH) {  // zu weit weg
    stopMotors(); setStatus(CRGB::Red);
    return;
  }
  int error = x - IMG_CENTER;
  int steer = error / STEER_DIV;
  drive(BASE_SPEED + steer, BASE_SPEED - steer);
  setStatus(CRGB::Green);
}
void search() {
  drive(SEARCH_SPEED * searchDir, -SEARCH_SPEED * searchDir);
  setStatus(CRGB::Blue);
  if (millis() - lastFlip > SEARCH_FLIP_MS) {
    searchDir = -searchDir; lastFlip = millis();
  }
}
void setup() {
  Serial.begin(9600); pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_STBY, OUTPUT); pinMode(PIN_AIN1, OUTPUT);
  pinMode(PIN_BIN1, OUTPUT); pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  stopMotors();
  FastLED.addLeds<WS2812, PIN_LED, GRB>(leds, 1);
  setStatus(CRGB::Black);
  waitForStart();
  lastSeen = millis(); lastFlip = millis();
}
void loop() {
  if (readTelegram()) {
    int x = readValue(buf, 'x'), w = readValue(buf, 'w');
    if (x >= 0 && w >= 0) {
      lastSeen = millis(); follow(x, w);
      return;
    }
  }
  if (millis() - lastSeen > CAM_LOST_MS) {
    stopMotors(); setStatus(CRGB::Red);
  } else if (millis() - lastSeen > LOST_MS) {
    search();
  }
}
