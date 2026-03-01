import dotenv from 'dotenv';
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import morgan from 'morgan';

import authRoutes from './routes/auth.js';
import medicineRoutes from './routes/medicines.js';
import dietRoutes from './routes/diet.js';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Diabetes Tracker API' });
});

app.use('/api/auth', authRoutes);
app.use('/api/medicines', medicineRoutes);
app.use('/api/diet', dietRoutes);

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/diabetes_tracker';

let isConnected = false;

export async function ensureDbConnected() {
  if (isConnected) return;
  await mongoose.connect(MONGODB_URI);
  isConnected = true;
  console.log('Connected to MongoDB');
}

export default app;

