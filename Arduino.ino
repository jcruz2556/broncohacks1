#include "thingProperties.h"
#include <ArduinoHttpClient.h>
#include <Servo.h>

Servo myServo;  // Create a servo object
Servo myServo1;
const char* serverAddress = "broncohacks-494423.wl.r.appspot.com";
const int port = 80;
const char* apiPath = "/readings/panel";

WiFiClient wifiClient;
HttpClient client(wifiClient, serverAddress, port);

unsigned long lastSend = 0;

// Light sensor pins
const int pinUR = A3;
const int pinUL = A1;
const int pinLL = A0;
const int pinLR = A5;

void setup() {
  Serial.begin(115200);
  delay(1500);
  myServo.attach(9);        // Attach the first servo to pin 9
  myServo1.attach(10);      // Attach the second servo to pin 10
  myServo1.write(120);  

  pinMode(LED_BUILTIN, OUTPUT);

  initProperties();
  ArduinoCloud.begin(ArduinoIoTPreferredConnection);

  setDebugMessageLevel(2);
  ArduinoCloud.printDebugInfo();
}

void loop() {
  ArduinoCloud.update();

  digitalWrite(LED_BUILTIN, led);

  if (millis() - lastSend >= 5000) {
    lastSend = millis();

    a0Value = analogRead(pinLL);
    a1Value = analogRead(pinUL);
    a3Value = analogRead(pinUR);
    a5Value = analogRead(pinLR);
// Print sensor values for debugging
Serial.print("Sensor UR: "); Serial.print(a3Value);
Serial.print(" | Sensor UL: "); Serial.print(a1Value);
Serial.print(" | Sensor LL: "); Serial.print(a0Value);
Serial.print(" | Sensor LR: "); Serial.println(a5Value);

// Determine which sensor detects the most light
if (a1Value < a3Value && a1Value < a0Value && a1Value < a5Value) {
    myServo.write(180);  
    myServo1.write(90);
    Serial.println("Servo moved (UL has the most light)");
}
else if (a3Value < a1Value && a3Value < a0Value && a3Value < a5Value) {
    myServo.write(90);
    myServo1.write(90);
    Serial.println("Servo moved (UR has the most light)");
}
else if (a0Value < a1Value && a0Value < a3Value && a0Value < a5Value) {
    myServo.write(90); 
    myServo1.write(180);
    Serial.println("Servo moved (LL has the most light)");
}
else if (a5Value < a1Value && a5Value < a3Value && a5Value < a0Value) {
    myServo.write(0); 
    myServo1.write(90);
    Serial.println("Servo moved (LR has the most light)");
}
else {
    Serial.println("No clear light direction detected.");
}
    delay(300);
    

    sendToAPI();
  }
}

void sendToAPI() {
  String json = "{";
  json += "\"a0\":" + String(a0Value) + ",";
  json += "\"a1\":" + String(a1Value) + ",";
  json += "\"a3\":" + String(a3Value) + ",";
  json += "\"a5\":" + String(a5Value);
  json += "}";

  Serial.println("Sending:");
  Serial.println(json);

  client.beginRequest();
  client.post(apiPath);
  client.sendHeader("Content-Type", "application/json");
  client.sendHeader("Content-Length", json.length());
  client.beginBody();
  client.print(json);
  client.endRequest();

  Serial.print("Status: ");
  Serial.println(client.responseStatusCode());

  client.stop();
}

void onLedChange() {
  Serial.print("LED changed: ");
  Serial.println(led);
}
