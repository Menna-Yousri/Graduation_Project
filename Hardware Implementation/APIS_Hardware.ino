#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

const char* ssid = "Galaxy M3126AE";
const char* password = "88&&29>;<M!362R";

ESP8266WebServer server(80);

// Values from Arduino
String temp = "0";
String gas = "0";
String voc = "0";

void setup() {
  Serial.begin(9600);  // Serial to Arduino
  WiFi.begin(ssid, password);
  Serial.println("Connecting to WiFi...");

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected.");
  Serial.println(WiFi.localIP());

  server.on("/temp", []() {
    server.send(200, "application/json", "{\"temperature\":" + temp + "}");
  });

  server.on("/gas", []() {
    server.send(200, "application/json", "{\"gas\":" + gas + "}");
  });

  server.on("/voc", []() {
    server.send(200, "application/json", "{\"voc\":" + voc + "}");
  });

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();

  // Read from Arduino
  if (Serial.available()) {
    String line = Serial.readStringUntil('\n');
    if (line.startsWith("DATA")) {
      int firstComma = line.indexOf(',');
      int secondComma = line.indexOf(',', firstComma + 1);
      int thirdComma = line.indexOf(',', secondComma + 1);

      if (firstComma > 0 && secondComma > firstComma) {
        temp = line.substring(firstComma + 1, secondComma);
        gas  = line.substring(secondComma + 1, thirdComma);
        voc  = line.substring(thirdComma + 1);
      }
    }
  }
}