const mongoose = require('mongoose');

const medicationSchema = new mongoose.Schema({
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true },
    name: { type: String, required: true },
    dose: { type: String, required: true },
    times: [{ type: String, required: true }], // למשל: ["08:00", "14:00"]
}, { timestamps: true });

module.exports = mongoose.model('Medication', medicationSchema);
