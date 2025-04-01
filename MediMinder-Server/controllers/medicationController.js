const medicationService = require('../services/medicationsService');

/**
 * בקר להוספת תרופה חדשה למטופל
 */

async function createMedication(req, res) {
    try {
        const { patientId, name, dose, times, days } = req.body;
        console.log(`day ${days}`);

        if (!patientId || !name || !dose || !times || !days)  {
            return res.status(400).json({ message: '❌ All fields are required' });
        }

                // בדיקה שכל איבר במערך תקין
        for (let entry of times) {
            if (!entry.time || typeof entry.pillsCount !== 'number') {
                return res.status(400).json({ message: '❌ Each entry in times must have time and pillsCount' });
            }
        }

        const result = await medicationService.addMedication(patientId, name, dose, times, days);

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

/**
 * Controller to get a specific medication by its ID.
 */
const getMedicationById = async (req, res) => {
    try {
        const { medicationId } = req.params;
        console.log(`🔎 Searching for medication ID: ${medicationId}`);
        const medication = await medicationService.getMedicationById(medicationId);
        res.status(200).json(medication);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
};

// תרופות לפי יום
const getMedicationsByDay = async (req, res) => {
    const { patientId, day } = req.params;
  
    try {
      const medications = await medicationService.getMedicationsForPatient(patientId);
  
      // סינון לפי יום הרצוי
      const filtered = medications.filter(med => med.days.includes(day));
      res.status(200).json(filtered);
    } catch (error) {
      res.status(500).json({ message: '❌ Error getting medications for day', error: error.message });
    }
  };
  

module.exports = {
    createMedication,
    getMedicationsForPatient,
    deleteMedication,
    updateMedication,
    getMedicationById, 
    getMedicationsByDay
};
