const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patientController');

// רישום מטופל חדש
router.post('/register', patientController.registerPatient);

module.exports = router;
