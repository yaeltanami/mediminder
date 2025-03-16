const caregiverService = require('../services/caregiverService');

/**
 * בקר לרישום מטפל חדש
 */
const registerCaregiver = async (req, res) => {
    try {
        const { name, email, password, patients, relation } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const { user, caregiver, token } = await caregiverService.registerCaregiver({ name, email, password, patients, relation });
        res.status(201).json({ user, caregiver, token });

    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};
/**
 * בקר להוספת מטופל למטפל
 */
const addPatientToCaregiver = async (req, res) => {
    try {
        const { caregiverId, patientId } = req.body;
        const response = await caregiverService.addPatientToCaregiver(caregiverId, patientId);
        res.status(200).json(response);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

/**
 * בקר להסרת מטופל ממטפל
 */
const removePatientFromCaregiver = async (req, res) => {
    try {
        const { caregiverId, patientId } = req.body;
        const response = await caregiverService.removePatientFromCaregiver(caregiverId, patientId);
        res.status(200).json(response);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = { registerCaregiver, addPatientToCaregiver, removePatientFromCaregiver };
