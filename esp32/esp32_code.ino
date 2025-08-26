
// Keeps original behavior: register with server, NTP time, web UI, reminders, report-taken.
// Changes: pin maps for S3 + active-high LED logic (HIGH=ON, LOW=OFF).

#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <time.h>

// ===== Network credentials =====
const char* ssid     = "tanami";
const char* password = "10203040";

WebServer server(80); // local web server on port 80

// ===== Pin definitions (ESP32-S3 build) =====
const int NUM_LEDS = 5;
const int ledPins[NUM_LEDS]    = { 9, 8, 7, 6, 10 };   // LED pins (S3 wiring)
const int buttonPins[NUM_LEDS] = { 4, 3, 2, 1, 5 };    // Button pins (S3 wiring)
const String color[NUM_LEDS]   = { "Red", "Green", "Blue", "Yellow", "Purple" };

// ===== LED & button states =====
// ledStates[i] = true means LED should be ON (dose due)
bool ledStates[NUM_LEDS]        = { false, false, false, false, false };
bool lastButtonStates[NUM_LEDS] = { false, false, false, false, false };

// reminder timing
unsigned long ledActivationTimes[NUM_LEDS] = { 0, 0, 0, 0, 0 };
bool reminderSent[NUM_LEDS]                = { false, false, false, false, false };

// ======= Forward decls =======
void handleRoot();
void handleSetLeds();
void handleStatus();
void checkButtons();
void checkReminderTimers();
String getCurrentStatus();
String getTimeISO();
void registerPillBoxWithServer();

void setup() {
  Serial.begin(115200);

  // --- Pins ---
  for (int i = 0; i < NUM_LEDS; i++) {
    pinMode(ledPins[i], OUTPUT);
    digitalWrite(ledPins[i], LOW);      // ACTIVE-HIGH: LOW = OFF at boot
    pinMode(buttonPins[i], INPUT_PULLUP);
  }

  // --- Wi-Fi ---
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi");
  Serial.println("IP address: " + WiFi.localIP().toString());

  // --- Register device with backend (MAC + IP) ---
  registerPillBoxWithServer();

  // --- NTP time sync ---
  configTime(0, 0, "pool.ntp.org");
  time_t now = time(nullptr);
  while (now < 100000) { // wait until time is valid
    delay(500);
    Serial.print("*");
    now = time(nullptr);
  }
  Serial.println("\nNTP time received!");
  Serial.println(ctime(&now));

  // --- HTTP routes ---
  server.on("/", HTTP_GET, handleRoot);
  server.on("/setLeds", HTTP_GET, handleSetLeds); // update LEDs
  server.on("/status", HTTP_GET, handleStatus);   // LED status string
  server.begin();
}

void loop() {
  server.handleClient();
  checkButtons();
  checkReminderTimers();
}

// ===== Buttons: detect "taken" =====
void checkButtons() {
  for (int i = 0; i < NUM_LEDS; i++) {
    bool currentState = !digitalRead(buttonPins[i]); // INPUT_PULLUP: pressed = LOW -> invert -> true

    if (currentState != lastButtonStates[i]) {
      if (currentState) { // pressed (edge)
        // Turn OFF LED (acknowledge dose)
        ledStates[i] = false;
        digitalWrite(ledPins[i], LOW); // ACTIVE-HIGH: LOW = OFF
        reminderSent[i] = false;       // reset reminder flag

        // Timestamp + slot
        String timestamp = getTimeISO();
        int slotNumber = i + 1;

        // Report to server
        WiFiClient client;
        HTTPClient http;
        http.begin(client, "http://10.100.102.17:5050/api/esp/report-taken");
        http.addHeader("Content-Type", "application/json");

String payload = "{\"slotNumber\":" + String(slotNumber) +
                 ",\"timestamp\":\"" + timestamp + "\"" +
                 ",\"macAddress\":\"" + WiFi.macAddress() + "\"}";
        int httpResponseCode = http.POST(payload);

        Serial.println("POST sent to server:");
        Serial.println(payload);
        Serial.print("Response code: ");
        Serial.println(httpResponseCode);

        http.end();
      }
      lastButtonStates[i] = currentState;
    }
  }
}

// ===== Reminder: send alert if LED stays on for 60s =====
void checkReminderTimers() {
  unsigned long now = millis();
  for (int i = 0; i < NUM_LEDS; i++) {
    if (ledStates[i] && !reminderSent[i]) {
      if (ledActivationTimes[i] > 0 && now - ledActivationTimes[i] >= 60000UL) { // 60,000 ms = 60s
        WiFiClient client;
        HTTPClient http;
        http.begin(client, "http://10.100.102.17:5050/api/esp/reminder-alert");
        http.addHeader("Content-Type", "application/json");

        String payload = "{\"slotNumber\":" + String(i + 1) + ",\"macAddress\":\"" + WiFi.macAddress() + "\"}";
        int httpResponseCode = http.POST(payload);

        Serial.println("Reminder sent for slot " + String(i + 1));
        Serial.println("Response code: " + String(httpResponseCode));

        http.end();
        reminderSent[i] = true;
      }
    }
  }
}

// ===== Helpers =====
String getTimeISO() {
  time_t now = time(nullptr);
  struct tm *timeinfo = localtime(&now); // if you want strict UTC, use gmtime(&now)
  char buf[25];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", timeinfo);
  return String(buf);
}

void registerPillBoxWithServer() {
  String mac = WiFi.macAddress();
  String ip  = "http://" + WiFi.localIP().toString();

  Serial.println("Registering pillbox with MAC: " + mac + " and IP: " + ip);

  WiFiClient client;
  HTTPClient http;

  http.begin(client, "http://10.100.102.17:5050/api/esp/register-pillbox");
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

// ===== Web UI =====
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
  html += "  fetch('/setLeds?states=' + states.join('')).then(r => r.text()).then(updateStatus);";
  html += "}";
  html += "function updateStatus(status) {";
  html += "  document.getElementById('status').textContent = 'Current LED states: ' + status;";
  html += "}";
  html += "setInterval(() => fetch('/status').then(r => r.text()).then(updateStatus), 1000);";
  html += "</script></body></html>";
  server.send(200, "text/html", html);
}

// Update LEDs from browser
void handleSetLeds() {
  if (server.hasArg("states")) {
    String states = server.arg("states");
    if (states.length() == NUM_LEDS) {
      for (int i = 0; i < NUM_LEDS; i++) {
        bool newState = (states.charAt(i) == '1');
        ledStates[i] = newState;

        // ACTIVE-HIGH: HIGH = ON, LOW = OFF
        digitalWrite(ledPins[i], newState ? HIGH : LOW);

        if (newState) {
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

