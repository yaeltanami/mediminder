const express = require('express');
const pillBoxController = require('../controllers/pillBoxController');

const router = express.Router();

// יצירת קופסה חכמה למטופל
router.post('/create', pillBoxController.createPillBox);

// הקצאת תרופה אוטומטית לתא פנוי בקופסה
router.post('/assign-auto', pillBoxController.assignMedicationToAvailableSlot);

// קבלת מצב הקופסא
router.get('/status/:patientId', pillBoxController.getPillBoxStatus);


module.exports = router;