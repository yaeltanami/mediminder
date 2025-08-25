//MakerGo ESP32 C3 SuperMini
// ESP32 Code
#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <time.h>

// Network credentials
const char* ssid = "BeSpot36AD_2.4";
const char* password = "390436AD";

WebServer server(80);

// Pin definitions
const int NUM_LEDS = 5;
const int ledPins[NUM_LEDS] = { 5, 6, 7, 8, 9 };     // LED pins
const int buttonPins[NUM_LEDS] = { 4, 3, 2, 1, 0 };  // Button pins
const String color[NUM_LEDS] = { "Red", "Green", "Blue", "Yellow", "Purple" };
// LED states
bool ledStates[NUM_LEDS] = { false, false, false, false, false };
bool lastButtonStates[NUM_LEDS] = { false, false, false, false, false };
unsigned long ledActivationTimes[NUM_LEDS] = { 0, 0, 0, 0, 0 };
bool reminderSent[NUM_LEDS] = { false, false, false, false, false };

void setup() {
  Serial.begin(115200);


  // Initialize LED pins
  for (int i = 0; i < NUM_LEDS; i++) {
    pinMode(ledPins[i], OUTPUT);
    digitalWrite(ledPins[i], HIGH);
    pinMode(buttonPins[i], INPUT_PULLUP);
  }

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi");
  Serial.println("IP address: " + WiFi.localIP().toString());

  // Sending MAC and IP to the server
  registerPillBoxWithServer();

   
  // Synchronize with NTP clock
  configTime(0, 0, "pool.ntp.org");
  time_t now = time(nullptr);
  while (now < 100000) {
    delay(500);
    Serial.print("*"); 
    now = time(nullptr);
  }

  Serial.println("\n✅ NTP time received!");
  Serial.println(ctime(&now));

  // Setup server routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/setLeds", HTTP_GET, handleSetLeds);
  server.on("/status", HTTP_GET, handleStatus);
  server.begin();
}

void loop() {
  server.handleClient();
  checkButtons();
  checkReminderTimers();
}

void checkButtons() {
  for (int i = 0; i < NUM_LEDS; i++) {
    bool currentState = !digitalRead(buttonPins[i]); 

    if (currentState != lastButtonStates[i]) {
      if (currentState) { // לחיצה על כפתור
        ledStates[i] = false;
        digitalWrite(ledPins[i], HIGH); // כיבוי הלד
        reminderSent[i] = false; // reset reminder
        // Create a report
        String timestamp = getTimeISO();
        int slotNumber = i + 1;

        // Sending POST to Node.js server
        WiFiClient client;
        HTTPClient http;

        http.begin(client, "http://10.0.0.15:5050/api/esp/report-taken"); 
        http.addHeader("Content-Type", "application/json");

        String payload = "{\"slotNumber\":" + String(slotNumber) + ",\"timestamp\":\"" + timestamp + ",\"macAddress\":\"" + WiFi.macAddress() +"\"}";
        int httpResponseCode = http.POST(payload);

        Serial.println("📡 POST sent to server:");
        Serial.println(payload);
        Serial.print("Response code: ");
        Serial.println(httpResponseCode);

        http.end();
      }
      lastButtonStates[i] = currentState;
    }
  }
}
void checkReminderTimers() {
  unsigned long now = millis();
  for (int i = 0; i < NUM_LEDS; i++) {
    if (ledStates[i] && !reminderSent[i]) {
      if (ledActivationTimes[i] > 0 && now - ledActivationTimes[i] >= 60000) {
        WiFiClient client;
        HTTPClient http;
        http.begin(client, "http://10.0.0.15:5050/api/esp/reminder-alert");
        http.addHeader("Content-Type", "application/json");

        String payload = "{\"slotNumber\":" + String(i + 1) + ",\"macAddress\":\"" + WiFi.macAddress() + "\"}";
        int httpResponseCode = http.POST(payload);

        Serial.println(" Reminder sent for slot " + String(i + 1));
        Serial.println("Response code: " + String(httpResponseCode));

        http.end();
        reminderSent[i] = true;
      }
    }
  }
}
String getTimeISO() {
  time_t now = time(nullptr);
  struct tm *timeinfo = localtime(&now);
  char buf[25];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", timeinfo);
  return String(buf);
}

void registerPillBoxWithServer() {
  String mac = WiFi.macAddress();
  String ip = "http://" + WiFi.localIP().toString();


  Serial.println(" Registering pillbox with MAC: " + mac + " and IP: " + ip);

  WiFiClient client;
  HTTPClient http;

  http.begin(client, "http://10.0.0.15:5050/api/esp/register-pillbox");
  http.addHeader("Content-Type", "application/json");

  String payload = "{";
  payload += "\"macAddress\": \"" + mac + "\",";
  payload += "\"ip\": \"" + ip + "\"";
  payload += "}";

  int httpResponseCode = http.POST(payload);

  Serial.println("Sent: " + payload);
  Serial.println("Server response code: " + String(httpResponseCode)); 
  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("Server reply: " + response);
  } else {
    Serial.println("Failed to send POST request");
  }

  http.end();
}

void handleRoot() {
  String html = "<!DOCTYPE html><html><head>";
  html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
  html += "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css'>";
  html += "</head><body style='padding: 20px'>";
  html += "<h1>ESP32 Pill control</h1>";
  html += "<div id='ledControls'>";
  for (int i = 0; i < NUM_LEDS; i++) {
    html += "<label><input type='checkbox' id='led" + String(i) + "'> LED " + color[i] + "</label><br>";
  }
  html += "</div>";
  html += "<button onclick='updateLEDs()'>Update LEDs</button>";
  html += "<p id='status'></p>";
  html += "<script>";
  html += "function updateLEDs() {";
  html += "  let states = [];";
  html += "  for(let i = 0; i < " + String(NUM_LEDS) + "; i++) {";
  html += "    states.push(document.getElementById('led'+i).checked ? '1' : '0');";
  html += "  }";
  html += "  fetch('/setLeds?states=' + states.join('')).then(response => response.text()).then(updateStatus);";
  html += "}";
  html += "function updateStatus(status) {";
  html += "  document.getElementById('status').textContent = 'Current LED states: ' + status;";
  html += "}";
  html += "setInterval(() => fetch('/status').then(response => response.text()).then(updateStatus), 1000);";
  html += "</script></body></html>";
  server.send(200, "text/html", html);
}

void handleSetLeds() {
  if (server.hasArg("states")) {
    String states = server.arg("states");
    if (states.length() == NUM_LEDS) {
      for (int i = 0; i < NUM_LEDS; i++) {
        ledStates[i] = (states.charAt(i) == '1');
        digitalWrite(ledPins[i], ledStates[i] ? LOW : HIGH);
        if (ledStates[i]) {
          ledActivationTimes[i] = millis();
          reminderSent[i] = false;
        }
      }
    }
  }
  server.send(200, "text/plain", getCurrentStatus());
}

void handleStatus() {
  server.send(200, "text/plain", getCurrentStatus());
}

String getCurrentStatus() {
  String status = "";
  for (int i = 0; i < NUM_LEDS; i++) {
    status += ledStates[i] ? "1" : "0";
  }
  return status;
}

/*
אדום
ירוק
כחול
צהוב
סגול
*/
