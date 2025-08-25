const PillBox = require('../models/pillBoxModel');
const User = require('../models/userModel');
const Medication = require('../models/medicationModel');
const pillBoxService = require('../services/pillBoxService');

/**
 * בקר ליצירת קופסה חכמה למטופל.
 * קורא לפונקציית `createPillBox` שב-`services/pillBoxService.js`
 */
const createPillBox = async (req, res) => {
    try {
        const { patientId } = req.body;

        // קריאה ללוגיקה העסקית ליצירת קופסה חכמה
        const pillBox = await pillBoxService.createPillBox(patientId);

        res.status(201).json({ message: "PillBox created successfully", pillBox });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

/**
 * 💊 הקצאת תרופה אוטומטית לתא פנוי בקופסה החכמה
 * 
 * @route POST /api/pillbox/assign-auto
 * @param {string} req.body.patientId - מזהה המטופל
 * @param {string} req.body.medicationId - מזהה התרופה
 * @returns {object} - קופסת התרופות המעודכנת ומספר התא שנבחר
 */
const assignMedicationToAvailableSlot = async (req, res) => {
    try {
        const { patientId, medicationId } = req.body;

        if (!patientId || !medicationId) {
            return res.status(400).json({ message: 'Patient ID and Medication ID are required' });
        }

        const { updatedPillBox, slotNumber } = await pillBoxService.assignMedicationToAvailableSlot(patientId, medicationId);

        res.status(200).json({ 
            message: `Medication assigned automatically to slot ${slotNumber}`, 
            slotNumber,
            pillBox: updatedPillBox 
        });
    } catch (error) {
        res.status(500).json({ message: 'Error assigning medication', error: error.message });
    }
};

/**
 * Controller to get the pillbox status for a specific patient.
 */
const getPillBoxStatus = async (req, res) => {
    try {
        const { patientId } = req.params;
        const pillBoxStatus = await pillBoxService.getPillBoxStatus(patientId);
        res.status(200).json(pillBoxStatus);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
};

const getUserByPillBoxId = async (req, res) => {
  try {
    const { pillBoxId } = req.params;
    const user = await pillBoxService.getUserByPillBoxId(pillBoxId);
    res.status(200).json(user);
  } catch (err) {
    res.status(404).json({ message: err.message });
  }
};


module.exports = {
     createPillBox ,
      assignMedicationToAvailableSlot,
      getPillBoxStatus, 
      getUserByPillBoxId
     };

