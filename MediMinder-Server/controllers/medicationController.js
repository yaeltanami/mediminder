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

// קבלת כל התרופות של מטופל
async function getMedicationsForPatient(req, res) {
    const { patientId } = req.params;
    try {
        const medications = await medicationService.getMedicationsForPatient(patientId);
        res.status(200).json(medications);  // מחזירים את כל התרופות של המטופל
    } catch (error) {
        res.status(500).json({ message: 'Error getting medications', error });
    }
}

module.exports = {
    createMedication, getMedicationsForPatient
}