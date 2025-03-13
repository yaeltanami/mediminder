const patientService = require('../services/patientService');

/**
 * בקר לרישום מטופל חדש
 */
const registerPatient = async (req, res) => {
    try {
        const { name, email, password, birthDate, caregivers } = req.body;

        if (!name || !email || !password || !birthDate) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const { user, patient, token } = await patientService.registerPatient({ name, email, password, birthDate, caregivers });
        res.status(201).json({ user, patient, token });

    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = { registerPatient };
