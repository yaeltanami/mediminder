const axios = require('axios');
const { esp32Ip } = require('../config/espConfig'); 
const { getDueMedicationsStates } = require('../services/medicationsService');


// שולחת פקודה ל-ESP – למשל: states=10000 תדליק את הלד הראשון
const sendLedCommand = async (ledStates) => {
  try {
    const url = `${esp32Ip}/setLeds?states=${ledStates}`;
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
  const states = await getDueMedicationsStates(patientId);
  console.log('🎯 Calculated LED states:', states);

  if (!states || states === '00000') {
    console.log('⚠️ No medications due right now.');
    return;
  }

  console.log(`💡 Activating LEDs with states: ${states}`);
  await sendLedCommand(states);
  
};

module.exports = {
  testLed,
  sendLedCommand,
  reportMedicationTaken,
  activateDueMedications,
};
