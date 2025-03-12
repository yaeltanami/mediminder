const mongoose = require('mongoose');

const pillBoxSchema = new mongoose.Schema({
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true }, // למי שייכת הקופסה
    slots: [
        {
            slotNumber: { type: Number, required: true }, // מספר התא (1-5)
            medication: { type: mongoose.Schema.Types.ObjectId, ref: 'Medication', default: null }, // תרופה בתא
            status: { type: String, enum: ['empty', 'filled'], default: 'empty' } // מצב התא
        }
    ]
}, { timestamps: true });

module.exports = mongoose.model('PillBox', pillBoxSchema);
