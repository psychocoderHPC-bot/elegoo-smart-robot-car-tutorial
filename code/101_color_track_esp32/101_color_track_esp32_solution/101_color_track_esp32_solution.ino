// Beispiel 101 - Gruen suchen, x und w an den Uno senden.
#include "esp_camera.h"
// Kamera-Pins des Moduls M5STACK_WIDE
const int PWDN=-1, RESET=15, XCLK=27, SIOD=22, SIOC=23;  // Kamera-Pins
const int D0=32, D1=35, D2=34, D3=5, D4=39, D5=18, D6=36, D7=19;  // Daten
const int VSYNC=25, HREF=26, PCLK=21, RXD2=33, TXD2=4;  // Kamera-/UART-Pins
const int W=320, H=240, STEP=4, SEND_MS=100, MIN_COUNT=4;  // Bild/Timing
const int G_MIN=100, G_OVER_R=40, G_OVER_B=40;  // Gruen
void sendPosition(int x, int w) {
  // Lesbarer Wert fuer den Serial Monitor des ESP32.
  Serial.print(F("x=")); Serial.print(x);
  Serial.print(F(" w=")); Serial.println(w);
  // Dasselbe Telegramm an den Uno.
  Serial2.print(F("{\"x\":")); Serial2.print(x);
  Serial2.print(F(",\"w\":")); Serial2.print(w);
  Serial2.println(F("}"));
}
bool isTarget(uint8_t r, uint8_t g, uint8_t b) {
  return g>G_MIN && (g-r)>G_OVER_R && (g-b)>G_OVER_B;
}
void setup() {
  Serial.begin(9600); Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2);
  camera_config_t c = {
    PWDN, RESET, XCLK, SIOD, SIOC,
    D7, D6, D5, D4, D3, D2, D1, D0,
    VSYNC, HREF, PCLK, 10000000, LEDC_TIMER_0, LEDC_CHANNEL_0,
    PIXFORMAT_RGB565, FRAMESIZE_QVGA,
    12, 1, CAMERA_FB_IN_PSRAM, CAMERA_GRAB_LATEST, 0,
  };
  if (esp_camera_init(&c) != ESP_OK) {
    Serial.println(F("Kamera startet nicht."));
    return;
  }
  Serial.println(F("Kamera bereit."));
}
void loop() {
  camera_fb_t *fb = esp_camera_fb_get();
  if (fb == NULL) { delay(200); return; }
  long sumX=0; int count=0; int minX=W; int maxX=-1;
  for (int y=0; y<H; y+=STEP) {
    for (int x=0; x<W; x+=STEP) {
      long i = 2L*(y*W + x);
      uint16_t p = fb->buf[i] | (fb->buf[i+1] << 8);
      uint8_t r=((p>>11)&0x1F)*255/31, g=((p>>5)&0x3F)*255/63;
      uint8_t b=(p&0x1F)*255/31;
      if (isTarget(r,g,b)) {
        sumX+=x; count++;
        minX = min(minX, x); maxX = max(maxX, x);
      }
    }
  }
  esp_camera_fb_return(fb);
  int cx=W/2, w=0;
  if (count>=MIN_COUNT) { cx=sumX/count; w=maxX-minX; }
  sendPosition(cx, w);
  delay(SEND_MS);
}
