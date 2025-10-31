# MongoDB Schema for Smart Home Control App

This document describes the MongoDB collection structure expected by the app for storing user profile data.

## User Profile Collection

**Collection Name:** `userprofiles` or `users`

### Schema Structure

```javascript
{
  "_id": ObjectId,                    // MongoDB auto-generated ID
  "userId": String,                   // User identifier (can be same as _id or separate)
  "name": String,                     // User's name
  "address": String,                  // User's address
  "preferredUnit": String,            // "kWh" or "Rs"
  "homes": [                          // Array of home profiles
    {
      "id": String,                   // Home identifier
      "name": String,                 // Home name
      "address": String               // Home address
    }
  ],
  "settings": {                       // User preferences
    "themeMode": Number,               // 0=system, 1=light, 2=dark
    "language": Number,               // 0=si, 1=ta, 2=en, 3=hi
    "notificationsPower": Boolean,
    "notificationsAutomation": Boolean,
    "notificationsUpdates": Boolean,
    "accessibilityMode": Boolean
  },
  "createdAt": Date,                  // Optional: creation timestamp
  "updatedAt": Date                   // Optional: last update timestamp
}
```

### Example Document

```javascript
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "userId": "u1",
  "name": "John Doe",
  "address": "123 Main Street, Colombo",
  "preferredUnit": "kWh",
  "homes": [
    {
      "id": "h1",
      "name": "My Home",
      "address": "123 Main Street, Colombo"
    },
    {
      "id": "h2",
      "name": "Vacation Home",
      "address": "456 Beach Road, Galle"
    }
  ],
  "settings": {
    "themeMode": 2,
    "language": 2,
    "notificationsPower": true,
    "notificationsAutomation": true,
    "notificationsUpdates": false,
    "accessibilityMode": false
  },
  "createdAt": ISODate("2024-01-01T00:00:00Z"),
  "updatedAt": ISODate("2024-01-15T12:30:00Z")
}
```

## Backend API Endpoints Required

### GET /api/users/profile
**Description:** Retrieve user profile from MongoDB

**Response Format:**
```json
{
  "profile": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "u1",
    "name": "John Doe",
    "address": "123 Main Street",
    "preferredUnit": "kWh",
    "homes": [...],
    "settings": {...}
  }
}
```

### PUT /api/users/profile
**Description:** Update user profile in MongoDB

**Request Body:**
```json
{
  "userId": "u1",
  "name": "John Doe",
  "address": "123 Main Street",
  "preferredUnit": "kWh",
  "homes": [
    {
      "id": "h1",
      "name": "My Home",
      "address": "123 Main Street"
    }
  ],
  "settings": {
    "themeMode": 2,
    "language": 2,
    "notificationsPower": true,
    "notificationsAutomation": true,
    "notificationsUpdates": false,
    "accessibilityMode": false
  }
}
```

**Response Format:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "profile": {
    "_id": "507f1f77bcf86cd799439011",
    ...
  }
}
```

## Backend Implementation Examples

### Node.js + Express + Mongoose

```javascript
const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  address: String,
  preferredUnit: { type: String, default: 'kWh' },
  homes: [{
    id: String,
    name: String,
    address: String
  }],
  settings: {
    themeMode: { type: Number, default: 0 },
    language: { type: Number, default: 2 },
    notificationsPower: { type: Boolean, default: true },
    notificationsAutomation: { type: Boolean, default: true },
    notificationsUpdates: { type: Boolean, default: true },
    accessibilityMode: { type: Boolean, default: false }
  }
}, {
  timestamps: true
});

const UserProfile = mongoose.model('UserProfile', userProfileSchema);

// GET /api/users/profile
app.get('/api/users/profile', async (req, res) => {
  try {
    const userId = req.user?.id || 'u1'; // Get from auth token
    const profile = await UserProfile.findOne({ userId });
    
    if (!profile) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    res.json({ profile });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PUT /api/users/profile
app.put('/api/users/profile', async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId || 'u1';
    const profile = await UserProfile.findOneAndUpdate(
      { userId },
      req.body,
      { new: true, upsert: true }
    );
    
    res.json({ 
      success: true, 
      message: 'Profile updated successfully',
      profile 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### Python + FastAPI + Motor (async MongoDB)

```python
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from typing import List, Optional

class HomeProfile(BaseModel):
    id: str
    name: str
    address: str

class UserSettings(BaseModel):
    themeMode: int = 0
    language: int = 2
    notificationsPower: bool = True
    notificationsAutomation: bool = True
    notificationsUpdates: bool = True
    accessibilityMode: bool = False

class UserProfile(BaseModel):
    userId: str
    name: str
    address: str
    preferredUnit: str = "kWh"
    homes: List[HomeProfile] = []
    settings: UserSettings = UserSettings()

# GET /api/users/profile
@app.get("/api/users/profile")
async def get_user_profile(current_user: dict = Depends(get_current_user)):
    db = app.state.db
    profile = await db.userprofiles.find_one({"userId": current_user["id"]})
    
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    profile["_id"] = str(profile["_id"])
    return {"profile": profile}

# PUT /api/users/profile
@app.put("/api/users/profile")
async def update_user_profile(
    profile_data: UserProfile,
    current_user: dict = Depends(get_current_user)
):
    db = app.state.db
    userId = current_user["id"] or profile_data.userId
    
    result = await db.userprofiles.update_one(
        {"userId": userId},
        {"$set": profile_data.dict()},
        upsert=True
    )
    
    updated_profile = await db.userprofiles.find_one({"userId": userId})
    updated_profile["_id"] = str(updated_profile["_id"])
    
    return {
        "success": True,
        "message": "Profile updated successfully",
        "profile": updated_profile
    }
```

## Indexes Recommended

```javascript
// Create indexes for better performance
db.userprofiles.createIndex({ "userId": 1 }, { unique: true });
db.userprofiles.createIndex({ "createdAt": 1 });
db.userprofiles.createIndex({ "updatedAt": 1 });
```

## Notes

1. **User Authentication:** The `userId` should be extracted from the authentication token (JWT) in production. For now, default to 'u1' for testing.

2. **Upsert Behavior:** The PUT endpoint should use upsert to create the profile if it doesn't exist.

3. **Data Validation:** Validate incoming data on the backend before saving to MongoDB.

4. **Error Handling:** Return appropriate HTTP status codes (404 for not found, 500 for server errors).

5. **Timestamps:** Consider adding `createdAt` and `updatedAt` timestamps automatically using MongoDB's timestamps feature.

6. **Backup:** The app also saves to local storage (SharedPreferences) as a fallback if MongoDB is unavailable.

