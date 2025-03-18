const express = require('express');
const router = express.Router();
const caregiverController = require('../controllers/caregiverController');

// רישום מטפל חדש
router.post('/register', caregiverController.registerCaregiver);
// הוספת מטופל למטפל
router.post('/add-patient', caregiverController.addPatientToCaregiver);
// הסרת מטופל ממטפל
router.post('/remove-patient', caregiverController.removePatientFromCaregiver);
// החזרת כל מטופליו של מטפל מסוים
router.get('/patients/:caregiverId', caregiverController.getPatientsForCaregiver);


module.exports = router;
