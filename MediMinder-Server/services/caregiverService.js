const Caregiver = require('../models/caregiverModel');
const userService = require('./userService');
const Patient = require('../models/patientModel');
const admin = require('../config/firebase');


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

/**
 * Retrieves the list of patients assigned to a caregiver.
 *
 * @param {string} caregiverId - The ID of the caregiver.
 * @returns {Promise<Array<string>>} - The list of patient IDs.
 */
const getPatientsForCaregiver = async (caregiverId) => {
    try {
        // חיפוש המטפל ושליפת כל המטופלים שלו, אך מחזירים רק את ה-ID
        const caregiver = await Caregiver.findById(caregiverId).populate('patients', '_id');

        if (!caregiver) {
            throw new Error("Caregiver not found.");
        }

        return caregiver.patients;
    } catch (error) {
        console.error("❌ Error retrieving patients for caregiver:", error);
        throw error;
    }
};


const sendCaregiverReminder = async (caregiver, patientUserId, medication) => {
    
    try {
      const caregiverUser = await User.findById(caregiver.userId);
      if (!caregiverUser || !caregiverUser.fcmToken) {
        console.warn(`⚠️ Caregiver ${caregiverId} has no FCM token`);
        return;
      }
  
      // שליחת ההתראה
      const message = {
        token: caregiverUser.fcmToken,
        notification: {
          title: 'המטופל שלך צריך לקחת תרופה',
          body: `יש לעקוב אחרי התרופה: ${medication.name}`,
        },
        data: {
          action: 'caregiver_reminder',
          patientUserId: patientUserId.toString(),
          medicationId: medication._id.toString(),
          medicationName: medication.name,
        }
      };
  
      await admin.messaging().send(message);
      console.log(`📨 התראה נשלחה למטפל ${caregiverUser.name} על התרופה ${medication.name}`);
    } catch (error) {
      console.error('❌ שגיאה בשליחת התראה למטפל:', error);
    }
  };
const findByUserId = async (userId) => {
  return await Caregiver.findOne({ userId });
};  

module.exports = { findByUserId, registerCaregiver, addPatientToCaregiver, removePatientFromCaregiver, getPatientsForCaregiver, sendCaregiverReminder };
