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

module.exports = { registerPatient, sendPatientReminder };
