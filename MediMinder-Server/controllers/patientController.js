const patientService = require('../services/patientService');
const jwt = require('jsonwebtoken');


/**
 * בקר לרישום מטופל חדש
 */
const registerPatient = async (req, res) => {
    try {
        console.log("try to register");
        const { name, email, password, birthDate, caregivers } = req.body;

        if (!name || !email || !password || !birthDate) {
            return res.status(400).json({ message: 'All fields are required' });
        }
        console.log("all fiels good");

        const { user, patient, token } = await patientService.registerPatient({ name, email, password, birthDate, caregivers });
        res.status(201).json({ user, patient, token });

    } catch (error) {
                console.log("do not work4");

        res.status(400).json({ message: error.message });
    }
};

/**
 * Controller to get the list of caregiver IDs for a specific patient.
 */
const getCaregiversForPatient = async (req, res) => {
    try {
        const { patientId } = req.params;
        const caregiverIds = await patientService.getCaregiversForPatient(patientId);
        res.status(200).json(caregiverIds);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
};


module.exports = { registerPatient, getCaregiversForPatient };
