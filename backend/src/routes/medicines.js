import express from 'express';
import Medicine from '../models/Medicine.js';
import TakenMedicine from '../models/TakenMedicine.js';
import { authRequired } from '../middleware/auth.js';

const router = express.Router();

router.use(authRequired);

router.get('/', async (req, res) => {
  try {
    const meds = await Medicine.find({ user: req.userId }).sort({ createdAt: 1 });
    res.json(meds);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { name, dosage, timeHour, timeMinute, weekdays, importance } = req.body;
    if (!name || !dosage || timeHour === undefined || timeMinute === undefined || !Array.isArray(weekdays)) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    const med = await Medicine.create({
      user: req.userId,
      name,
      dosage,
      timeHour,
      timeMinute,
      weekdays,
      importance: importance || 'medium',
    });
    res.status(201).json(med);
  } catch (err) {
    console.error(err);
    if (err.name === 'ValidationError') {
      return res.status(400).json({ error: err.message });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const update = req.body;
    const med = await Medicine.findOneAndUpdate({ _id: id, user: req.userId }, update, {
      new: true,
      runValidators: true,
    });
    if (!med) {
      return res.status(404).json({ error: 'Medicine not found' });
    }
    res.json(med);
  } catch (err) {
    console.error(err);
    if (err.name === 'ValidationError') {
      return res.status(400).json({ error: err.message });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const med = await Medicine.findOneAndDelete({ _id: id, user: req.userId });
    if (!med) {
      return res.status(404).json({ error: 'Medicine not found' });
    }
    await TakenMedicine.deleteMany({ user: req.userId, medicine: id });
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/:id/toggle-taken', async (req, res) => {
  try {
    const { id } = req.params;
    const { date } = req.body;
    if (!date) {
      return res.status(400).json({ error: 'date is required (YYYY-MM-DD)' });
    }
    const d = new Date(date + 'T00:00:00.000Z');

    const med = await Medicine.findOne({ _id: id, user: req.userId });
    if (!med) {
      return res.status(404).json({ error: 'Medicine not found' });
    }

    const existing = await TakenMedicine.findOne({ user: req.userId, medicine: id, date: d });
    if (existing) {
      await existing.deleteOne();
      return res.json({ taken: false });
    } else {
      await TakenMedicine.create({ user: req.userId, medicine: id, date: d });
      return res.json({ taken: true });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/status', async (req, res) => {
  try {
    const { date } = req.query;
    if (!date) {
      return res.status(400).json({ error: 'date is required (YYYY-MM-DD)' });
    }
    const d = new Date(date + 'T00:00:00.000Z');
    const taken = await TakenMedicine.find({ user: req.userId, date: d }).select('medicine');
    res.json({ takenMedicineIds: taken.map((t) => t.medicine.toString()) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;

