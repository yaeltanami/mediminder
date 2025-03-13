const express = require('express');
const router = express.Router();
const caregiverController = require('../controllers/caregiverController');

// רישום מטפל חדש
router.post('/register', caregiverController.registerCaregiver);

module.exports = router;
