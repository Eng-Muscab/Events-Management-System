import mongoose from 'mongoose';

const registrationSchema = mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true,
        },
        event: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Event',
            required: true,
        },
        status: {
            type: String,
            enum: ['registered', 'cancelled'],
            default: 'registered',
        },
        paymentStatus: {
            type: String,
            enum: ['pending', 'paid', 'failed'],
            default: 'pending',
        },
        amount: {
            type: Number,
            default: 0,
        },
        seats: {
            type: Number,
            required: true,
            default: 1,
        },
        attendeeDetails: {
            name: String,
            email: String,
            phone: String,
        },
        registeredAt: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: false, // Custom timestamp field used
    }
);

const Registration = mongoose.model('Registration', registrationSchema);

export default Registration;
