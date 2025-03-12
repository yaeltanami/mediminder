const express = require('express');
const { createPatient, getPatients } = require('../controllers/patientController');

const router = express.Router();
router.post('/create', createPatient);
router.get('/', getPatients);

module.exports = router;
