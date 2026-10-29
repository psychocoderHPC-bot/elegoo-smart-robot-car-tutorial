// Beispiel 031 - Rampe von 0 bis 255
// Kapitel 2: Geschwindigkeit in Stufen erhoehen
const uint8_t PIN_PWMA = 5;    // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;    // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;    // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;    // linker Motor: Richtung
const uint8_t PIN_STBY = 3;    // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield

const int RAMP_STEP = 51;      // 0, 51, 102, 153, 204, 255
const int STEP_DELAY_MS = 400;  // Zeit zwischen Schritten
const int LEFT_TRIM = 0;  // Korrektur linker Motor
const int RIGHT_TRIM = 0;  // Korrektur rechter Motor

void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
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
  while (buttonPressed()) {
    delay(20);
  }
  for (int i = 3; i > 0; i--) {
    Serial.print(i);
    Serial.println(F(" ..."));
    delay(1000);
  }
  Serial.println(F("Los!"));
}

void driveForward(int speed) {
  drive(speed + LEFT_TRIM, speed + RIGHT_TRIM);
}

void setup() {
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT);
  pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  stopMotors();
  Serial.begin(9600);
}

void loop() {
  waitForStart();
  Serial.println(F("Rampe vorwaerts"));
  for (int pwm = 0; pwm <= 255; pwm += RAMP_STEP) {
    driveForward(pwm);
    Serial.print(F("PWM "));
    Serial.println(pwm);
    delay(STEP_DELAY_MS);
  }
  stopMotors();
  Serial.println(F("Aus."));
}
