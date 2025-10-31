import { Router } from 'express';
import UserProfile from '../models/UserProfile.js';

const router = Router();

// For demo: use fixed userId 'u1'. In production use auth middleware
const getUserId = (req) => (req.user && req.user.id) || req.query.userId || 'u1';

// GET /api/users/profile
router.get('/profile', async(req, res) => {
    try {
        const userId = getUserId(req);
        let profile = await UserProfile.findOne({ userId });

        // If no profile exists, return a default one
        if (!profile) {
            profile = {
                userId: userId,
                name: 'Guest User',
                address: '—',
                preferredUnit: 'kWh',
                homes: [{ id: 'h1', name: 'My Home', address: '—' }],
            };
        } else {
            // Convert Mongoose document to plain object
            profile = profile.toObject ? profile.toObject() : profile;
        }

        res.json({ profile });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// PUT /api/users/profile
router.put('/profile', async(req, res) => {
    try {
        const userId = getUserId(req) || req.body.userId;
        if (!userId) return res.status(400).json({ error: 'userId is required' });

        const payload = {...req.body, userId };
        const profile = await UserProfile.findOneAndUpdate({ userId }, { $set: payload }, { upsert: true, new: true });
        res.json({ success: true, profile });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

export default router;