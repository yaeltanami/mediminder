const Caregiver = require('../models/caregiverModel');
const userService = require('./userService');
const Patient = require('../models/patientModel');
const admin = require('../config/firebase');
const User = require('../models/userModel');


/**
 * יצירת מטפל (`Caregiver`) עם `User`
 */
const registerCaregiver = async ({ name, email, password, patientsEmails }) => {
    const patientIds = [];
  
    // 1. בדיקת המטופלים לפני כל דבר אחר
    for (const email of patientsEmails) {
      const patientUser = await User.findOne({ email, role: 'patient' });
      if (!patientUser) {
        console.log(`Patient user not found for email: ${email}`);
        continue;
      }
  
      const patient = await Patient.findOne({ userId: patientUser._id });
      if (!patient) {
        console.log(`Patient record not found for userId: ${patientUser._id}`);
        continue;
      }
  
      patientIds.push(patient._id);
    }
  
    // 2. יצירת משתמש מסוג caregiver
    const user = await userService.registerUser({
      name,
      email,
      password,
      role: 'caregiver',
    });
    
    // 3. יצירת caregiver ושמירה
    let caregiver;
    try {
      caregiver = new Caregiver({
        userId: user._id,
        patients: patientIds,
      });
  
      await caregiver.save();
    } catch (err) {
      console.error('Failed to save caregiver:', err.message);
  
      // 🧹 אם נכשלת, ננקה את המשתמש שיצרנו
      await User.findByIdAndDelete(user._id);
      throw new Error('Failed to create caregiver – user was deleted');
    }
  
    // 4. קשר דו-כיווני למטופלים
for (const patientId of patientIds) {
  try {
    await addCaregiverToPatient(caregiver._id, patientId);
  } catch (err) {
    console.error(`Failed to link patient ${patientId} to caregiver:, err.message`);
  }
}
    // 5. יצירת טוקן
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
const addCaregiverToPatient = async (caregiverId, patientId) => {
    try {
        // בדיקה אם המטפל קיים
        const caregiver = await Caregiver.findById(caregiverId);
        if (!caregiver) throw new Error("Caregiver not found.");

        // בדיקה אם המטופל קיים
        const patient = await Patient.findById(patientId);
        if (!patient) throw new Error("Patient not found.");

        // הוספת המטפל לרשימת המטפלים של המטופל
        patient.caregivers.push(caregiverId);
        await patient.save();

        return { message: `Patient added to caregiver successfully.` };
    } catch (error) {
        console.error("Error adding patient to caregiver:", error);
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
        console.error("Error removing patient from caregiver:", error);
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
        console.error("Error retrieving patients for caregiver:", error);
        throw error;
    }
};


const sendCaregiverReminder = async (caregiverId, patientUserId, medications) => {
    
    try {
      const caregiver = await Caregiver.findById(caregiverId);
      const caregiverUser = await User.findById(caregiver.userId);
      if (!caregiverUser || !caregiverUser.fcmToken) {
        console.warn(`Caregiver ${caregiverId} has no FCM token`);
        return;
      }

      const patient = await User.findById(patientUserId);
      if (!patient) {
         console.warn(`Patient with ID ${patientUserId} not found`);
         return;
    }
    
    const medNames = medications.map(med => med.name).join(', ');
    const medData = medications.map(med => ({
      medicationId: med._id.toString(),
      medicationName: med.name,
      slotNumber: med.slotNumber?.toString() || ''
    }));
  
      // שליחת ההתראה
      const message = {
        token: caregiverUser.fcmToken,
        notification: {
          title: '\u200EMedication Reminder',
          body: `\u200E${patient.name} needs to take: ${medNames} now`,
        },
        android: {
          notification: {
            icon: 'notification_icon', 
            color: '#FFCC00' 
          }
        }, 
        data: {
          action: 'caregiver_reminder',
          patientName: patient.name,
          medications: JSON.stringify(medData)

        }
      };
  
      await admin.messaging().send(message);
    } catch (error) {
      console.error('error sending messasge to caregiver', error);
    }
  };


const findByUserId = async (userId) => {
  return await Caregiver.findOne({ userId });
};  

module.exports = { findByUserId, registerCaregiver, addCaregiverToPatient, removePatientFromCaregiver, getPatientsForCaregiver, sendCaregiverReminder };
