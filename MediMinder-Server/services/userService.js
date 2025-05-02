const jwt = require('jsonwebtoken'); 
const User = require('../models/userModel');
const Patient = require('../models/patientModel');
const Caregiver = require('../models/caregiverModel');
const Medication = require('../models/medicationModel');
const PillBox = require('../models/pillBoxModel');

/**
 * רישום משתמש חדש למערכת
 */
const registerUser = async ({ name, email, password, role }) => {
    const existingUser = await User.findOne({ email });
    if (existingUser) throw new Error('User already exists');

    // ודא שכל הנתונים מועברים בצורה תקינה
    if (!name || !email || !password || !role) {
        throw new Error('All user fields are required.');
    }

    const user = new User({ name, email, password, role });

    // שמירה במסד הנתונים
    await user.save();

    // הפיכת המשתמש לאובייקט רגיל והסרת הסיסמה
    const sanitizedUser = user.toObject();
    delete sanitizedUser.password;

    return sanitizedUser;
};


/**
 * התחברות משתמש למערכת
 */
const loginUser = async (email, password) => {
    const user = await User.findOne({ email });
    if (!user) throw new Error('Invalid credentials');

    // השוואת הסיסמה באמצעות `bcrypt`
    const isMatch = await user.matchPassword(password);
    if (!isMatch) throw new Error('Invalid credentials');

    // יצירת טוקן JWT
    const token = generateToken(user._id, user.role);

 // הסרת הסיסמה מהאובייקט שנשלח ללקוח
    const sanitizedUser = user.toObject();
    delete sanitizedUser.password;
    return { user: sanitizedUser, token };
};

/**
 * פונקציה ליצירת טוקן JWT
 */
const generateToken = (userId, role) => {
    return jwt.sign({ userId, role }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

/**
 * מחיקת משתמש מהמערכת
 * אם המשתמש מטופל - מוחקים את קופסת התרופות והתרופות שלו
 * אם המשתמש מטפל - מוחקים אותו מכל רשימות המטופלים שלו
 *
 * @param {string} userId - מזהה המשתמש למחיקה
 * @returns {Promise<object>} - הודעה על מחיקה מוצלחת
 */
const deleteUser = async (userId) => {
    try {
        // שליפת המשתמש
        const user = await User.findById(userId);
        if (!user) throw new Error("User not found.");

        if (user.role === 'patient') {
            // מחיקת המטופל ממסד הנתונים
            const patient = await Patient.findOne({ userId });
            if (patient) {
                // מחיקת כל התרופות של המטופל
                await Medication.deleteMany({ patientId: patient._id });

                // מחיקת קופסת התרופות של המטופל
                await PillBox.deleteOne({ patientId: patient._id });

                // הסרת המטופל מכל המטפלים
                await Caregiver.updateMany(
                    { patients: patient._id },
                    { $pull: { patients: patient._id } }
                );

                // מחיקת המטופל ממסד הנתונים
                await Patient.deleteOne({ userId });
            }
        } else if (user.role === 'caregiver') {
            // מחיקת המטפל מכל המטופלים שהוא קשור אליהם
            await Patient.updateMany(
                { caregivers: userId },
                { $pull: { caregivers: userId } }
            );

            // מחיקת המטפל ממסד הנתונים
            await Caregiver.deleteOne({ userId });
        }

        // מחיקת המשתמש ממסד הנתונים
        await User.findByIdAndDelete(userId);

        console.log(`🗑️ User ${user.name} was successfully deleted`);
        return { message: "User deleted successfully" };
    } catch (error) {
        console.error("❌ Error deleting user:", error);
        throw error;
    }
};

const saveFcmToken = async (userId, fcmToken) => {
    if (!fcmToken) {
      throw new Error('Missing FCM token');
    }
  
    const user = await User.findById(userId); 
    if (!user) {
      throw new Error('User not found');
    }
  
    user.fcmToken = fcmToken;
    await user.save();
  
    return user;
  };

  const removeFcmToken = async (userId) => {
    const user = await User.findById(userId);
    if (!user) {
      throw new Error('User not found');
    }
  
    user.fcmToken = null;
    await user.save();
  };

  /**
 * מחזירה את מזהה המטופל (Patient._id) לפי מזהה משתמש (User._id)
 * @param {string} userId - מזהה המשתמש
 * @returns {Promise<string>} - מזהה המטופל (Patient._id)
 */
const getPatientIdByUserId = async (userId) => {
    const patient = await Patient.findOne({ userId });
  
    if (!patient) {
      throw new Error('Patient not found for the given user ID');
    }
  
    return patient._id;
  };
  
  

module.exports = { registerUser, loginUser, generateToken, deleteUser, saveFcmToken, removeFcmToken, getPatientIdByUserId };
