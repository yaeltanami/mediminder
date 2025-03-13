const jwt = require('jsonwebtoken'); 
const User = require('../models/userModel');
const bcrypt = require('bcryptjs');

/**
 * רישום משתמש חדש למערכת
 */
const registerUser = async ({ name, email, password, role }) => {
    const existingUser = await User.findOne({ email });
    if (existingUser) throw new Error('User already exists');

    // ודא שכל הנתונים מועברים בצורה תקינה
    if (!name || !email || !password || !role) {
        throw new Error('All user fields are required.');
    }

    const user = new User({ name, email, password, role });

    // שמירה במסד הנתונים
    await user.save();

    // הפיכת המשתמש לאובייקט רגיל והסרת הסיסמה
    const sanitizedUser = user.toObject();
    delete sanitizedUser.password;

    return sanitizedUser;
};


/**
 * התחברות משתמש למערכת
 */
const loginUser = async (email, password) => {
    const user = await User.findOne({ email });
    if (!user) throw new Error('Invalid credentials');

    // השוואת הסיסמה באמצעות `bcrypt`
    const isMatch = await user.matchPassword(password);
    if (!isMatch) throw new Error('Invalid credentials');

    // יצירת טוקן JWT
    const token = generateToken(user._id, user.role);

 // הסרת הסיסמה מהאובייקט שנשלח ללקוח
    const sanitizedUser = user.toObject();
    delete sanitizedUser.password;

    return { user: sanitizedUser, token };};

/**
 * פונקציה ליצירת טוקן JWT
 */
const generateToken = (userId, role) => {
    return jwt.sign({ userId, role }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

module.exports = { registerUser, loginUser, generateToken };
