const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patientController');

// רישום מטופל חדש
router.post('/register', patientController.registerPatient);
// קבלת כל המטפלים של מטופל מסוים
router.get('/caregivers/:patientId', patientController.getCaregiversForPatient);
router.get('/by-user/:userId', patientController.getPatientByUserId);
router.get('/by-email', patientController.getPatientByEmail);
router.get('/:patientId/user', patientController.getUserByPatientId);

module.exports = router;
