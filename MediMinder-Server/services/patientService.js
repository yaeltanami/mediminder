const Patient = require('../models/patientModel');
const PillBox = require('../models/pillBoxModel');
const userService = require('./userService');

/**
 * יצירת מטופל (`Patient`) עם `User` ו- `PillBox`
 */


const registerPatient = async ({ name, email, password, birthDate, caregivers, pillbox }) => {
    const user = await userService.registerUser({ name, email, password, role: 'patient' });

    const patient = await Patient.create({
        userId: user._id,
        birthDate,
        caregivers: caregivers || []
    });

    // יצירת `PillBox` אם סופק בבקשה
    let createdPillBox = null;
    if (pillbox) {
        createdPillBox = await PillBox.create({
            patientId: patient._id,
            compartments: pillbox.compartments || 5 // ברירת מחדל: 5 תאים
        });

        // עדכון המטופל כך שיקושר ל-PillBox
        patient.pillBox = createdPillBox._id;
        await patient.save();
    }

    // יצירת טוקן
    const token = userService.generateToken(user._id, user.role);

    return { user, patient, pillBox: createdPillBox, token };
};

module.exports = { registerPatient };
