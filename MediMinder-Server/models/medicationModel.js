const mongoose = require('mongoose');


const medicationSchema = new mongoose.Schema({
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: 'Patient', required: true }, // מזהה המטופל אליו התרופה שייכת
    name: { type: String, required: true }, // שם התרופה
    dose: { type: String, required: true }, // מינון התרופה
    times: [{ type: String, required: true }], // שעות נטילה
    days: [{ type: String, required: true }], // ימי נטילה
        // מערך של שעות נטילה עם מספר כדורים לכל שעה
    times: [{ 
            time: { type: String, required: true }, // שעת הנטילה
            pillsCount: { type: Number, required: true, min: 1 } // מספר כדורים בשעה זו
        }],
    days: [{ type: String, enum: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'] }], // ימים שבהם יש לקחת את התרופה
    slotNumber: { type: Number, min: 1, max: 5 } // מספר התא בקופסה (אם מוקצה)
}, { timestamps: true });

module.exports = mongoose.model('Medication', medicationSchema);
