const mongoose = require('mongoose');


const medicationSchema = new mongoose.Schema({
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true }, // מזהה המטופל אליו התרופה שייכת
    name: { type: String, required: true }, // שם התרופה
    dose: { type: String, required: true }, // מינון התרופה
    times: [{ type: String, required: true }], // שעות נטילה
    slotNumber: { type: Number, min: 1, max: 5 } // מספר התא בקופסה (אם מוקצה)
}, { timestamps: true });

module.exports = mongoose.model('Medication', medicationSchema);
