import mongoose from 'mongoose';

const EnergySampleSchema = new mongoose.Schema({
    deviceId: { type: String, required: true, index: true },
    timestamp: { type: Date, required: true, index: true },
    watts: { type: Number, required: true },
}, { timestamps: true });

export default mongoose.model('EnergySample', EnergySampleSchema);