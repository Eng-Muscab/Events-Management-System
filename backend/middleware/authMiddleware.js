import jwt from 'jsonwebtoken';
import User from '../models/User.js';

const protect = async (req, res, next) => {
    let token;

    if (
        req.headers.authorization &&
        req.headers.authorization.startsWith('Bearer')
    ) {
        try {
            token = req.headers.authorization.split(' ')[1];

            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            req.user = await User.findById(decoded.id).select('-password');

            if (!req.user) {
                res.status(401);
                throw new Error('Not authorized, user not found');
            }

            next();
        } catch (error) {
            console.error(error);
            const status = res.statusCode === 200 ? 401 : res.statusCode;
            res.status(status);
            next(error);
        }
    }

    if (!token) {
        res.status(401);
        return next(new Error('Not authorized, no token'));
    }
};

const authorize = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            res.status(401);
            throw new Error('User not authenticated');
        }
        if (!roles.includes(req.user.role)) {
            res.status(403);
            throw new Error(`User role ${req.user.role} is not authorized to access this route`);
        }
        next();
    };
};

export { protect, authorize };
