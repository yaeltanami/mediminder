const userService = require('../services/userService');
const jwt = require('jsonwebtoken');


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

/**
 * אחרי ההתחברות fcmToken  שמירת 
 * userId = user._id
 */
const saveFcmToken = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ message: 'Missing auth token' });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const userId = decoded.userId;

        const { fcmToken } = req.body;

        await userService.saveFcmToken(userId, fcmToken);

        res.status(200).json({ message: 'FCM token saved successfully' });
    } catch (error) {
        console.error('❌ Error saving FCM token:', error);
        res.status(500).json({ message: error.message || 'Internal server error' });
    }
};


/**
 * logout אחרי  fcmToken  מחיקת
 * userId = user._id
 */
const removeFcmToken = async (req, res) => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return res.status(401).json({ message: 'Missing auth token' });
      }
  
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const userId = decoded.userId;
  
      await userService.removeFcmToken(userId); 
  
      res.status(200).json({ message: 'FCM token removed' });
    } catch (error) {
      console.error('❌ Error removing FCM token:', error);
      res.status(500).json({ message: error.message || 'Server error' });
    }
  };
  
module.exports = { registerUser, loginUser, deleteUser, saveFcmToken, removeFcmToken };
