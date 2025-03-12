const express = require('express');
const { assignMedicationToSlot } = require('../controllers/pillBoxController');

const router = express.Router();

router.post('/assign', assignMedicationToSlot); // הקצאת תרופה לתא

module.exports = router;
