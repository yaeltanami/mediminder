const express = require('express');
const router = express.Router();
const medicationLogController = require('../controllers/medicationLogController');

router.post('/', medicationLogController.createMedicationLog);
router.get('/:patientId/:date', medicationLogController.getLogsByPatientAndDate);


module.exports = router;
