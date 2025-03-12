const PillBox = require('../models/pillBoxModel');
const Medication = require('../models/medicationModel');
const pillBoxService = require('../services/pillBoxService');

/**
 * בקר ליצירת קופסה חכמה למטופל.
 * קורא לפונקציית `createPillBox` שב-`services/pillBoxService.js`
 */
createPillBox = async (req, res) => {
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
 * בקר להקצאת תרופה אוטומטית לתא פנוי בקופסה החכמה.
 */
assignMedicationToAvailableSlot = async (req, res) => {
    try {
        const { patientId, medicationId } = req.body;

        // קריאה לפונקציה שמבצעת הקצאה אוטומטית
        const { updatedPillBox, slotNumber } = await pillBoxService.assignMedicationToAvailableSlot(patientId, medicationId);

        res.status(200).json({ 
            message: `Medication assigned automatically to slot ${slotNumber}`, 
            slotNumber,
            pillBox: updatedPillBox 
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { createPillBox , assignMedicationToAvailableSlot };

