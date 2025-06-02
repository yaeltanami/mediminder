const express = require('express');
const router = express.Router();
const { testLed , reportMedicationTaken, handleLateReminderAlert, registerOrUpdatePillBox} = require('../controllers/espController');router.post('/esp/register-pillbox', registerOrUpdatePillBox);

router.get('/test-led', testLed);
router.post('/report-taken', reportMedicationTaken); 
router.post('/reminder-alert', handleLateReminderAlert);
router.post('/register-pillbox', registerOrUpdatePillBox);


module.exports = router;
