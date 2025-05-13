const Patient = require('../models/patientModel');
const User = require('../models/userModel');
const PillBox = require('../models/pillBoxModel');
const userService = require('./userService');
const pillBoxService = require('./pillBoxService');
const Medication = require('../models/medicationModel');
const admin = require('../config/firebase');

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
 * @param {string} userId - The patient's ID
 * @param {string} medicationId - The medication's ID
 */
const sendPatientReminder = async (userId, medicationId) => {
    try {  
      const user = await User.findById(userId);
      if (!user) {
        console.error(`❌ User for patient ${userId} not found.`);
        return;
      }
      if (!user.fcmToken) {
        console.warn(`⚠️ User ${user._id} has no FCM token.`);
        return;
      }
      const medication = await Medication.findById(medicationId);
      if (!medication) {
        console.error(`❌ Medication with ID ${medicationId} not found.`);
        return;
      }
      const message = {
        token: user.fcmToken,
        notification: {
          title: 'Medication Reminder',
          body: `Time to take: ${medication.name}`,
        },
        data: {
          action: 'medication_reminder',
          userId: user._id.toString(),
          medicationId: medication._id.toString(),
          medicationName: medication.name,
        }
      };
      const response = await admin.messaging().send(message);
      console.log(`📢 התראה נשלחה למשתמש ${user._id}: ${medication.name}`);
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

const findByUserId = async (userId) => {
  return await Patient.findOne({ userId });
};


module.exports = { registerPatient, sendPatientReminder, getCaregiversForPatient, findByUserId};
