const express = require('express');
const router = express.Router();
const medicationController = require('../controllers/medicationController');

router.post('/add', medicationController.createMedication);
router.get('/patient/:patientId', medicationController.getMedicationsForPatient);
router.delete('/delete/:medicationId', medicationController.deleteMedication); 
router.put('/update/:medicationId', medicationController.updateMedication);
router.get('/:medicationId', medicationController.getMedicationById);



module.exports = router;
