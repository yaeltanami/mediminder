const Medication = require('../models/medicationModel');
const Patient = require('../models/patientModel');

/**
 * הוספת תרופה למטופל ושמירתה במסד הנתונים.
 * התרופה מתווספת גם למערך התרופות של המטופל.
 *
 * @param {string} patientId - מזהה המטופל
 * @param {string} name - שם התרופה
 * @param {string} dose - מינון התרופה
 * @param {Array<string>} times - רשימת שעות נטילה
 * @param {number} slotNumber - מספר התא בקופסה (אם מוקצה)
 * @returns {Promise<object>} - מחזיר את התרופה שנוספה
 */
async function addMedication(patientId, name, dose, times, slotNumber) {
    try {
        // בדיקה אם המטופל קיים
        const patient = await Patient.findById(patientId);
        if (!patient) {
            throw new Error("Patient not found.");
        }

        // יצירת אובייקט תרופה חדש ושמירתו במסד הנתונים
        const newMedication = new Medication({ patientId, name, dose, times, slotNumber });
        const savedMedication = await newMedication.save();

        // הוספת התרופה למערך התרופות של המטופל
        await Patient.findByIdAndUpdate(patientId, {
            $push: { medications: savedMedication._id },
        });

        return savedMedication;
    } catch (error) {
        console.error('❌ Error adding medication:', error);
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

module.exports = {
    addMedication,
    getMedicationsForPatient
};
