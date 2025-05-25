const express = require('express');

const router = express.Router();

// חיבור כל הנתיבים במקום אחד
router.use('/users', require('./userRoutes'));
router.use('/patients', require('./patientRoutes'));
router.use('/caregivers', require('./caregiverRoutes'));
router.use('/medications', require('./medicationRoutes'));
router.use('/pillbox', require('./pillBoxRoutes'));
router.use('/esp', require('./espRoutes'));
router.use('/medicationLog',require('./medicationLogRoutes'));

module.exports = router;
