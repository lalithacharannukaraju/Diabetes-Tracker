import mongoose from 'mongoose';

const medicineSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    name: { type: String, required: true },
    dosage: { type: String, required: true },
    timeHour: { type: Number, required: true, min: 0, max: 23 },
    timeMinute: { type: Number, required: true, min: 0, max: 59 },
    weekdays: {
      type: [Number],
      validate: {
        validator: (arr) => arr.every((d) => d >= 1 && d <= 7),
        message: 'Weekdays must be integers between 1 and 7',
      },
      required: true,
    },
    importance: {
      type: String,
      enum: ['low', 'medium', 'high'],
      default: 'medium',
    },
  },
  { timestamps: true }
);

const Medicine = mongoose.model('Medicine', medicineSchema);

export default Medicine;

