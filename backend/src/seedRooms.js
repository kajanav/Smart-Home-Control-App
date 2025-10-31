import dotenv from 'dotenv';
import mongoose from 'mongoose';
import Room from './models/Room.js';

dotenv.config();

const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/smarthome';

const defaultRooms = [{
        id: '1',
        name: 'Living Room',
        description: 'Main living space',
        type: 'livingRoom',
        isFavorite: false,
        devices: [{
                id: 'd1',
                name: 'Main Light',
                type: 'light',
                roomId: '1',
                isOnline: true,
                state: { isOn: false, brightness: 100 },
                currentLoad: 50.5,
            },
            {
                id: 'd2',
                name: 'Ceiling Fan',
                type: 'fan',
                roomId: '1',
                isOnline: true,
                state: { isOn: false, fanSpeed: 3 },
                currentLoad: 60.0,
            },
            {
                id: 'd3',
                name: 'Smart TV',
                type: 'tv',
                roomId: '1',
                isOnline: true,
                state: { isOn: false },
                currentLoad: 120.0,
            },
            {
                id: 'd4',
                name: 'Air Conditioner',
                type: 'airConditioner',
                roomId: '1',
                isOnline: true,
                state: { isOn: false, temperature: 26, mode: 'cool' },
                currentLoad: 900.0,
            },
        ],
    },
    {
        id: '2',
        name: 'Bedroom 1',
        description: 'Master bedroom',
        type: 'bedroom1',
        isFavorite: false,
        devices: [{
                id: 'd5',
                name: 'Bedside Lamp',
                type: 'light',
                roomId: '2',
                isOnline: true,
                state: { isOn: false, brightness: 50 },
                currentLoad: 25.0,
            },
            {
                id: 'd6',
                name: 'Ceiling Fan',
                type: 'fan',
                roomId: '2',
                isOnline: true,
                state: { isOn: false, fanSpeed: 2 },
                currentLoad: 40.0,
            },
            {
                id: 'd7',
                name: 'TV',
                type: 'tv',
                roomId: '2',
                isOnline: true,
                state: { isOn: false },
                currentLoad: 120.0,
            },
            {
                id: 'd8',
                name: 'AC',
                type: 'airConditioner',
                roomId: '2',
                isOnline: true,
                state: { isOn: true, temperature: 24, mode: 'cool' },
                currentLoad: 900.0,
            },
        ],
    },
];

async function seedRooms() {
    try {
        await mongoose.connect(mongoUri);
        console.log('✅ Connected to MongoDB');

        // Clear existing rooms (optional)
        await Room.deleteMany({});

        // Insert default rooms
        for (const roomData of defaultRooms) {
            const room = await Room.findOneAndUpdate({ id: roomData.id },
                roomData, { upsert: true, new: true }
            );
            console.log(`✅ Seeded room: ${room.name} (${room.id})`);
        }

        console.log('✅ All rooms seeded successfully');
        await mongoose.disconnect();
    } catch (error) {
        console.error('❌ Error seeding rooms:', error);
        process.exit(1);
    }
}

seedRooms();