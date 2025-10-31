import mongoose from 'mongoose';

const HomeSchema = new mongoose.Schema({
    id: { type: String, required: true },
    name: { type: String, required: true },
    address: { type: String, default: '—' },
}, { _id: false });

const SettingsSchema = new mongoose.Schema({
    themeMode: { type: Number, default: 0 },
    language: { type: Number, default: 2 },
    notificationsPower: { type: Boolean, default: true },
    notificationsAutomation: { type: Boolean, default: true },
    notificationsUpdates: { type: Boolean, default: true },
    accessibilityMode: { type: Boolean, default: false },
}, { _id: false });

const UserProfileSchema = new mongoose.Schema({
    userId: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    address: { type: String, default: '—' },
    preferredUnit: { type: String, enum: ['kWh', 'Rs'], default: 'kWh' },
    homes: { type: [HomeSchema], default: [] },
    settings: { type: SettingsSchema, default: () => ({}) },
}, { timestamps: true });

export default mongoose.model('UserProfile', UserProfileSchema);