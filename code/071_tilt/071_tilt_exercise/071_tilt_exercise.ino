// Beispiel 071 - Roll und Pitch
// Neigung in Grad anzeigen: Roll (links/rechts) und Pitch (vorn/hinten).
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const float GYRO_RAD_TO_DEG = 57.2958;  // rad/s in Grad/s

Adafruit_MPU6050 mpu;
sensors_event_t accel, gyro, temp;

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

void setup() {
  Serial.begin(9600);

  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT);
  pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  stopMotors();

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

  float ax = accel.acceleration.x;
  float ay = accel.acceleration.y;
  float az = accel.acceleration.z;

  // Roll: Drehung um die Fahrtrichtung (links/rechts kippen).
  float roll = atan2(ay, az) * 180.0 / PI;
  // Pitch: Nase hoch oder runter.
  float pitch = atan2(-ax, sqrt(ay * ay + az * az)) * 180.0 / PI;

  // Gyro: Drehrate von rad/s in Grad pro Sekunde umrechnen.
  float gyroX = gyro.gyro.x * GYRO_RAD_TO_DEG;
  float gyroY = gyro.gyro.y * GYRO_RAD_TO_DEG;
  float gyroZ = gyro.gyro.z * GYRO_RAD_TO_DEG;

  Serial.print(F("Roll "));
  Serial.print(roll, 1);
  Serial.print(F(" Grad, Pitch "));
  Serial.print(pitch, 1);
  Serial.println(F(" Grad"));
  Serial.print(F("Drehrate "));
  Serial.print(gyroX, 1);
  Serial.print(F(", "));
  Serial.print(gyroY, 1);
  Serial.print(F(", "));
  Serial.print(gyroZ, 1);
  Serial.println(F(" deg/s"));
  delay(200);
}
