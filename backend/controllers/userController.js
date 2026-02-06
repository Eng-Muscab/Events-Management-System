import User from '../models/User.js';

// @desc    Get all users
// @route   GET /api/users
// @access  Private/Admin
const getUsers = async (req, res, next) => {
    try {
        const users = await User.find({});
        res.json(users);
    } catch (error) {
        next(error);
    }
};

// @desc    Update user
// @route   PUT /api/users/:id
// @access  Private/Admin
const updateUser = async (req, res, next) => {
    try {
        const user = await User.findById(req.params.id);

        if (user) {
            user.name = req.body.name || user.name;
            user.email = req.body.email || user.email;
            user.role = req.body.role || user.role;
            if (req.body.password) {
                user.password = req.body.password;
            }

            const updatedUser = await user.save();
            res.json({
                _id: updatedUser._id,
                name: updatedUser.name,
                email: updatedUser.email,
                role: updatedUser.role,
            });
        } else {
            res.status(404);
            throw new Error('User not found');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Delete user
// @route   DELETE /api/users/:id
// @access  Private/Admin
const deleteUser = async (req, res, next) => {
    try {
        const user = await User.findById(req.params.id);

        if (user) {
            await user.deleteOne();
            res.json({ message: 'User removed' });
        } else {
            res.status(404);
            throw new Error('User not found');
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = async (req, res, next) => {
    try {
        if (!req.user) {
            res.status(401);
            throw new Error('Not authorized');
        }

        // Fetch full user doc including password to avoid exclusion issues during save
        const user = await User.findById(req.user._id);

        if (user) {
            // Check if email is already taken by another user
            if (req.body.email && req.body.email !== user.email) {
                const userExists = await User.findOne({ email: req.body.email });
                if (userExists) {
                    res.status(400);
                    throw new Error('Email already in use');
                }
            }

            user.name = req.body.name || user.name;
            user.email = req.body.email || user.email;

            if (req.body.password && req.body.password.trim() !== '') {
                user.password = req.body.password;
            }

            const updatedUser = await user.save();

            res.json({
                _id: updatedUser._id,
                name: updatedUser.name,
                email: updatedUser.email,
                role: updatedUser.role,
            });
        } else {
            res.status(404);
            throw new Error('User not found');
        }
    } catch (error) {
        console.error('Update Profile Error:', error);
        if (error.code === 11000) {
            res.status(400);
            next(new Error('Email already exists'));
        } else {
            next(error);
        }
    }
};

export { getUsers, updateUser, deleteUser, updateUserProfile };
