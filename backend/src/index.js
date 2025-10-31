import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import usersRouter from './routes/users.js';
import roomsRouter from './routes/rooms.js';
import energyRouter from './routes/energy.js';

dotenv.config();

const app = express();

// CORS configuration - allow Flutter app
app.use(cors({
    origin: '*', // Allow all origins for development
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use(morgan('dev'));

// MongoDB
const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/smarthome';

try {
    const connectionOptions = {
        serverSelectionTimeoutMS: 5000, // Timeout after 5s instead of 30s
    };

    await mongoose.connect(mongoUri, connectionOptions);
    console.log('✅ MongoDB connected successfully');
    console.log(`📊 Database: ${mongoose.connection.db.databaseName}`);
} catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    console.log('💡 Troubleshooting steps:');
    console.log('   1. Check if MongoDB Atlas cluster is running');
    console.log('   2. Verify your IP is whitelisted in MongoDB Atlas');
    console.log('   3. Check username/password in MONGODB_URI');
    console.log('   4. Ensure network access is enabled in Atlas');
    console.log(`   5. Connection string: ${mongoUri.replace(/\/\/[^:]+:[^@]+@/, '//***:***@')}`);
    process.exit(1);
}

app.get('/health', (req, res) => res.json({ ok: true }));
app.use('/api/users', usersRouter);
app.use('/api/rooms', roomsRouter);
app.use('/api/energy', energyRouter);

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`API listening on http://localhost:${port}`));