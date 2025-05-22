const caregiverService = require('../services/caregiverService');

/**
 * בקר לרישום מטפל חדש
 */
const registerCaregiver = async (req, res) => {
    try {
        const { name, email, password, patientsEmails } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const data = await caregiverService.registerCaregiver({
            name,
            email,
            password,
            patientsEmails,
        });
        res.status(201).json(data);

    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};
/**
 * בקר להוספת מטופל למטפל
 */
const addCaregiverToPatient = async (req, res) => {
    try {
        const { caregiverId, patientId } = req.body;
        const response = await caregiverService.addCaregiverToPatient(caregiverId, patientId);
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

/**
 * Controller to get the list of patients for a specific caregiver.
 */
const getPatientsForCaregiver = async (req, res) => {
    try {
        const { caregiverId } = req.params;
        const patients = await caregiverService.getPatientsForCaregiver(caregiverId);
        res.status(200).json(patients);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
};
const getCaregiverByUserId = async (req, res) => {
  try {
    const { userId } = req.params;
    const caregiver = await caregiverService.findByUserId(userId);
    if (!caregiver) {
      return res.status(404).json({ message: 'Caregiver not found' });
    }
    res.json(caregiver);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getCaregiverByUserId, registerCaregiver, addCaregiverToPatient, removePatientFromCaregiver, getPatientsForCaregiver };
