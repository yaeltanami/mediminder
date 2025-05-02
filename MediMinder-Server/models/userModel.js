const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

/**
 * סכמת המשתמשים במערכת
 */
const userSchema = new mongoose.Schema({
    name: { type: String, required: true },  // שם המשתמש (חובה)
    email: { type: String, required: true, unique: true }, // אימייל (ייחודי וחובה)
    password: { type: String, required: true }, // סיסמה (חובה)
    role: { type: String, enum: ['patient', 'caregiver'], required: true },// תפקיד (מטופל/מטפל)
    fcmToken: { type: String }

}, { timestamps: true });

/**
 * 🔹 Middleware של Mongoose - רץ **לפני** שמירת המשתמש (`save()`).
 * 🔹 אם הסיסמה שונתה, היא תוצפן **לפני** שתשמר במסד הנתונים.
 */
userSchema.pre('save', async function (next) {
    // אם הסיסמה לא השתנתה, ממשיכים בלי הצפנה
    if (!this.isModified('password')) return next();

    // יצירת salt (ערך אקראי) ברמת אבטחה של 10 סיבובים
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);

    // המשך שמירת המשתמש במסד הנתונים
    next();
});

/**
 * השוואת סיסמה שהוזנה עם הסיסמה המוצפנת במסד הנתונים
 * @param {string} enteredPassword - הסיסמה שהמשתמש הזין
 * @returns {Promise<boolean>} - מחזיר true אם הסיסמה נכונה, אחרת false
 */
userSchema.methods.matchPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
