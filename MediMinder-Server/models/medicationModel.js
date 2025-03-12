const mongoose = require('mongoose');

const medicationSchema = new mongoose.Schema({
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true },
    name: { type: String, required: true },
    dose: { type: String, required: true },
    times: [{ type: String, required: true }], // שעות נטילה
    slotNumber: { type: Number, min: 1, max: 5 } // מספר התא בקופסה
}, { timestamps: true });

module.exports = mongoose.model('Medication', medicationSchema);
