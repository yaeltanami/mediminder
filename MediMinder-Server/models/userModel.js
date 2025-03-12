const mongoose = require('mongoose');

// הגדרת סכמת המשתמש
const userSchema = new mongoose.Schema({
    name: { type: String, required: true },  // שם המשתמש (חובה)
    email: { type: String, required: true, unique: true }, // אימייל (ייחודי וחובה)
    password: { type: String, required: true }, // סיסמה (חובה)
    role: { type: String, enum: ['patient', 'caregiver'], required: true } // תפקיד (מטופל/מטפל)
}, { timestamps: true }); // הוספת תאריכים (createdAt, updatedAt)

// ייצוא המודל לשימוש בקובצי השרת
module.exports = mongoose.model('User', userSchema);
