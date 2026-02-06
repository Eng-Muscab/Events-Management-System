import Payment from '../models/Payment.js';

// @desc    Create payment
// @route   POST /api/payments
// @access  Private
const createPayment = async (req, res, next) => {
    try {
        const { registrationId, amount, paymentMethod } = req.body;

        const payment = await Payment.create({
            registration: registrationId,
            amount,
            paymentMethod,
            paymentStatus: 'completed', // Mocking success
        });

        res.status(201).json(payment);
    } catch (error) {
        next(error);
    }
};

export { createPayment };