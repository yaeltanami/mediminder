const express = require('express');
const { createPillBox } = require('../controllers/pillBoxController'); // וודאי שהייבוא תקין

const router = express.Router();

// יצירת קופסה חכמה למטופל
router.post('/create', createPillBox);

// הקצאת תרופה אוטומטית לתא פנוי בקופסה
router.post('/assign-auto', assignMedicationToAvailableSlot);

module.exports = router;