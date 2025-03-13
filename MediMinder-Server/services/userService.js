const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const registerUser = async (name, email, password, role) => {
    // בדיקה אם המשתמש כבר קיים
    const existingUser = await User.findOne({ email });
    if (existingUser) throw new Error('User already exists');

    // יצירת משתמש חדש
    const user = await User.create({ name, email, password, role });

    // יצירת טוקן
    const token = generateToken(user._id);
    
    return { user, token };
};

const loginUser = async (email, password) => {
    const user = await User.findOne({ email });
    if (!user) throw new Error('Invalid credentials');

    if (password !== user.password) throw new Error('Invalid credentials');

    // יצירת טוקן JWT
    const token = generateToken(user._id);

    return { user, token };
};


// פונקציה ליצירת טוקן JWT
const generateToken = (userId) => {
    return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

module.exports = { registerUser, loginUser };
