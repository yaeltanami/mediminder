const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// רישום משתמש חדש
router.post('/register', userController.registerUser);

// התחברות משתמש
router.post('/login', userController.loginUser);

// מחיקת משתמש
router.delete('/delete/:userId', userController.deleteUser);


module.exports = router;
