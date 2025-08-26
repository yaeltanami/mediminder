// ==============================
// MediMinder ESP32 (C3/S3) – Full Working Sketch
// ==============================
//
// Features:
// - Works on ESP32-C3 SuperMini or ESP32-S3 (select below).
// - Local web UI: toggle 5 LEDs, see live status.
// - Buttons (active-low with INPUT_PULLUP) turn off their slot LED and POST "taken".
// - Auto-registers MAC/IP with Node server on boot.
// - NTP sync; timestamps are UTC ISO-8601 with 'Z' suffix.
// - Reminder POST after LED stays ON for N seconds (default 60).
// - Simple Wi-Fi auto-reconnect.
//
// ==== HOW TO USE ====
// 1. Select your board profile below (BOARD_PROFILE_*).
// 2. Fill your Wi-Fi SSID/PASS.
// 3. Set SERVER_HOST/IP + PORT if needed.
// 4. Flash & open Serial Monitor @115200.
// 5. Open http://<esp-ip>/ in your browser to control LEDs.
//
// ==============================

#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <time.h>

// ------------------------------
// 1) SELECT YOUR BOARD PROFILE
//    Uncomment ONE of the following lines.
// ------------------------------
#define BOARD_PROFILE_C3_SUPERMINI
// #define BOARD_PROFILE_S3_MODULE

// ------------------------------
// 2) NETWORK SETTINGS
// ------------------------------
const char* WIFI_SSID     = "tanami";
const char* WIFI_PASSWORD = "10203040";

// Your Node server (change to your LAN IP/port)
const char* SERVER_HOST = "10.100.102.17";
const uint16_t SERVER_PORT = 5050;    // default 5050
// API base path (no trailing '/')
const char* API_BASE = "/api/esp";

// Reminder timing (ms)
const unsigned long REMINDER_AFTER_MS = 60UL * 1000UL; // 60 seconds (adjust as you like)

// Button debounce (ms)
const unsigned long DEBOUNCE_MS = 50;

// ------------------------------
// 3) PIN MAP + LED ACTIVE POLARITY PER BOARD
// ------------------------------
const int NUM_LEDS = 5;

#ifdef BOARD_PROFILE_C3_SUPERMINI
// MakerGo ESP32-C3 SuperMini (your original mapping)
const int LED_PINS[NUM_LEDS]    = { 5, 6, 7, 8, 9 };
const int BUTTON_PINS[NUM_LEDS] = { 4, 3, 2, 1, 0 };
// Your C3 build used "HIGH = off, LOW = on"
const bool LED_ACTIVE_LOW = true;
#elif defined(BOARD_PROFILE_S3_MODULE)
// ESP32-S3 module (your new mapping)
const int LED_PINS[NUM_LEDS]    = { 9, 8, 7, 6, 10 };
const int BUTTON_PINS[NUM_LEDS] = { 4, 3, 2, 1, 5 };
// If your wiring is active-high on S3, set this to false.
// If you find LEDs inverted, flip this to true.
const bool LED_ACTIVE_LOW = false;
#else
#error "Select a board profile at the top!"
#endif

// Color labels (UI only)
const char* COLOR_NAMES[NUM_LEDS] = {"Red","Green","Blue","Yellow","Purple"};

// ------------------------------
// Globals
// ------------------------------
WebServer server(80);

// LED state machine
bool ledStates[NUM_LEDS]         = {false, false, false, false, false};
bool lastButtonSample[NUM_LEDS]  = {false, false, false, false, false};
bool stableButtonState[NUM_LEDS] = {false, false, false, false, false};
unsigned long lastBounceAt[NUM_LEDS] = {0,0,0,0,0};

// Reminder tracking
unsigned long ledTurnedOnAt[NUM_LEDS] = {0,0,0,0,0};
bool reminderSent[NUM_LEDS] = {false, false, false, false, false};

// ------------------------------
// Helpers: LED write with polarity
// ------------------------------
inline void writeLed(int idx, bool on)
{
  if (LED_ACTIVE_LOW) {
    digitalWrite(LED_PINS[idx], on ? LOW : HIGH);
  } else {
    digitalWrite(LED_PINS[idx], on ? HIGH : LOW);
  }
}

// ------------------------------
// HTTP helpers
// ------------------------------
String serverBaseUrl()
{
  String url = "http://";
  url += SERVER_HOST;
  url += ":";
  url += String(SERVER_PORT);
  url += API_BASE;
  return url;
}

int postJson(const String& path, const String& jsonBody, String* outResponse = nullptr)
{
  WiFiClient client;
  HTTPClient http;
  String url = serverBaseUrl() + path;

  http.begin(client, url);
  http.addHeader("Content-Type", "application/json");
  int code = http.POST(jsonBody);

  if (outResponse) {
    if (code > 0) *outResponse = http.getString();
    else *outResponse = "";
  }
  http.end();
  return code;
}

// ------------------------------
// Time: NTP + ISO UTC
// ------------------------------
void syncTime()
{
  // Use pool.ntp.org; offset 0, DST 0 -> we'll format as UTC 'Z'
  configTime(0, 0, "pool.ntp.org", "time.nist.gov", "pool.ntp.org");
  time_t now = time(nullptr);
  Serial.print("Syncing NTP");
  while (now < 100000) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
  }
  Serial.println();
  Serial.print("Time synced (UTC): ");
  Serial.println(ctime(&now));
}

// ISO-8601 UTC: "YYYY-MM-DDTHH:MM:SSZ"
String isoUtcNow()
{
  time_t now = time(nullptr);
  struct tm t;
  gmtime_r(&now, &t); // UTC
  char buf[25];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", &t);
  return String(buf);
}

// ------------------------------
// Wi-Fi
// ------------------------------
void ensureWifi()
{
  if (WiFi.status() == WL_CONNECTED) return;
  Serial.print("Reconnecting WiFi");
  WiFi.disconnect();
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("WiFi reconnected. IP: " + WiFi.localIP().toString());
  } else {
    Serial.println("WiFi reconnect failed.");
  }
}

// ------------------------------
// Server API calls
// ------------------------------
void registerPillBoxWithServer()
{
  String mac = WiFi.macAddress();
  String ip  = "http://" + WiFi.localIP().toString();

  String body = "{\"macAddress\":\"" + mac + "\",\"ip\":\"" + ip + "\"}";
  int code = postJson("/register-pillbox", body);
  Serial.println("[Register] POST " + String(code) + " body=" + body);
}

void reportTaken(int slotNumber)
{
  String ts = isoUtcNow();
  String body = "{\"slotNumber\":" + String(slotNumber) + ",\"timestamp\":\"" + ts + "\"}";
  int code = postJson("/report-taken", body);
  Serial.println("[Taken] slot=" + String(slotNumber) + " ts=" + ts + " -> " + String(code));
}

void sendReminder(int slotNumber)
{
  String body = "{\"slotNumber\":" + String(slotNumber) + ",\"macAddress\":\"" + WiFi.macAddress() + "\"}";
  int code = postJson("/reminder-alert", body);
  Serial.println("[Reminder] slot=" + String(slotNumber) + " -> " + String(code));
}

// ------------------------------
// Button handling (debounced, active-low)
// ------------------------------
void sampleButtons()
{
  unsigned long now = millis();
  for (int i = 0; i < NUM_LEDS; i++) {
    bool raw = (digitalRead(BUTTON_PINS[i]) == LOW); // active-low => LOW means pressed
    if (raw != lastButtonSample[i]) {
      lastButtonSample[i] = raw;
      lastBounceAt[i] = now;
    } else {
      // stable for long enough?
      if ((now - lastBounceAt[i]) >= DEBOUNCE_MS) {
        // state changed?
        if (stableButtonState[i] != raw) {
          stableButtonState[i] = raw;
          // on rising pressed edge
          if (raw) {
            // Button pressed => turn OFF LED + reset reminder + POST "taken"
            ledStates[i] = false;
            writeLed(i, false);
            reminderSent[i] = false;

            // report taken (1-based slot)
            reportTaken(i + 1);
          }
        }
      }
    }
  }
}

// ------------------------------
// Reminder timer check
// ------------------------------
void checkReminders()
{
  unsigned long now = millis();
  for (int i = 0; i < NUM_LEDS; i++) {
    if (ledStates[i] && !reminderSent[i]) {
      if (ledTurnedOnAt[i] > 0 && (now - ledTurnedOnAt[i]) >= REMINDER_AFTER_MS) {
        sendReminder(i + 1);
        reminderSent[i] = true;
      }
    }
  }
}

// ------------------------------
// Web UI
// ------------------------------
String makeStatusString()
{
  String s;
  s.reserve(NUM_LEDS);
  for (int i = 0; i < NUM_LEDS; i++) s += (ledStates[i] ? '1' : '0');
  return s;
}

void handleStatus()
{
  server.send(200, "text/plain", makeStatusString());
}

void handleSetLeds()
{
  if (server.hasArg("states")) {
    String states = server.arg("states");
    if ((int)states.length() == NUM_LEDS) {
      unsigned long now = millis();
      for (int i = 0; i < NUM_LEDS; i++) {
        bool newState = (states.charAt(i) == '1');
        if (ledStates[i] != newState) {
          ledStates[i] = newState;
          writeLed(i, newState);
          if (newState) {
            // turned ON -> start reminder countdown
            ledTurnedOnAt[i] = now;
            reminderSent[i] = false;
          } else {
            // turned OFF -> clear reminder state
            reminderSent[i] = false;
            ledTurnedOnAt[i] = 0;
          }
        }
      }
    }
  }
  handleStatus();
}

void handleRoot()
{
  String html;
  html.reserve(3000);
  html += "<!DOCTYPE html><html><head>";
  html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
  html += "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/milligram/1.4.1/milligram.min.css'>";
  html += "<style>body{padding:20px} .row{margin-bottom:8px}</style>";
  html += "</head><body>";
  html += "<h2>ESP32 Pill Control</h2>";
  html += "<p><b>Board:</b> ";
#ifdef BOARD_PROFILE_C3_SUPERMINI
  html += "ESP32-C3 SuperMini";
#else
  html += "ESP32-S3 Module";
#endif
  html += " &nbsp; <b>IP:</b> " + WiFi.localIP().toString() + "</p>";

  html += "<div id='ledControls'>";
  for (int i = 0; i < NUM_LEDS; i++) {
    html += "<div class='row'>";
    html += "<label><input type='checkbox' id='led" + String(i) + "'> LED " + COLOR_NAMES[i] + "</label>";
    html += "</div>";
  }
  html += "</div>";
  html += "<button onclick='updateLEDs()'>Update LEDs</button>";
  html += "<p id='status'></p>";

  html += "<script>";
  html += "function updateLEDs(){";
  html += " let states=[];";
  html += " for(let i=0;i<" + String(NUM_LEDS) + ";i++){";
  html += "  states.push(document.getElementById('led'+i).checked?'1':'0');";
  html += " }";
  html += " fetch('/setLeds?states='+states.join('')).then(r=>r.text()).then(updateStatus);";
  html += "}";
  html += "function updateStatus(s){";
  html += " if(typeof s!=='string'){return;}";
  html += " document.getElementById('status').textContent='Current LED states: '+s;";
  html += " for(let i=0;i<s.length;i++){";
  html += "   const c=document.getElementById('led'+i);";
  html += "   if(c) c.checked=(s[i]==='1');";
  html += " }";
  html += "}";
  html += "setInterval(()=>fetch('/status').then(r=>r.text()).then(updateStatus),1000);";
  html += "</script>";

  html += "</body></html>";
  server.send(200, "text/html", html);
}

// ------------------------------
// Setup / Loop
// ------------------------------
void setup()
{
  Serial.begin(115200);
  delay(100);

  // Pins
  for (int i = 0; i < NUM_LEDS; i++) {
    pinMode(LED_PINS[i], OUTPUT);
    writeLed(i, false); // start OFF
    pinMode(BUTTON_PINS[i], INPUT_PULLUP);
    // initialize button samples from current read
    lastButtonSample[i]  = (digitalRead(BUTTON_PINS[i]) == LOW);
    stableButtonState[i] = lastButtonSample[i];
    lastBounceAt[i] = millis();
  }

  // Fun little LED sweep on boot
  for (int i = 0; i < NUM_LEDS; i++) {
    writeLed(i, true);
    delay(150);
    writeLed(i, false);
  }

  // Wi-Fi
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.println("Connected. IP: " + WiFi.localIP().toString());

  // Register device to server
  registerPillBoxWithServer();

  // Time sync
  syncTime();

  // Web routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/setLeds", HTTP_GET, handleSetLeds);
  server.on("/status", HTTP_GET, handleStatus);
  server.begin();
  Serial.println("HTTP server started");
}

void loop()
{
  server.handleClient();
  ensureWifi();       // keep Wi-Fi up
  sampleButtons();    // debounced button logic
  checkReminders();   // send reminder POSTs when due
}
