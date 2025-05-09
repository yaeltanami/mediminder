const Medication = require('../models/medicationModel');
const Patient = require('../models/patientModel');
const PillBox = require('../models/pillBoxModel');
const pillBoxService = require('../services/pillBoxService');
const User = require('../models/userModel');
const admin = require('../config/firebase'); // או הנתיב המתאים

/**
 * הוספת תרופה חדשה למטופל ושיבוצה לתא פנוי בקופסת התרופות.
 *
 * @param {string} patientId - מזהה המטופל
 * @param {string} name - שם התרופה
 * @param {string} dose - מינון
 * @param {array} times - מערך המכיל שעות נטילה ומספר כדורים לכל שעה
 *                        לדוגמה: [{time: "08:00", pillsCount: 2}, {time: "20:00", pillsCount: 1}]
 * @returns {Promise<object>} - מחזיר את התרופה החדשה ואת ההודעה למשתמש
 */
const addMedication = async (patientId, name, dose, times, days) => {
    try {

        // יצירת התרופה ושמירתה במסד הנתונים
        let newMedication = new Medication({ patientId, name, dose, times, days });
        let savedMedication = await newMedication.save();

        // הוספת התרופה לרשימת התרופות של המטופל
        await Patient.findByIdAndUpdate(patientId, { $push: { medications: savedMedication._id } });

        console.log(`patient id:${patientId} patient name ${name}`)

        // שיבוץ התרופה לתא פנוי בקופסה
        const { updatedPillBox, slotNumber } = await pillBoxService.assignMedicationToAvailableSlot(patientObjectId, savedMedication._id);

                // ✅ עדכון התרופה עם מספר התא שנבחר בקופסה
                savedMedication.slotNumber = slotNumber;
                await savedMedication.save();

        return {
            message: `🔔 הכנס את התרופה '${name}' לתא מספר ${slotNumber}`,
            medication: savedMedication,
            slotNumber,
            pillBox: updatedPillBox
        };
    } catch (error) {
        console.error('❌ Error adding medication:', error);
        throw error;
    }
};

/**
 * שליפת כל התרופות של מטופל מסוים.
 *
 * @param {string} patientId - מזהה המטופל
 * @returns {Promise<Array<object>>} - מחזיר מערך של כל התרופות של המטופל
 */
async function getMedicationsForPatient(patientId) {
    try {
        const medications = await Medication.find({ patientId });
        return medications;
    } catch (error) {
        console.error('❌ Error getting medications:', error);
        throw error;
    }
}

/**
 * פונקציה למחיקת תרופה ממסד הנתונים והסרתה מהמטופל ומהקופסה.
 *
 * @param {string} medicationId - מזהה התרופה למחיקה.
 * @returns {Promise<object>} - מחזיר הודעה המאשרת את המחיקה.
 */
const deleteMedication = async (medicationId) => {
    try {
        // בדיקה אם התרופה קיימת
        const medication = await Medication.findById(medicationId);
        if (!medication) {
            throw new Error("Medication not found.");
        }

        // הסרת התרופה ממטופל
        await Patient.findByIdAndUpdate(medication.patientId, {
            $pull: { medications: medicationId }
        });

        // מחיקת התרופה מהתא בקופסה
        await pillBoxService.removeMedicationFromPillBox(medication.patientId, medicationId);

        // מחיקת התרופה ממסד הנתונים
        await Medication.findByIdAndDelete(medicationId);

        console.log(`🗑️ Medication '${medication.name}' was successfully deleted`);

        return { message: "Medication deleted successfully" };
    } catch (error) {
        console.error("❌ Error deleting medication:", error);
        throw error;
    }
};

/**
 * עדכון תרופה קיימת - שינוי שם, מינון או שעות נטילה.
 *
 * @param {string} medicationId - מזהה התרופה
 * @param {object} updateData - הנתונים שצריך לעדכן
 * @returns {Promise<object>} - התרופה לאחר העדכון
 */
const updateMedication = async (medicationId, updateData) => {
    try {
        // חיפוש התרופה במסד הנתונים
        const medication = await Medication.findById(medicationId);
        if (!medication) {
            throw new Error("Medication not found.");
        }

        // עדכון הנתונים רק אם התקבלו שדות רלוונטיים
        if (updateData.name) medication.name = updateData.name;
        if (updateData.dose) medication.dose = updateData.dose;
        if (updateData.times) {
            if (!Array.isArray(updateData.times)) {
                throw new Error("Times must be an array of objects.");
            }

            updateData.times.forEach(entry => {
                if (!entry.time || typeof entry.pillsCount !== 'number') {
                    throw new Error("Each entry in 'times' must have a 'time' and a numeric 'pillsCount'.");
                }
            });

            medication.times = updateData.times;
        }
                // עדכון הימים אם התקבלו
        if (updateData.days) {
            const validDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                    
            if (!Array.isArray(updateData.days)) {
                throw new Error("Days must be an array of strings.");
            }
        
             updateData.days.forEach(day => {
                 if (!validDays.includes(day)) {
                    throw new Error(`Invalid day provided: ${day}`);
                }
            });
        
            medication.days = updateData.days;
        }

        // שמירת השינויים במסד הנתונים
        const updatedMedication = await medication.save();

        console.log(`✏️ Medication '${updatedMedication.name}' was successfully updated`);
        return updatedMedication;
    } catch (error) {
        console.error("❌ Error updating medication:", error);
        throw error;
    }
};

/**
 * Retrieves medication details by medicationId.
 *
 * @param {string} medicationId - The ID of the medication.
 * @returns {Promise<object>} - The medication details.
 */
const getMedicationById = async (medicationId) => {
    try {
        const medication = await Medication.findById(medicationId);
        
        if (!medication) {
            throw new Error("Medication not found.");
        }

        return medication;
    } catch (error) {
        console.error("❌ Error retrieving medication:", error);
        throw error;
    }
};

const markAsTaken = async (userId, medicationId) => {
   
    const user = await User.findById(userId);
    if (!user || !user.fcmToken) {
      throw new Error('User or FCM token not found');
    }
  
    const message = {
      token: user.fcmToken,
      data: {
        action: 'medication_taken',
        medicationId,
      },
    };
  
    await admin.messaging().send(message);
    console.log(`📤 Sent 'medication_taken' notification to user ${userId}`);
  };


// בדיקת התאמה בין זמן נוכחי לשעת התרופה
function isTimeMatching(currentHour, currentMinute, medicationTime) {
    const [medHour, medMinute] = medicationTime.split(':').map(Number);
  
    return medHour === currentHour && medMinute === currentMinute;
  }
  
const getDueMedicationsStates = async (patientId) => {
    const patient = await Patient.findById(patientId).populate('medications');
    const now = new Date();
    const currentDay = now.toLocaleDateString('en-US', { weekday: 'long' }); // למשל "Sunday"
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
  
    let states = ['0', '0', '0', '0', '0']; // חמישה תאים בקופסה
  
    for (const medication of patient.medications) {
      if (medication.days.includes(currentDay)) {
        console.log(`🔍 Found medication for today: ${medication.name}`);
        for (const time of medication.times) {
          console.log(`⏰ Checking if current time (${currentHour}:${currentMinute}) matches time: ${time}`);
          if (isTimeMatching(currentHour, currentMinute, time)) {
            console.log(`✅ Time matches for medication: ${medication.name}`);
            states[medication.slotNumber - 1] = '1';
          }
        }
      }
    }
    return states.join('');
};
module.exports = {
    addMedication,
    getMedicationsForPatient,
    deleteMedication,
    updateMedication,
    getMedicationById,
    markAsTaken,
    getDueMedicationsStates,
};
