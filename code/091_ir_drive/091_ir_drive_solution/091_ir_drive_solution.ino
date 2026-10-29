// Beispiel 091 - Mission Fernbedienung
// Fahren mit der IR-Fernbedienung der Familie A (Elegoo).
#include <IRremote.hpp>

const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_AIN1 = 7;  // rechter Motor: Richtung
const uint8_t PIN_BIN1 = 8;  // linker Motor: Richtung
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus
const uint8_t PIN_BUTTON = 2;  // Taste auf dem Shield
const uint8_t PIN_IR = 9;  // IR-Empfaenger

const int SPEED = 160;  // festes Tempo, 0..255
const unsigned long REMOTE_TIMEOUT_MS = 1000;  // Stopp ohne Befehl

// --- Fernbedienung: Befehle der Familie A (Elegoo) -------------------
// Andere Fernbedienung (Familie B)? Mit 086 messen und die Zahlen hier
// eintragen. Es gibt nur diese eine Stelle im Sketch.
const uint8_t CMD_UP = 0x62;     // hoch
const uint8_t CMD_DOWN = 0xA8;   // runter
const uint8_t CMD_LEFT = 0x22;   // links
const uint8_t CMD_RIGHT = 0xC2;  // rechts
const uint8_t CMD_OK = 0x02;     // anhalten

bool driving = false;  // laufen die Motoren gerade?
unsigned long lastCommand = 0;  // Zeit des letzten gueltigen Befehls

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
    delay(30);
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

void handleCode(uint8_t command) {
  switch (command) {
    case CMD_UP: drive(SPEED, SPEED); break;
    case CMD_DOWN: drive(-SPEED, -SPEED); break;
    case CMD_LEFT: drive(-SPEED, SPEED); break;
    case CMD_RIGHT: drive(SPEED, -SPEED); break;
    case CMD_OK: stopMotors(); break;
    default: return;  // unbekannte Taste ignorieren
  }
  driving = (command != CMD_OK);
  lastCommand = millis();
}

void setup() {
  Serial.begin(9600);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_AIN1, OUTPUT);
  pinMode(PIN_BIN1, OUTPUT);
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  stopMotors();
  // DISABLE_LED_FEEDBACK laesst D13 frei.
  IrReceiver.begin(PIN_IR, DISABLE_LED_FEEDBACK);
  waitForStart();
}

void loop() {
  if (IrReceiver.decode()) {
    uint8_t command = IrReceiver.decodedIRData.command;
    IrReceiver.resume();
    handleCode(command);
  }
  // Watchdog: ohne neuen Befehl nach kurzer Zeit anhalten.
  if (driving && millis() - lastCommand > REMOTE_TIMEOUT_MS) {
    stopMotors();
    driving = false;
    Serial.println(F("Stopp: kein IR-Befehl."));
  }
}
