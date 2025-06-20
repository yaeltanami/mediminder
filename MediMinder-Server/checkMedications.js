const mongoose = require('mongoose');
const Medication = require('./models/medicationModel');

async function checkAllMedications() {
    try {
        await mongoose.connect('mongodb://127.0.0.1:27017/MediMinder');
        console.log('Connected to MongoDB');

        const medications = await Medication.find({});
        console.log(`Found ${medications.length} medications:`);

        // medications.forEach(med => {
        //     console.log(`----------------------------------`);
        //     console.log(` Name: ${med.name}`);
        //     console.log(` Slot: ${med.slotNumber}`);
        //     console.log(` Times: ${med.times.map(t => t.time).join(', ')}`);
        //     console.log(` Days: ${med.days.join(', ')}`);
        // });

        await mongoose.disconnect();
        console.log('Disconnected from MongoDB');
    } catch (err) {
        console.error('Error checking medications:', err);
    }
}

checkAllMedications();
