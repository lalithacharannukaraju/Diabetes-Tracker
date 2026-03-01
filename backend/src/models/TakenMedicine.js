import mongoose from 'mongoose';

const takenMedicineSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    medicine: { type: mongoose.Schema.Types.ObjectId, ref: 'Medicine', required: true },
    date: { type: Date, required: true },
  },
  { timestamps: true }
);

takenMedicineSchema.index({ user: 1, medicine: 1, date: 1 }, { unique: true });

const TakenMedicine = mongoose.model('TakenMedicine', takenMedicineSchema);

export default TakenMedicine;

