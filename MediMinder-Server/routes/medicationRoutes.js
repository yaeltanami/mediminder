const express = require('express');
const router = express.Router();
const medicationController = require('../controllers/medicationController');

router.post('/create', medicationController.createMedication);

module.exports = router;
