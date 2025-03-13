const caregiverService = require('../services/caregiverService');

/**
 * בקר לרישום מטפל חדש
 */
const registerCaregiver = async (req, res) => {
    try {
        const { name, email, password, patients } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ message: 'All fields are required' });
        }

        const { user, caregiver, token } = await caregiverService.registerCaregiver({ name, email, password, patients });
        res.status(201).json({ user, caregiver, token });

    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = { registerCaregiver };
