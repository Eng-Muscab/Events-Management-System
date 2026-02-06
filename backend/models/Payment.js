import mongoose from 'mongoose';
// payment scheme creation
const paymentSchema = mongoose.Schema(
    {
        registration: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Registration',
            required: true,
        },
        amount: {
            type: Number,
            required: true,
        },
        paymentMethod: {
            type: String,
            required: true,
        },
        paymentStatus: {
            type: String,
            enum: ['pending', 'completed', 'failed'],
            default: 'pending',
        },
    },
    {
        timestamps: true,
    }
);

const Payment = mongoose.model('Payment', paymentSchema);

export default Payment;
