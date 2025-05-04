const caregiverService = require('../services/caregiverService');

/**
 * בקר לרישום מטפל חדש
 */
const registerCaregiver = async (req, res) => {
    try {
      const { name, email, password, patientsEmails } = req.body;
  
      const data = await caregiverService.registerCaregiver({
        name,
        email,
        password,
        patientsEmails,
      });
  
      res.status(201).json(data);
    } catch (err) {
      console.error('❌ Error in registerCaregiver controller:', err);
      res.status(500).json({ error: 'Server error' });
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

module.exports = { registerCaregiver, addPatientToCaregiver, removePatientFromCaregiver, getPatientsForCaregiver };
