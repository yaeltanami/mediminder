const medicationService = require('../services/medicationsService');

/**
 * בקר להוספת תרופה חדשה למטופל
 */

async function createMedication(req, res) {
    try {
        const { patientId, name, dose, times } = req.body;

        if (!patientId || !name || !dose || !times) {
            return res.status(400).json({ message: '❌ All fields are required' });
        }

        const result = await medicationService.addMedication(patientId, name, dose, times);

        res.status(201).json(result);
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

/**
 * בקר למחיקת תרופה.
 */
const deleteMedication = async (req, res) => {
    try {
        const { medicationId } = req.params;
        const response = await medicationService.deleteMedication(medicationId);
        res.status(200).json(response);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

/**
 * בקר לעדכון תרופה קיימת.
 */
const updateMedication = async (req, res) => {
    try {
        const { medicationId } = req.params;
        const updateData = req.body;

        const updatedMedication = await medicationService.updateMedication(medicationId, updateData);

        res.status(200).json({
            message: "Medication updated successfully",
            medication: updatedMedication
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = {
    createMedication,
    getMedicationsForPatient,
    deleteMedication,
    updateMedication
};
