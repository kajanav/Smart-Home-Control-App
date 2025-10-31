import mongoose from 'mongoose';

const DeviceStateSchema = new mongoose.Schema({
    isOn: { type: Boolean, default: false },
    brightness: Number,
    fanSpeed: Number,
    temperature: Number,
    mode: String,
}, { _id: false });

const DeviceSchema = new mongoose.Schema({
    id: { type: String, required: true },
    name: { type: String, required: true },
    type: { type: String, required: true },
    roomId: { type: String, required: true },
    isOnline: { type: Boolean, default: false },
    state: { type: DeviceStateSchema, default: () => ({}) },
    currentLoad: Number,
    lastUpdate: Date,
    properties: mongoose.Schema.Types.Mixed,
}, { _id: false });

const RoomSchema = new mongoose.Schema({
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    description: { type: String, default: '' },
    type: { type: String, required: true },
    devices: { type: [DeviceSchema], default: [] },
    imageUrl: String,
    isFavorite: { type: Boolean, default: false },
}, { timestamps: true });

export default mongoose.model('Room', RoomSchema);