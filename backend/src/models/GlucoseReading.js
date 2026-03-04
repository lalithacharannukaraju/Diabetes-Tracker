import mongoose from 'mongoose';

const glucoseReadingSchema = new mongoose.Schema(
    {
        user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
        value: { type: Number, required: true },
        readingType: {
            type: String,
            enum: ['fasting', 'post-meal', 'pre-meal', 'random'],
            default: 'random',
        },
        date: { type: Date, required: true },
        timeHour: { type: Number, required: true, min: 0, max: 23 },
        timeMinute: { type: Number, required: true, min: 0, max: 59 },
        notes: { type: String, default: '' },
    },
    { timestamps: true }
);

glucoseReadingSchema.index({ user: 1, date: 1 });

const GlucoseReading = mongoose.model('GlucoseReading', glucoseReadingSchema);

export default GlucoseReading;
