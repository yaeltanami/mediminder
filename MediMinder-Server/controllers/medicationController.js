const medicationService = require('../models/medicationModel');

// יצירת תרופה
async function createMedication(req, res) {
    const { patientId, name, dose, times, slotNumber } = req.body;
    try {
        const medication = await medicationService.addMedication(patientId, name, dose, times, slotNumber);
        res.status(201).json(medication);  // מחזירים את התרופה שנוספה
    } catch (error) {
        res.status(500).json({ message: 'Error adding medication', error });
    }
}

module.exports = {
    createMedication}