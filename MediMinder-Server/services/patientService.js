const Patient = require('../models/patientModel');
const PillBox = require('../models/pillBoxModel');
const userService = require('./userService');
const pillBoxService = require('./pillBoxService');
const Medication = require('../models/medicationModel');



/**
 * רישום מטופל חדש ויצירת קופסת תרופות אוטומטית.
 *
 * @param {string} name - שם המטופל
 * @param {string} email - כתובת המייל
 * @param {string} password - סיסמה
 * @param {date} birthDate - תאריך לידה
 * @param {array} caregivers - מזהי המטפלים
 * @returns {object} - מחזיר את המשתמש, המטופל וקופסת התרופות שנוצרה
 */

const registerPatient = async ({ name, email, password, birthDate, caregivers}) => {
    const user = await userService.registerUser({ name, email, password, role: 'patient' });

    const patient = await Patient.create({
        userId: user._id,
        birthDate,
        caregivers: caregivers || [],
        medications: [] 
    });

    // יצירת `PillBox` כברירת מחדל לכל מטופל חדש
    const pillBox = await pillBoxService.createPillBox(patient._id);


    // קישור `PillBox` שנוצר למטופל
    patient.pillBox = pillBox._id;
    await patient.save();

    // יצירת טוקן
    const token = userService.generateToken(user._id, user.role);

    return { user, patient, pillBox, token };
};


/**
 * Sends a reminder notification to a patient to take their medication.
 *
 * @param {string} patientId - The patient's ID
 * @param {string} medicationId - The medication's ID
 */
const sendPatientReminder = async (patientId, medicationId) => {
    try {
        // Fetch medication details from the database
        const medication = await Medication.findById(medicationId);

        if (!medication) {
            console.error(`❌ Medication with ID ${medicationId} not found.`);
            return;
        }

        console.log(`📢 Reminder sent to patient ${patientId}: Please take your medication - ${medication.name}`);

        // Here you can integrate push notifications or SMS sending
        // Example: sendPushNotification(patientId, `Time to take your medication: ${medication.name}`);
    } catch (error) {
        console.error('❌ Error sending reminder to patient:', error);
    }
};

/**
 * Retrieves the list of caregiver IDs assigned to a patient.
 *
 * @param {string} patientId - The ID of the patient.
 * @returns {Promise<Array<string>>} - The list of caregiver IDs.
 */
const getCaregiversForPatient = async (patientId) => {
    try {
        // חיפוש המטופל ושליפת כל המטפלים שלו, אך מחזירים רק את ה-ID
        const patient = await Patient.findById(patientId).populate('caregivers', '_id');

        if (!patient) {
            throw new Error("Patient not found.");
        }

        // מחזירים רק מערך של מזהי המטפלים
        return patient.caregivers.map(caregiver => caregiver._id);
    } catch (error) {
        console.error("❌ Error retrieving caregivers for patient:", error);
        throw error;
    }
};

module.exports = { registerPatient, sendPatientReminder, getCaregiversForPatient };
