# MongoDB Setup Guide

## Why the Connection Error?
The error `ECONNREFUSED 127.0.0.1:27017` means MongoDB is not running on your local machine at port 27017.

## Solution 1: Use MongoDB Atlas (Cloud - Easiest) ⭐

### Steps:
1. **Sign up for free**: Go to https://www.mongodb.com/cloud/atlas/register
2. **Create a free cluster** (M0 - Free tier)
3. **Get connection string**:
   - Click "Connect" → "Connect your application"
   - Copy the connection string (looks like: `mongodb+srv://username:password@cluster.mongodb.net/`)
4. **Update your .env file**:
   ```env
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/smarthome?retryWrites=true&w=majority
   ```
   Replace `username` and `password` with your Atlas credentials.

### Advantages:
- ✅ No installation needed
- ✅ Works immediately
- ✅ Free tier available
- ✅ Accessible from anywhere

---

## Solution 2: Install MongoDB Locally

### Windows:
1. **Download MongoDB**: https://www.mongodb.com/try/download/community
2. **Install** (default settings work)
3. **Start MongoDB Service**:
   - Open Services (Win+R → `services.msc`)
   - Find "MongoDB" service
   - Right-click → Start
4. **Verify it's running**:
   ```bash
   mongod --version
   ```

### macOS:
```bash
# Using Homebrew
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

### Linux (Ubuntu):
```bash
# Install
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start
sudo systemctl start mongod
sudo systemctl enable mongod
```

### Verify Connection:
```bash
mongosh
# Should connect to: mongodb://localhost:27017
```

---

## Update Your Backend Code (Optional - Better Error Handling)

The current code will fail if MongoDB isn't connected. Here's an improved version:

```javascript
// In src/index.js, replace the MongoDB connection section:

const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/smarthome';

try {
  await mongoose.connect(mongoUri);
  console.log('✅ MongoDB connected successfully');
} catch (error) {
  console.error('❌ MongoDB connection error:', error.message);
  console.log('💡 Make sure MongoDB is running or update MONGODB_URI in .env');
  process.exit(1);
}
```

---

## Quick Test After Setup

1. **Update .env** with your MongoDB URI
2. **Restart the server**:
   ```bash
   cd backend
   npm run dev
   ```
3. **Should see**: `✅ MongoDB connected successfully`

---

## Troubleshooting

### Still getting connection errors?

1. **Check if MongoDB is running**:
   ```bash
   # Windows: Check Services
   # macOS/Linux:
   ps aux | grep mongod
   ```

2. **Check connection string format**:
   - Local: `mongodb://localhost:27017/smarthome`
   - Atlas: `mongodb+srv://user:pass@cluster.mongodb.net/smarthome`

3. **Firewall issues**:
   - Make sure port 27017 is open (for local)
   - For Atlas, whitelist IP: 0.0.0.0/0 (Network Access tab)

4. **Test connection manually**:
   ```bash
   mongosh "your-connection-string"
   ```

