// Beispiel 086 - Codes auslesen
// Lern-Sketch: zeigt Protokoll, Adresse, Befehl und Rohwert.
#include <IRremote.hpp>

const uint8_t PIN_PWMA = 5;  // rechter Motor: Geschwindigkeit
const uint8_t PIN_PWMB = 6;  // linker Motor: Geschwindigkeit
const uint8_t PIN_STBY = 3;  // Motortreiber ein/aus
const uint8_t PIN_IR = 9;  // IR-Empfaenger

void stopMotors() {
  analogWrite(PIN_PWMA, 0);
  analogWrite(PIN_PWMB, 0);
  digitalWrite(PIN_STBY, LOW);
}
void setup() {
  Serial.begin(9600);
  pinMode(PIN_STBY, OUTPUT);
  pinMode(PIN_PWMA, OUTPUT);
  pinMode(PIN_PWMB, OUTPUT);
  stopMotors();
  // DISABLE_LED_FEEDBACK laesst D13 frei.
  IrReceiver.begin(PIN_IR, DISABLE_LED_FEEDBACK);
  Serial.println(F("Druecke eine Taste der Fernbedienung."));
}

void loop() {
  if (IrReceiver.decode()) {
    Serial.print(F("Protokoll "));
    Serial.print((uint8_t)IrReceiver.decodedIRData.protocol);
    Serial.print(F(" Adresse 0x"));
    Serial.print(IrReceiver.decodedIRData.address, HEX);
    Serial.print(F(" Befehl 0x"));
    Serial.print(IrReceiver.decodedIRData.command, HEX);
    Serial.print(F(" Roh 0x"));
    Serial.println(IrReceiver.decodedIRData.decodedRawData, HEX);
    IrReceiver.resume();
  }
}
