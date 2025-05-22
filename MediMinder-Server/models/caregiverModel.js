const mongoose = require('mongoose');

const caregiverSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    patients: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Patient' }],
    experienceYears: { type: Number }
}, { timestamps: true });

module.exports = mongoose.model('Caregiver', caregiverSchema);
