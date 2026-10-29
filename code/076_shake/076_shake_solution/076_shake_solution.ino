// Beispiel 076 - Mission Stossalarm
// Erkennt einen Stoss und warnt 2 Sekunden mit LED und Serial.
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <FastLED.h>
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_LED = 4;     // WS2812
const float SHAKE_LIMIT = 14.0;  // Schwelle in m/s^2
const float GYRO_RAD_TO_DEG = 57.2958;  // rad/s in Grad/s
const int WARN_MS = 2000;  // Dauer der Warnung
Adafruit_MPU6050 mpu;
sensors_event_t accel, gyro, temp;
CRGB leds[1];
unsigned long lastRatePrint = 0;  // Zeit der letzten Ausgabe

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
void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
}
void warnTwoSeconds(float total) {
  Serial.print(F("Stoss erkannt: "));
  Serial.println(total, 1);
  leds[0] = CRGB::Red;
  FastLED.show();
  unsigned long start = millis();
  while (millis() - start < WARN_MS) {
    delay(20);
  }
  leds[0] = CRGB::Black;
  FastLED.show();
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_PWMA, OUTPUT); pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT); pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT); pinMode(PIN_BUTTON, INPUT_PULLUP);
  stopMotors();
  FastLED.addLeds<WS2812, PIN_LED, GRB>(leds, 1);
  FastLED.setBrightness(40);
  leds[0] = CRGB::Black; FastLED.show();
  if (!mpu.begin()) {
    Serial.println(F("MPU6050 nicht gefunden. Kabel pruefen."));
    while (true) {
      delay(100);
    }
  }
  mpu.setAccelerometerRange(MPU6050_RANGE_2_G);
  mpu.setGyroRange(MPU6050_RANGE_250_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  delay(1000);  // Sensor kurz beruhigen
  waitForStart();
}
void loop() {
  mpu.getEvent(&accel, &gyro, &temp);
  // Drehrate hoechstens alle 200 ms als Grad pro Sekunde zeigen.
  unsigned long now = millis();
  if (now - lastRatePrint >= 200) {
    lastRatePrint = now;
    Serial.print(F("Drehrate "));
    Serial.print(gyro.gyro.x * GYRO_RAD_TO_DEG, 1);
    Serial.print(F(", "));
    Serial.print(gyro.gyro.y * GYRO_RAD_TO_DEG, 1);
    Serial.print(F(", "));
    Serial.print(gyro.gyro.z * GYRO_RAD_TO_DEG, 1);
    Serial.println(F(" deg/s"));
  }
  float ax = accel.acceleration.x;
  float ay = accel.acceleration.y;
  float az = accel.acceleration.z;
  float total = sqrt(ax * ax + ay * ay + az * az);
  if (total > SHAKE_LIMIT) {
    warnTwoSeconds(total);
    delay(300);  // kurz warten, damit der Stoss abklingt
  }
  delay(50);
}
