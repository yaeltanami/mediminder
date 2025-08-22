# MediMinder

MediMinder is a complete system for managing medications, combining a **Flutter mobile app**, a **Node.js backend server**, and an **ESP32 microcontroller** for smart pillbox integration.

📌 Jira board: [MediMinder Project](https://yaeltanami22-1716922574370.atlassian.net/jira/core/projects/PM/board)

---

## 📂 Project Structure

- `app/` – Flutter mobile application (patients & caregivers).
- `MediMinder-Server/` – Node.js backend server (REST API + DB).
- `esp32/` – Arduino/ESP32 code for the smart pillbox hardware.

---

## 🚀 Getting Started

### 1) Clone the repository
```bash
git clone https://github.com/yaeltanami/mediminder.git
cd mediminder

### 2) Run the Server (Node.js)
1. Go into the server folder:
  cd MediMinder-Server
2. Install dependencies:
  npm install
3. Start the server:
  npm start

### 3) Configure the IP Address
Before running the app, you must update the IP in the config file so the app knows how to reach your server.
1. Find your local IP address:
  Windows:
   run:  ipconfig
   Look for IPv4 Address under your active network.

  Mac/Linux:
    run: ifconfig
    Look for inet under your active network.

2. Open the config file in the Flutter app:
  app/lib/config.dart
  Update the serverIp field with your IP:
    class Config {
      static const String serverIp = '192.168.1.15'; // your computer’s IP
      static const int serverPort = 5050;

      static String get baseUrl => 'http://$serverIp:$serverPort/api';
    }

### ⚠️ Make sure both your phone/emulator and your computer are on the same Wi-Fi network!

### 4) Run the Flutter App :
1. Go into the app folder:
  cd app
2. Install dependencies:
  flutter pub get
3.Run the app on your device/emulator:
  flutter run
