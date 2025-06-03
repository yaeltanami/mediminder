const Patient = require('../models/patientModel');
const User = require('../models/userModel');
const PillBox = require('../models/pillBoxModel');
const userService = require('./userService');
const pillBoxService = require('./pillBoxService');
const Medication = require('../models/medicationModel');
const admin = require('../config/firebase');
const Caregiver = require('../models/caregiverModel');
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


// /**
//  * Sends a reminder notification to a patient to take their medication.
//  *
//  * @param {string} userId - The patient's ID
//  * @param {string} medicationId - The medication's ID
//  */
// const sendPatientReminder = async (userId, medicationId, currentHourMinute) => {
//     try {  
//       const user = await User.findById(userId);
//       if (!user) {
//         console.error(`❌ User for patient ${userId} not found.`);
//         return;
//       }
//       if (!user.fcmToken) {
//         console.warn(`⚠️ User ${user._id} has no FCM token.`);
//         return;
//       }
//       const medication = await Medication.findById(medicationId);
//       if (!medication) {
//         console.error(`❌ Medication with ID ${medicationId} not found.`);
//         return;
//       }
//       const message = {
//         token: user.fcmToken,
//         notification: {
//           title: '\u200EMedication Reminder',
//           body: `\u200ETime to take: ${medication.name}`,
//         },
//         android: {
//           notification: {
//             icon: 'notification_icon', // שם הקובץ בלי סיומת (למשל notification_icon.png)
//             color: '#FFCC00' // צהוב בהיר – תואם ללוגו שלך
//           }
//         },
//         data: {
//           action: 'medication_reminder',
//           userId: user._id.toString(),
//           medicationId: medication._id.toString(),
//           medicationName: medication.name,
//           slotNumber: medication.slotNumber.toString(),
//           timeToTake: currentHourMinute,
//         }
//       };
//       const response = await admin.messaging().send(message);
//       console.log(`📢 התראה נשלחה למשתמש ${user._id}: ${medication.name}`);
//     } catch (error) {
//       console.error('❌ Error sending reminder to patient:', error);
//     }
//   };
  
/**
 * Sends a combined reminder to a user for multiple medications at once.
 * @param {User} user
 * @param {Array} medications
 * @param {string} currentHourMinute
 */
const sendPatientReminder = async (user, medications, currentHourMinute) => {
  try {
    if (!user?.fcmToken) {
      console.warn(`⚠️ No FCM token for user ${user._id}`);
      return;
    }

// יוצרים מחרוזת אחת שמכילה את שמות כל התרופות, מופרדות בפסיקים (לכותרת ההתראה)
    const medNames = medications.map(med => med.name).join(', ');
    // יוצרים מערך חדש של אובייקטים שמכילים מידע בסיסי על כל תרופה
    const medData = medications.map(med => ({
      medicationId: med._id.toString(),
      medicationName: med.name,
      slotNumber: med.slotNumber?.toString() || ''
    }));

    const message = {
      token: user.fcmToken,
      notification: {
        title: '\u200EMedication Reminder',
        body: `\u200ETime to take: ${medNames}`,
      },
      android: {
        notification: {
          icon: 'notification_icon',
          color: '#FFCC00'
        }
      },
      data: {
        action: 'medication_reminder',
        userId: user._id.toString(),
        timeToTake: currentHourMinute,
        medications: JSON.stringify(medData)
      }
    };

    const response = await admin.messaging().send(message);
    console.log(`📢 תזכורת מרוכזת נשלחה ל-${user.name} לתרופות: ${medNames}`);
  } catch (err) {
    console.error('❌ Error sending combined medication reminder:', err);
  }
};


/**
הפונקציה מחזירה מערך של שם ומייל של המטפלים של משתמש 
 */
const getCaregiversNamesForPatient = async (patientId) => {
    try {
        // חיפוש המטופל ושליפת כל המטפלים שלו, אך מחזירים רק את ה-ID
        const patient = await Patient.findById(patientId);

        if (!patient) {
            throw new Error("Patient not found.");
        }

        const caregivers = await Caregiver.find({
            _id: { $in: patient.caregivers }
          });

    // שליפת המשתמשים של כל המטפלים
    const userIds = caregivers.map(c => c.userId);
    const users = await User.find({ _id: { $in: userIds } }).select('name email');

    return users;
    } catch (error) {
        console.error("❌ Error retrieving caregivers for patient:", error);
        throw error;
    }
};

/**
 * מחזירה מערך של מזהי המטפלים של מטופל לפי מזהה המטופל
 */
const getCaregiversForPatient = async (patientId) => {
  try {
    const patient = await Patient.findById(patientId);
    if (!patient) throw new Error("Patient not found.");

    return patient.caregivers; // כבר מכיל מזהי Caregiver
  } catch (error) {
    console.error("❌ Error retrieving caregiver IDs for patient:", error);
    throw error;
  }
};


const findByUserId = async (userId) => {
  return await Patient.findOne({ userId });
};

const getPatientByEmail = async (email) => {
  if (!email) throw new Error('Email is required');

  const user = await User.findOne({ email, role: 'patient' });
  if (!user) throw new Error('Patient not found');

  const patient = await Patient.findOne({ userId: user._id });
  if (!patient) throw new Error('Patient data not found');

  return patient;
};


module.exports = { registerPatient, getCaregiversNamesForPatient, findByUserId, getPatientByEmail, getCaregiversForPatient, sendPatientReminder};
