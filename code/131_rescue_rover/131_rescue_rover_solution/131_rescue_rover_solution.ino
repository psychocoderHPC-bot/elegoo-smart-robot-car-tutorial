// Beispiel 131 - Rettungsrover
#include <Servo.h>
#include <FastLED.h>
const uint8_t PIN_PWMA=5, PIN_PWMB=6, PIN_AIN1=7, PIN_BIN1=8; // Motor
const uint8_t PIN_STBY=3, PIN_BUTTON=2;  // Treiber, Taste
const uint8_t PIN_TRIG=13, PIN_ECHO=12;  // Ultraschall
const uint8_t PIN_SERVO=10, PIN_LED=4;   // Kopf, LED
const uint8_t PIN_LINE_LEFT=A2, PIN_LINE_MIDDLE=A1;  // Linien-Sensoren
const uint8_t PIN_LINE_RIGHT=A0;  // Linien-Sensor rechts
enum State { FOLLOW_LINE, OBSTACLE, SEARCH, CROSSING, END };
State state = FOLLOW_LINE;
unsigned long stateSince = 0, whiteSince = 0;  // Zustandszeiten
uint8_t crossings = 0;  // Anzahl Querlinien
unsigned long lastProgress = 0;  // letzter Fortschritt
const char* const STATE_NAMES[] = {"FOLLOW", "OBSTACLE", "SEARCH",
                                   "CROSSING", "END"};
const CRGB STATE_LED[] = {CRGB::Blue, CRGB::Red, CRGB::Yellow,
                          CRGB::Blue, CRGB::Green};
const int LINE_THRESHOLD=600, BASE_SPEED=110, STEER_GAIN=90;  // Regelwerte
const int OBSTACLE_CM=25, SEARCH_MS=2000, WHITE_MS=300;  // Abstand/Zeiten
const int SCAN_LEFT=20, SCAN_RIGHT=150, SCAN_WAIT=400;  // Scan
const unsigned long RESCUE_MAX_MS = 30000;  // ohne Fortschritt: Stopp
CRGB leds[1]; Servo headServo;
void stopMotors() {
  analogWrite(PIN_PWMA,0); analogWrite(PIN_PWMB,0);
  digitalWrite(PIN_STBY,LOW);
}
void drive(int l, int r) {
  l = constrain(l, -255, 255); r = constrain(r, -255, 255);
  digitalWrite(PIN_BIN1, l >= 0); digitalWrite(PIN_AIN1, r >= 0);
  analogWrite(PIN_PWMB, abs(l)); analogWrite(PIN_PWMA, abs(r));
  digitalWrite(PIN_STBY, HIGH);
}
bool buttonPressed() {
  if (digitalRead(PIN_BUTTON) != LOW) return false;
  delay(30); return digitalRead(PIN_BUTTON) == LOW;
}
void waitForStart() {
  Serial.println(F("Bereit. Druecke die Taste."));
  while (!buttonPressed()) delay(20);
  while (buttonPressed()) delay(20);
  for (int i = 3; i > 0; i--) { Serial.print(i); delay(1000); }
  Serial.println(F("Los!"));
}
int readDistanceCm() {
  digitalWrite(PIN_TRIG, LOW); delayMicroseconds(2);
  digitalWrite(PIN_TRIG, HIGH); delayMicroseconds(10);
  digitalWrite(PIN_TRIG, LOW);
  unsigned long t = pulseIn(PIN_ECHO, HIGH, 25000);
  if (t == 0) return -1;  // kein Echo: ungueltig, nicht "frei"
  return (int)(t / 58UL);
}
bool onBlack(uint8_t pin) { return analogRead(pin) < LINE_THRESHOLD; }
void lookAt(int angle) {
  headServo.write(angle); delay(SCAN_WAIT);
}
void setState(State next) {
  state = next; stateSince = millis();
  if (next == CROSSING) { crossings++; lastProgress = millis(); }
  if (next == FOLLOW_LINE) whiteSince = 0;
  leds[0] = STATE_LED[next]; FastLED.show();
  Serial.println(STATE_NAMES[next]);
}
void followLine(unsigned long now) {
  bool l=onBlack(PIN_LINE_LEFT), m=onBlack(PIN_LINE_MIDDLE);
  bool r=onBlack(PIN_LINE_RIGHT);
  if (l && m && r) { setState(CROSSING); return; }
  if (!l && !m && !r) {
    if (whiteSince == 0) whiteSince = now;
    if (now - whiteSince > WHITE_MS) { setState(SEARCH); return; }
  } else whiteSince = 0;
  int cm = readDistanceCm();
  if (cm < 0) { stopMotors(); setState(OBSTACLE); return; }
  if (cm < OBSTACLE_CM) { setState(OBSTACLE); return; }
  int e = l ? -1 : (r ? 1 : 0);
  drive(BASE_SPEED + e * STEER_GAIN, BASE_SPEED - e * STEER_GAIN);
}
void avoidObstacle() {
  stopMotors();
  if (readDistanceCm() < 0) { setState(END); return; }
  drive(-110, -110); delay(400); stopMotors();
  lookAt(SCAN_LEFT); int l = readDistanceCm();
  lookAt(90); int m = readDistanceCm();
  lookAt(SCAN_RIGHT); int r = readDistanceCm(); lookAt(90);
  if (l < 0 || m < 0 || r < 0) { setState(END); return; }
  if (l > m && l >= r) drive(-120, 120); else if (r > m) drive(120, -120);
  delay(500); stopMotors(); setState(SEARCH);
}
void searchLine(unsigned long now) {
  if (onBlack(PIN_LINE_LEFT)||onBlack(PIN_LINE_MIDDLE)||
      onBlack(PIN_LINE_RIGHT)) { setState(FOLLOW_LINE); return; }
  if (now - stateSince > SEARCH_MS) { stopMotors(); return; }
  drive(70, 30);
}
void crossLine(unsigned long now) {
  if (now - stateSince < 250) { drive(90, 90); return; }
  if (onBlack(PIN_LINE_LEFT)&&onBlack(PIN_LINE_MIDDLE)&&
      onBlack(PIN_LINE_RIGHT)) return;
  if (crossings >= 3) { stopMotors(); lookAt(90); setState(END); }
  else setState(FOLLOW_LINE);
}
void setup() {
  Serial.begin(9600); pinMode(PIN_PWMA, OUTPUT); pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT); pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT); pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_TRIG, OUTPUT); pinMode(PIN_ECHO, INPUT);
  pinMode(PIN_LINE_LEFT, INPUT); pinMode(PIN_LINE_MIDDLE, INPUT);
  pinMode(PIN_LINE_RIGHT, INPUT);
  headServo.attach(PIN_SERVO); stopMotors(); lookAt(90);
  FastLED.addLeds<WS2812, PIN_LED, GRB>(leds, 1);
  FastLED.setBrightness(60); leds[0]=CRGB::Black; FastLED.show();
  lastProgress = millis(); waitForStart(); setState(FOLLOW_LINE);
}
void loop() {
  unsigned long now = millis();
  if (state != END && now - lastProgress > RESCUE_MAX_MS) {
    stopMotors(); setState(END); return;
  }
  switch (state) {
    case FOLLOW_LINE: followLine(now); break;
    case OBSTACLE: avoidObstacle(); break;
    case SEARCH: searchLine(now); break;
    case CROSSING: crossLine(now); break;
    case END: stopMotors(); break;
  }
}
