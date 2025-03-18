const userService = require('../services/userService');

/**
 * בקר לרישום משתמש חדש
 */
const registerUser = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;

        // בדיקת תקינות הנתונים
        if (!name || !email || !password || !role) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const { user, token } = await userService.registerUser(name, email, password, role);
        res.status(201).json({ user, token });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

/**
 * בקר להתחברות משתמש
 */
const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        // בדיקת תקינות הנתונים
        if (!email || !password) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const { user, token } = await userService.loginUser(email, password);
        res.status(200).json({ user, token });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

/**
 * בקר למחיקת משתמש
 */
const deleteUser = async (req, res) => {
    try {
        const { userId } = req.params;
        const response = await userService.deleteUser(userId);
        res.status(200).json(response);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};
module.exports = { registerUser, loginUser, deleteUser };
