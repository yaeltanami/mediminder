const Medication = require('../models/medicationModel');

// הוספת תרופה למטופל אחד
async function addMedication(patientId, name, dose, times, slotNumber) {
    try {
        const newMedication = new Medication({
            patientId,
            name,
            dose,
            times,
            slotNumber
        });

        const savedMedication = await newMedication.save();  // שומר את התרופה במסד הנתונים
        return savedMedication;  // מחזיר את התרופה שנוספה
    } catch (error) {
        console.error('Error adding medication:', error);
        throw error;
    }
}

module.exports = {
    addMedication}
