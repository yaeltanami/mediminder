const express = require('express');
const router = express.Router();
const medicationController = require('../controllers/medicationController');

router.post('/create', medicationController.createMedication);
router.get('/medications/:patientId', medicationController.getMedicationsForPatient);


module.exports = router;
