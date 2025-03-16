const Patient = require('../models/patientModel');
const PillBox = require('../models/pillBoxModel');
const userService = require('./userService');
const pillBoxService = require('./pillBoxService');



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

module.exports = { registerPatient };
