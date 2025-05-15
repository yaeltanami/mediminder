const express = require('express');
const router = express.Router();
const { testLed , reportMedicationTaken} = require('../controllers/espController');

router.get('/test-led', testLed);
router.post('/report-taken', reportMedicationTaken); 

module.exports = router;
