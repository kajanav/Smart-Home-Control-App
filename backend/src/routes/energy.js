import { Router } from 'express';
import EnergySample from '../models/Energy.js';

const router = Router();

// POST /api/energy - Create energy sample
router.post('/', async(req, res) => {
    try {
        const { deviceId, watts, timestamp } = req.body;

        if (!deviceId || watts === undefined || !timestamp) {
            return res.status(400).json({
                error: 'Missing required fields: deviceId, watts, timestamp'
            });
        }

        const sample = new EnergySample({
            deviceId,
            watts: parseFloat(watts),
            timestamp: new Date(timestamp),
        });

        await sample.save();
        res.status(201).json({ success: true, sample });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// GET /api/energy - Get energy data with optional filters
router.get('/', async(req, res) => {
    try {
        const { start, end, deviceId } = req.query;
        const query = {};

        if (deviceId) {
            query.deviceId = deviceId;
        }

        if (start || end) {
            query.timestamp = {};
            if (start) {
                query.timestamp.$gte = new Date(start);
            }
            if (end) {
                query.timestamp.$lte = new Date(end);
            }
        }

        const samples = await EnergySample.find(query)
            .sort({ timestamp: -1 })
            .limit(1000); // Limit to prevent huge responses

        res.json({ samples });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

export default router;