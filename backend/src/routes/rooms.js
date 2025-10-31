import { Router } from 'express';
import Room from '../models/Room.js';

const router = Router();

// GET /api/rooms - Get all rooms
router.get('/', async(req, res) => {
    try {
        let rooms = await Room.find({});

        // If no rooms in DB, return default rooms structure
        if (rooms.length === 0) {
            // Return empty array, frontend will use defaults
            // OR we can return default rooms here
            rooms = [];
        }

        res.json({ rooms });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET /api/rooms/:roomId - Get room by ID
router.get('/:roomId', async(req, res) => {
    try {
        const room = await Room.findOne({ id: req.params.roomId });
        if (!room) {
            return res.status(404).json({ error: 'Room not found' });
        }
        res.json({ room });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;