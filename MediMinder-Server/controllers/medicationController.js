const medicationService = require('../services/medicationsService');

/**
 * בקר להוספת תרופה חדשה למטופל
 */
async function createMedication(req, res) {
    const { patientId, name, dose, times, slotNumber } = req.body;
    try {
        // קריאה לשירות שמוסיף את התרופה למטופל
        const medication = await medicationService.addMedication(patientId, name, dose, times, slotNumber);
        res.status(201).json(medication);  // החזרת התרופה שנוספה
    } catch (error) {
        res.status(500).json({ message: '❌ Error adding medication', error: error.message });
    }
}

/**
 * בקר לשליפת כל התרופות של מטופל מסוים
 */
async function getMedicationsForPatient(req, res) {
    const { patientId } = req.params;
    try {
        const medications = await medicationService.getMedicationsForPatient(patientId);
        res.status(200).json(medications);  // החזרת כל התרופות של המטופל
    } catch (error) {
        res.status(500).json({ message: '❌ Error getting medications', error: error.message });
    }
}

module.exports = {
    createMedication,
    getMedicationsForPatient
};
