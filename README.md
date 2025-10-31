## Smart Home Control App

A modern Flutter + Node.js smart home controller with rooms, devices, energy analytics, and automation. Designed with a clean Material 3 UI and a simple REST backend.

### Highlights
- **Rooms & Devices**: Browse rooms, favorites, and device summaries
- **Profile & Customization**: Name, address, theme, language, notifications
- **Energy Analytics**: Sample data generation + charts-ready endpoints
- **Automation & Smart Functions**: Leave/Arrive modes, scheduling, energy save, sensors, and voice control placeholders
- **Secure-Ready**: Biometric and pairing options planned

---

### Tech Stack
- **Frontend**: Flutter 3, Provider, Material 3
- **Backend**: Node.js, Express, MongoDB (Mongoose)
- **Data**: Local storage fallback + REST APIs

---

### Project Structure
```text
Mobile_App/
  lib/
    screens/
      profile/
        profile_screen.dart      # Profile, Rooms, History, Customize, Security, Automation tabs
    providers/                   # SettingsProvider, RoomProvider
    models/                      # UserProfile, Room, etc.
  backend/
    src/
      index.js                   # Express bootstrap & Mongo connection
      models/                    # Mongoose models
      routes/                    # users, rooms, energy APIs
    package.json
  README.md
```

---

### Prerequisites
- Flutter SDK installed and on PATH
- Node.js 18+ and npm
- MongoDB Atlas (or local MongoDB). For Atlas, whitelist your IP and create a database user.

---

### Backend Setup
1) Copy env template and set your Mongo URI
```bash
cd backend
copy env.template .env   # on Windows PowerShell: Copy-Item env.template .env
```
Update `.env`:
```
MONGODB_URI=mongodb+srv://<USER>:<PASS>@<CLUSTER>/<DBNAME>
PORT=3000
```

2) Install and run
```bash
cd backend
npm install
npm run dev
```
You should see: `API listening on http://localhost:3000` and `✅ MongoDB connected successfully`.

Troubleshooting MongoDB Atlas:
- Ensure your current IP is whitelisted in Atlas
- Verify username/password in `MONGODB_URI`
- Confirm the cluster is running and network access is enabled

---

### Frontend Setup (Flutter)
1) From the project root:
```bash
flutter pub get
```

2) Run (Web or Mobile)
```bash
flutter run
```
Select Chrome/Edge for web, or a connected device/emulator.

Hot restart when changing tabs count/controllers (like adding the Automation tab).

Fonts on Web:
- If you see “Could not find a set of Noto fonts…”, add a font asset to `pubspec.yaml` or run on mobile where system fonts cover glyphs.

MQTT on Web:
- TLS `SecurityContext` isn’t available on web; use REST or mock providers when testing in Chrome.

---

### Key Screens
#### Profile
- Header with avatar, name, address
- Edit profile: name, address, preferred unit (kWh / Rs)

#### Rooms
- Summary metrics: total rooms, devices, favorites
- Room list with quick stats and navigation

#### History
- Recent logs from `SettingsProvider`

#### Customize
- Theme: System / Light / Dark
- Language: Sinhala, Tamil, English, Hindi
- Notifications and Accessibility mode

#### Security
- Password, biometrics, secure pairing (coming soon)

#### Automation & Smart Functions
- Gradient header with quick actions
- Leave Home / Arrive Home modes with toggles and run buttons
- Scheduling system with time pickers (AC, Lights)
- Energy Save Mode with peak hour start/end
- Voice Control integration placeholders (Google Assistant / Alexa)
- Motion/Temperature sensor toggles
- AI Learning (future upgrade)

---

### API Overview
Base URL: `http://localhost:3000`

- `GET /api/users/profile`
- `PUT /api/users/profile`
- `GET /api/rooms`
- `GET /api/rooms/:roomId`
- `GET /api/energy?start=<ISO>&end=<ISO>&deviceId=<id>`
- `POST /api/energy` body: `{ deviceId, watts, timestamp }`

Note: `/api/devices` is not implemented; the app falls back to local/device data where needed.

---

### Development Tips
- Use Hot Restart after tab count changes
- If backend is down, app uses local defaults (see console logs)
- Keep providers lightweight; offload heavy I/O to backend

---

---

### License
MIT. Use freely with attribution.