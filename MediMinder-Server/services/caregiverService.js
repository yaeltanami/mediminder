const Caregiver = require('../models/caregiverModel');
const userService = require('./userService');
const Patient = require('../models/patientModel');

/**
 * יצירת מטפל (`Caregiver`) עם `User`
 */
const registerCaregiver = async ({ name, email, password, patients }) => {
    // יצירת משתמש עם role קבוע ל'caregiver'
    const user = await userService.registerUser({ name, email, password, role: 'caregiver' });

    // יצירת מטפל חדש עם פרטי המשתמש
    const caregiver = await Caregiver.create({
        userId: user._id,
        patients: patients || []
    });

    // קישור המטופלים למטפל
    if (patients && patients.length > 0) {
        await Patient.updateMany(
            { _id: { $in: patients } },
            { $push: { caregivers: caregiver._id } }
        );
    }

    // יצירת טוקן
    const token = userService.generateToken(user._id, user.role);

    return { user, caregiver, token };
};

module.exports = { registerCaregiver };
