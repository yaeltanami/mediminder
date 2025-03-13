const userService = require('../services/userService');

const registerUser = async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        const { user, token } = await userService.registerUser(name, email, password, role);
        res.status(201).json({ user, token });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;
        const { user, token } = await userService.loginUser(email, password);
        res.status(200).json({ user, token });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = { registerUser, loginUser };
