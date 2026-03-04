import express from 'express';
import GlucoseReading from '../models/GlucoseReading.js';
import { authRequired } from '../middleware/auth.js';

const router = express.Router();

router.use(authRequired);

// GET /api/glucose?date=YYYY-MM-DD
router.get('/', async (req, res) => {
    try {
        const { date } = req.query;
        if (!date) {
            return res.status(400).json({ error: 'date is required (YYYY-MM-DD)' });
        }
        const d = new Date(date + 'T00:00:00.000Z');

        const readings = await GlucoseReading.find({
            user: req.userId,
            date: d,
        }).sort({ timeHour: 1, timeMinute: 1 });

        res.json(readings);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// POST /api/glucose
router.post('/', async (req, res) => {
    try {
        const { date, value, readingType, timeHour, timeMinute, notes } = req.body;
        if (!date || value === undefined || timeHour === undefined || timeMinute === undefined) {
            return res.status(400).json({ error: 'date, value, timeHour and timeMinute are required' });
        }
        const d = new Date(date + 'T00:00:00.000Z');

        const reading = await GlucoseReading.create({
            user: req.userId,
            value,
            readingType: readingType || 'random',
            date: d,
            timeHour,
            timeMinute,
            notes: notes || '',
        });

        res.status(201).json(reading);
    } catch (err) {
        console.error(err);
        if (err.name === 'ValidationError') {
            return res.status(400).json({ error: err.message });
        }
        res.status(500).json({ error: 'Internal server error' });
    }
});

// DELETE /api/glucose/:id
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const reading = await GlucoseReading.findOneAndDelete({ _id: id, user: req.userId });
        if (!reading) {
            return res.status(404).json({ error: 'Reading not found' });
        }
        res.json({ success: true });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

export default router;
