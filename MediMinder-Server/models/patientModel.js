const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    birthDate: { type: Date, required: true },
    caregivers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Caregiver' }],
    medications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Medication' }],
    pillBox: { type: mongoose.Schema.Types.ObjectId, ref: 'PillBox', default: null } // הוספת שדה לקופסה החכמה
}, { timestamps: true });

module.exports = mongoose.model('Patient', patientSchema);
