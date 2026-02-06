import express from 'express';
const router = express.Router();
import { getUsers, updateUser, deleteUser, updateUserProfile } from '../controllers/userController.js';
import { protect, authorize } from '../middleware/authMiddleware.js';

router.route('/profile').put(protect, updateUserProfile);
router.route('/').get(protect, authorize('admin'), getUsers);
router.route('/:id')
    .put(protect, authorize('admin'), updateUser)
    .delete(protect, authorize('admin'), deleteUser);

export default router;
