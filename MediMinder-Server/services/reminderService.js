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
            const user = await User.findById(medication.patientId);
            if (!user) {
                console.warn(`⚠️ No user found for medication.patientId = ${medication.patientId}`);
                continue;
              }

            const patient = await Patient.findOne({ userId: user._id });
            if (!patient) {
                console.warn(`⚠️ No patient found for user ${user._id}`);
                continue;
              }
            
            console.log(`🔔 Sending reminder to patient ${user.name} for medication: ${medication.name}`);
            await patientService.sendPatientReminder(user._id, medication._id);  


            // שליחת תזכורות לכל המטפלים
            const caregivers = await patientService.getCaregiversForPatient(patient._id);
            if (caregivers && caregivers.length > 0) {
              await Promise.all(
                caregivers.map(caregiver =>
                  caregiverService.sendCaregiverReminder(
                    caregiver,
                    user._id,
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
