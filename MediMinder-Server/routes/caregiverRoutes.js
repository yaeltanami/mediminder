const express = require('express');
const { createCaregiver, getCaregivers } = require('../controllers/caregiverController');

const router = express.Router();
router.post('/create', createCaregiver);
router.get('/', getCaregivers);

module.exports = router;
