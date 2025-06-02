const axios = require('axios');
const { esp32Ip } = require('../config/espConfig'); 
const { getDueMedicationsStates } = require('../services/medicationsService');
const { sendLatePatientReminder } = require('../services/patientService');
const PillBox = require('../models/pillBoxModel');
const Medication = require('../models/medicationModel');
const Patient = require('../models/patientModel'); 

// שולחת פקודה ל-ESP – למשל: states=10000 תדליק את הלד הראשון
const sendLedCommand = async (ledStates, ip) => {
  try {
    const url = `${ip}/setLeds?states=${ledStates}`;
    const response = await axios.get(url);
    return response.data;
  } catch (error) {
    console.error('Failed to send command to ESP32:', error.message);
    throw new Error('ESP32 connection failed');
  }
};

// נקודת בדיקה פשוטה
const testLed = async (req, res) => {
  try {
    const result = await sendLedCommand("10000"); // לדליק לד ראשון בלבד
    res.json({ message: 'Command sent to ESP32', result });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
const reportMedicationTaken = (req, res) => {
  const { slotNumber, timestamp } = req.body;
  console.log(`💊 Medication taken in slot ${slotNumber} at ${timestamp}`);
  
  // כאן בעתיד אפשר לעדכן DB, לשלוח התראה וכו'
  res.status(200).json({ message: 'Medication taken received successfully' });
};

// הפעלת הדלקת נורות לפי תרופות רלוונטיות
const activateDueMedications = async (patientId) => {
  const result = await getDueMedicationsStates(patientId);
  const states = result.states;
  const ip = result.ip;
  console.log('🎯 Calculated LED states:', result);

  if (!states || states === '00000') {
    console.log('⚠️ No medications due right now.');
    return;
  }

  console.log(`💡 Activating LEDs with states: ${states}`);
  await sendLedCommand(states, ip);

};
const handleLateReminderAlert = async (req, res) => {
    try {
        const { slotNumber, macAddress } = req.body;

        if (!slotNumber || !macAddress) {
            return res.status(400).json({ message: 'Missing slotNumber or macAddress' });
        }
            // חיפוש קופסה לפי MAC
        const pillBox = await PillBox.findOne({ macAddress });
        if (!pillBox) {
            return res.status(404).json({ message: 'PillBox not found for MAC' });
        }

        const patientId = pillBox.patientId;
         // שליפת התרופה המתאימה
        const medication = await Medication.findOne({ patientId, slotNumber });
        if (!medication) {
            return res.status(404).json({ message: 'Medication not found for slot' });
        }
        // שליפת המטופל לצורך שליפת userId
        const patient = await Patient.findById(patientId);
        if (!patient) {
            return res.status(404).json({ message: 'Patient not found' });
        }
        const userId = patient.userId;

        await sendLatePatientReminder(userId, medication._id, true); // ← מצב תזכורת מאוחרת

        res.status(200).json({ message: 'Late reminder sent' });
    } catch (error) {
        console.error('❌ Error handling late reminder alert:', error);
        res.status(500).json({ message: error.message });
    }
};
const registerOrUpdatePillBox = async (req, res) => {
  try {
    const { macAddress, ip } = req.body;

    console.log(`🔌 MAC Address: ${macAddress}`);
    console.log(`🌐 IP Address: ${ip}`);

    if (!macAddress || !ip) {
      return res.status(400).json({ message: 'MAC or IP is missing' });
    }

    let pillBox = await PillBox.findOne({ macAddress });

    if (pillBox) {
      // case 1: MAC exists, update IP
      pillBox.ip = ip;
      await pillBox.save();
      return res.status(200).json({ message: 'Updated existing PillBox IP' });
    }

    // case 2: MAC not found, try to assign to one without MAC
    pillBox = await PillBox.findOne({ macAddress: null });
    if (pillBox) {
      pillBox.macAddress = macAddress;
      pillBox.ip = ip;
      await pillBox.save();
      return res.status(200).json({ message: 'MAC and IP assigned to existing PillBox' });
    }

    // case 3: No pillbox found (shouldn't happen)
    return res.status(404).json({ message: 'No unassigned PillBox found' });

  } catch (error) {
    console.error('❌ Error registering pillbox:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
module.exports = {
  testLed,
  sendLedCommand,
  reportMedicationTaken,
  activateDueMedications,
  handleLateReminderAlert,
  registerOrUpdatePillBox,
};
