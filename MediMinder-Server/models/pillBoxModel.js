const mongoose = require('mongoose');

const pillBoxSchema = new mongoose.Schema({
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true }, // המטופל שהקופסה שייכת לו
    slots: [
        {
            slotNumber: { type: Number, required: true }, // מספר התא (1-5)
            medication: { type: mongoose.Schema.Types.ObjectId, ref: 'Medication', default: null }, // התרופה בתא (אם קיימת)
            status: { type: String, enum: ['empty', 'filled'], default: 'empty' } // מצב התא
        }
    ]
}, { timestamps: true });

module.exports = mongoose.model('PillBox', pillBoxSchema);
