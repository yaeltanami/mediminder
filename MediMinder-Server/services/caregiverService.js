const Caregiver = require('../models/caregiverModel');
const userService = require('./userService');
const Patient = require('../models/patientModel');

/**
 * יצירת מטפל (`Caregiver`) עם `User`
 */
const registerCaregiver = async ({ name, email, password, patients, relation }) => {
    // יצירת משתמש עם role קבוע ל'caregiver'
    const user = await userService.registerUser({ name, email, password, role: 'caregiver' });

    // יצירת מטפל חדש עם פרטי המשתמש
    const caregiver = await Caregiver.create({
        userId: user._id,
        patients: patients || [],
        relation: relation
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


/**
 * הוספת מטופל לרשימת המטופלים של מטפל
 *
 * @param {string} caregiverId - מזהה המטפל
 * @param {string} patientId - מזהה המטופל
 * @returns {Promise<object>} - מחזיר הודעת הצלחה
 */
const addPatientToCaregiver = async (caregiverId, patientId) => {
    try {
        // בדיקה אם המטפל קיים
        const caregiver = await Caregiver.findById(caregiverId);
        if (!caregiver) throw new Error("Caregiver not found.");

        // בדיקה אם המטופל קיים
        const patient = await Patient.findById(patientId);
        if (!patient) throw new Error("Patient not found.");

        // בדיקה אם המטופל כבר קיים אצל המטפל
        if (caregiver.patients.includes(patientId)) {
            throw new Error("Patient is already assigned to this caregiver.");
        }

        // הוספת המטופל לרשימת המטופלים של המטפל
        caregiver.patients.push(patientId);
        await caregiver.save();

        // הוספת המטפל לרשימת המטפלים של המטופל
        patient.caregivers.push(caregiverId);
        await patient.save();

        return { message: `Patient added to caregiver successfully.` };
    } catch (error) {
        console.error("❌ Error adding patient to caregiver:", error);
        throw error;
    }
};

/**
 * הסרת מטופל מרשימת המטופלים של מטפל
 *
 * @param {string} caregiverId - מזהה המטפל
 * @param {string} patientId - מזהה המטופל
 * @returns {Promise<object>} - מחזיר הודעת הצלחה
 */
const removePatientFromCaregiver = async (caregiverId, patientId) => {
    try {
        // בדיקה אם המטפל קיים
        const caregiver = await Caregiver.findById(caregiverId);
        if (!caregiver) throw new Error("Caregiver not found.");

        // בדיקה אם המטופל קיים
        const patient = await Patient.findById(patientId);
        if (!patient) throw new Error("Patient not found.");

        // בדיקה אם המטופל נמצא אצל המטפל
        if (!caregiver.patients.includes(patientId)) {
            throw new Error("Patient is not assigned to this caregiver.");
        }

        // הסרת המטופל מרשימת המטופלים של המטפל
        caregiver.patients = caregiver.patients.filter(id => id.toString() !== patientId);
        await caregiver.save();

        // הסרת המטפל מרשימת המטפלים של המטופל
        patient.caregivers = patient.caregivers.filter(id => id.toString() !== caregiverId);
        await patient.save();

        return { message: `Patient removed from caregiver successfully.` };
    } catch (error) {
        console.error("❌ Error removing patient from caregiver:", error);
        throw error;
    }
};

module.exports = { registerCaregiver, addPatientToCaregiver, removePatientFromCaregiver };
