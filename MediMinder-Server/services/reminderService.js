const cron = require('node-cron');
const Medication = require('../models/medicationModel');
const Patient = require('../models/patientModel');
const patientService = require('./patientService');
const caregiverService = require('./caregiverService');
const User = require('../models/userModel');
const { activateDueMedications } = require('../controllers/espController');



/**
 * Sends reminders to patients who need to take medication at the current time.
 */
const sendMedicationReminders = async () => {
    try {
        const currentTime = new Date();
        const currentHourMinute = `${currentTime.getHours().toString().padStart(2, '0')}:${currentTime.getMinutes().toString().padStart(2, '0')}`;
        const currentDay = currentTime.toLocaleDateString('en-US', { weekday: 'long' }); 

        console.log(`🔎 Checking for medication reminders at: ${currentHourMinute} and ${currentDay}`);

        // Find all medications that should be taken at this time
        const medications = await Medication.find({
            "times.time": currentHourMinute,
            days: currentDay
          });

        if (!medications || !Array.isArray(medications)) {
             console.log("⏩ No valid medications found for this time, skipping reminders.");
             return;
        }
        for (const medication of medications) { 
            const patient = await Patient.findOne({ userId: medication.patientId });
            if (!patient) {
                console.warn(`⚠️ No patient found for user ${patient.userId}`);
                continue;
              }
            
            console.log(`🔔 Sending reminder to patient ${patient.userId} for medication: ${medication.name}`);
            await patientService.sendPatientReminder(patient.userId, medication._id);  


            // שליחת תזכורות לכל המטפלים
            const caregivers = await patientService.getCaregiversForPatient(patient._id);
            if (caregivers && caregivers.length > 0) {
              await Promise.all(
                caregivers.map(caregiver =>
                  caregiverService.sendCaregiverReminder(
                    caregiver,
                    patient.userId,
                    medication
                  )
                )
              );
              console.log(`📣 Reminder also sent to ${caregivers.length} caregiver(s)`);
            } else {
              console.log(`ℹ️ No caregivers found for patient ${patient._id}`);
            }
            await activateDueMedications(patient._id);

        }
    } catch (error) {
        console.error('❌ Error sending medication reminders:', error);
    }
};

// Schedule the function to run every minute
cron.schedule('* * * * *', () => {
    sendMedicationReminders();
    console.log("📅 Medication reminder service is running...");
});

module.exports = { sendMedicationReminders };
