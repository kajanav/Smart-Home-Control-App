import dotenv from 'dotenv';
import mongoose from 'mongoose';
import UserProfile from './models/UserProfile.js';

dotenv.config();

const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/smarthome';

async function main() {
    await mongoose.connect(mongoUri);
    console.log('Mongo connected');

    const profile = await UserProfile.findOneAndUpdate({ userId: 'u1' }, {
        userId: 'u1',
        name: 'Guest User',
        address: '—',
        preferredUnit: 'kWh',
        homes: [{ id: 'h1', name: 'My Home', address: '—' }],
        settings: { themeMode: 0, language: 2 },
    }, { upsert: true, new: true });

    console.log('Seeded profile:', profile.userId);
    await mongoose.disconnect();
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});