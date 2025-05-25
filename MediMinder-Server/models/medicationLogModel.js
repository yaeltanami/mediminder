const mongoose = require('mongoose');

const medicationLogSchema = new mongoose.Schema({
  medicationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Medication', required: true },
  patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true },
  time: { type: String, required: true }, // פורמט HH:mm
  date: { type: String, required: true }, // פורמט YYYY-MM-DD
}, { timestamps: true });

module.exports = mongoose.model('MedicationLog', medicationLogSchema);
