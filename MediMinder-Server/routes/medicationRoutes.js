const express = require('express');
const { addMedication, getMedicationsForPatient } = require('../controllers/medicationController');

const router = express.Router();
router.post('/add', addMedication);
router.get('/:patientId', getMedicationsForPatient);

module.exports = router;
