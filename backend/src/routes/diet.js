import express from 'express';
import DietEntry from '../models/DietEntry.js';
import { authRequired } from '../middleware/auth.js';

const router = express.Router();

router.use(authRequired);

router.get('/', async (req, res) => {
  try {
    const { date } = req.query;
    if (!date) {
      return res.status(400).json({ error: 'date is required (YYYY-MM-DD)' });
    }
    const d = new Date(date + 'T00:00:00.000Z');

    const entries = await DietEntry.find({
      user: req.userId,
      date: d,
    }).sort({ createdAt: 1 });

    res.json(entries);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { date, text } = req.body;
    if (!date || !text) {
      return res.status(400).json({ error: 'date and text are required' });
    }
    const d = new Date(date + 'T00:00:00.000Z');

    const entry = await DietEntry.create({
      user: req.userId,
      date: d,
      text,
    });

    res.status(201).json(entry);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;

