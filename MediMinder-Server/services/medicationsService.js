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
 * @param {array} times - שעות הנטילה
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
        const { updatedPillBox, slotNumber } = await pillBoxService.assignMedicationToAvailableSlot(patientId, savedMedication._id);

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


async function getMedicationsForPatientByDay(patientId, day) {
    try {
        const medications = await Medication.find({ patientId });
        const filtered = medications.filter(med => med.days.includes(day));
          // חישוב כמה פעמים המטופל צריך לקחת תרופות באותו היום
        const totalIntakeCount = filtered.reduce((sum, med) => {
        return sum + (med.times?.length || 0);
        }, 0);
         return {
            medications: filtered,
            totalIntakeCount
         };
    } catch (error) {
        console.error('❌ Error getting medications:', error);
        throw error;
    }
}

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
        if (updateData.times) medication.times = updateData.times;
        if (updateData.days) medication.days = updateData.days;


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
    const pillBox = await PillBox.findOne({ patientId });
    if (!pillBox) {
        console.error(`❌ No pillbox found for patient ${patientId}`);
        return null;
    }
    const now = new Date();
    const currentDay = now.toLocaleDateString('en-US', { weekday: 'long' }); // למשל "Sunday"
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();

    console.log(`📆 Current day: ${currentDay}`);
    console.log(`🕒 Current time: ${currentHour}:${currentMinute}`);

    let states = ['0', '0', '0', '0', '0']; // חמישה תאים בקופסה

    for (const medication of patient.medications) {
        console.log(`💊 Checking medication: ${medication.name}`);
        console.log(`📅 Medication days: ${medication.days}`);
        if (medication.days.includes(currentDay)) {
            console.log(`✅ Medication ${medication.name} is valid for today`);
            for (const time of medication.times) {
                console.log(`⏰ Comparing time ${time.time} with now`);
                if (isTimeMatching(currentHour, currentMinute, time.time)) {
                    console.log(`🎯 Match found! Turning on slot ${medication.slotNumber}`);
                    states[medication.slotNumber - 1] = '1';
                }
            }
        }else {
            console.log(`⛔ Medication ${medication.name} is not scheduled for ${currentDay}`);
          }
    }

    console.log(`📦 Final LED states: ${states.join('')}`);
    console.log(`🌐 Pillbox IP: ${pillBox.ip}`); 
    return { states: states.join(''), ip: pillBox.ip };
};
module.exports = {
    addMedication,
    getMedicationsForPatientByDay,
    deleteMedication,
    updateMedication,
    getMedicationById,
    markAsTaken,
    getDueMedicationsStates,
    getMedicationsForPatient,
};
