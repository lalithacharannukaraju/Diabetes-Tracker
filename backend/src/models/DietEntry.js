import mongoose from 'mongoose';

const dietEntrySchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    date: { type: Date, required: true },
    text: { type: String, required: true },
    timeHour: { type: Number, min: 0, max: 23, default: 0 },
    timeMinute: { type: Number, min: 0, max: 59, default: 0 },
  },
  { timestamps: true }
);

dietEntrySchema.index({ user: 1, date: 1 });

const DietEntry = mongoose.model('DietEntry', dietEntrySchema);

export default DietEntry;

