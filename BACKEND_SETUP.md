# Backend Setup Guide

This document explains how to set up and integrate the backend services for the Smart Home Control app.

## Overview

The app integrates with backend services through:
1. **REST API** - For device control, data fetching, and user management
2. **MQTT Broker** - For real-time IoT device communication
3. **WebSocket** (optional) - For additional real-time updates

## Backend API Endpoints

The backend should implement the following REST API endpoints:

### Devices
- `GET /api/devices` - Get all devices
- `GET /api/devices/:deviceId` - Get device by ID
- `PUT /api/devices/:deviceId/control` - Send control command to device
- `POST /api/devices` - Create new device (optional)

### Rooms
- `GET /api/rooms` - Get all rooms with devices
- `GET /api/rooms/:roomId` - Get room by ID
- `POST /api/rooms` - Create room (optional)
- `PUT /api/rooms/:roomId` - Update room (optional)

### Energy
- `GET /api/energy` - Get energy data with optional query params:
  - `start` - ISO8601 timestamp
  - `end` - ISO8601 timestamp
  - `deviceId` - Filter by device
- `POST /api/energy` - Post energy sample
  ```json
  {
    "deviceId": "string",
    "watts": 100.5,
    "timestamp": "2024-01-01T12:00:00Z"
  }
  ```

### Users/Auth
- `POST /api/users/login` - User login
- `POST /api/users/register` - User registration
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile

### Automations
- `GET /api/automations` - Get all automations
- `POST /api/automations` - Create automation
- `PUT /api/automations/:id` - Update automation
- `DELETE /api/automations/:id` - Delete automation

## MQTT Topics

The MQTT broker should use the following topic structure:

### Device Control
- **Subscribe**: `devices/{deviceId}/status` - Receive device status updates
- **Publish**: `devices/{deviceId}/command` - Send commands to device
  ```json
  {
    "isOn": true,
    "brightness": 75,
    "fanSpeed": 3,
    "temperature": 24
  }
  ```

### Energy Data
- **Subscribe**: `energy/{deviceId}` - Receive real-time energy readings
- **Publish**: `energy/{deviceId}` - Send energy data (optional)

### Wildcard Subscriptions
- `devices/+/status` - Subscribe to all device status updates

## Configuration

### Environment Variables

Create a `.env` file or set environment variables:

```env
# API Configuration
API_BASE_URL=http://localhost:3000/api

# MQTT Configuration
MQTT_BROKER=localhost
MQTT_PORT=1883
MQTT_CLIENT_ID=smart_home_app

# Optional: Authentication
AUTH_TOKEN=your_jwt_token_here
```

### Flutter Configuration

The app reads configuration from `lib/services/api_config.dart`. You can:

1. **Use compile-time variables:**
   ```bash
   flutter run --dart-define=API_BASE_URL=http://your-backend.com/api
   ```

2. **Modify `api_config.dart` directly** for development

3. **Use environment-specific config files** (create separate config files per environment)

## Backend Implementation Options

### Option 1: Node.js + Express

Example server structure:
```javascript
// server.js
const express = require('express');
const app = express();

app.get('/api/devices', async (req, res) => {
  // Fetch devices from database
  res.json({ devices: [...] });
});

app.put('/api/devices/:id/control', async (req, res) => {
  // Update device state
  // Optionally publish to MQTT
  res.json({ device: {...} });
});
```

### Option 2: Python Flask/FastAPI

Example with FastAPI:
```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/api/devices")
async def get_devices():
    # Fetch from database
    return {"devices": [...]}

@app.put("/api/devices/{device_id}/control")
async def control_device(device_id: str, command: dict):
    # Update device
    return {"device": {...}}
```

### Option 3: Firebase

Firebase provides:
- Realtime Database / Firestore for data
- Cloud Functions for API endpoints
- Authentication
- Cloud Messaging for notifications

## MQTT Broker Setup

### Using Mosquitto (MQTT Broker)

1. Install Mosquitto:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install mosquitto mosquitto-clients
   
   # macOS
   brew install mosquitto
   ```

2. Start Mosquitto:
   ```bash
   mosquitto -c /etc/mosquitto/mosquitto.conf -v
   ```

3. Test connection:
   ```bash
   # Subscribe
   mosquitto_sub -h localhost -t "devices/+/status"
   
   # Publish
   mosquitto_pub -h localhost -t "devices/d1/status" -m '{"isOn": true}'
   ```

### Using Cloud MQTT Services

- **HiveMQ Cloud** - Free tier available
- **AWS IoT Core** - Enterprise solution
- **CloudMQTT** - Managed MQTT broker

## Testing the Integration

1. **Start your backend server**
2. **Start MQTT broker**
3. **Run the Flutter app:**
   ```bash
   flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
   ```

4. **Check logs:**
   - Backend should show incoming requests
   - MQTT broker should show subscriptions
   - App should connect and sync data

## Offline Mode

The app includes fallback mechanisms:
- Rooms load default data if API fails
- Energy samples are stored locally before sync
- Device state is cached locally

## Security Considerations

1. **Authentication**: Implement JWT token-based auth
2. **HTTPS/WSS**: Use secure connections in production
3. **MQTT Security**: Enable TLS/SSL for MQTT
4. **API Rate Limiting**: Prevent abuse
5. **Input Validation**: Validate all API inputs
6. **Device Authorization**: Ensure users can only control their devices

## Next Steps

1. Implement your backend server (Node.js/Python/Firebase)
2. Set up MQTT broker
3. Configure environment variables
4. Test API endpoints using Postman or curl
5. Test MQTT communication
6. Update app configuration
7. Deploy backend and MQTT broker
8. Update app with production URLs

## Example Backend Response Formats

### GET /api/devices
```json
{
  "devices": [
    {
      "id": "d1",
      "name": "Main Light",
      "type": "light",
      "roomId": "1",
      "isOnline": true,
      "state": {
        "isOn": false,
        "brightness": 100
      },
      "currentLoad": 50.5
    }
  ]
}
```

### GET /api/rooms
```json
{
  "rooms": [
    {
      "id": "1",
      "name": "Living Room",
      "type": "livingRoom",
      "devices": [...]
    }
  ]
}
```

## Troubleshooting

**App can't connect to API:**
- Check API_BASE_URL configuration
- Verify backend server is running
- Check firewall/network settings
- Look for CORS issues (backend needs CORS headers)

**MQTT connection fails:**
- Verify MQTT broker is running
- Check MQTT_BROKER and MQTT_PORT values
- Test with MQTT client (mosquitto_pub/sub)
- Check broker authentication requirements

**Data not syncing:**
- Check backend logs for errors
- Verify API endpoint URLs match
- Ensure proper authentication tokens
- Check network connectivity

