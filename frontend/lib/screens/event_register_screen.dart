import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../utils/constants.dart';
import '../widgets/custom_widgets.dart';
import '../providers/auth_provider.dart';
import '../providers/registration_provider.dart';
import 'checkout_screen.dart';
import 'package:intl/intl.dart';

class EventRegisterScreen extends StatefulWidget {
  final Event event;
  const EventRegisterScreen({super.key, required this.event});

  @override
  State<EventRegisterScreen> createState() => _EventRegisterScreenState();
}

class _EventRegisterScreenState extends State<EventRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  int _selectedSeats = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegistrationProvider>(context, listen: false).fetchRegistrations();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    
    final bool alreadyRegistered = registrationProvider.registrations.any((reg) => reg.event?.id == widget.event.id);
    final int remainingSeats = widget.event.capacity - widget.event.registrationCount;
    final bool isCapacityReached = remainingSeats <= 0;
    final bool isUser = user?.role == 'user';
    
    final bool canRegisterSeats = _selectedSeats <= remainingSeats;
    final bool isValidToRegister = isUser && !isCapacityReached && !alreadyRegistered && canRegisterSeats;

    String buttonText = 'Proceed to Payment';
    if (!isUser) {
      buttonText = 'Only Users can Register';
    } else if (alreadyRegistered) {
      buttonText = 'Already Registered';
    } else if (isCapacityReached) {
      buttonText = 'Capacity Reached';
    } else if (!canRegisterSeats) {
      buttonText = 'Not Enough Seats';
    }

    final double totalPrice = widget.event.price * _selectedSeats;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Register',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 24),
             if (alreadyRegistered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You are already registered for this event.',
                        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
             if (isCapacityReached && !alreadyRegistered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Event capacity has been reached.',
                        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              'Event Summary',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9EAF5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1540575467063-178a50c2df87?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('EEE, MMM dd, yyyy').format(DateTime.parse(widget.event.date))} · ${widget.event.time}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${widget.event.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Price per seat', style: TextStyle(color: Colors.grey)),
              ],
            ),
             const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$remainingSeats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: remainingSeats < 10 ? Colors.red : Colors.green)),
                const Text('Seats available', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Registration Details',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomTextField(label: 'Full Name', controller: _nameController, hintText: 'Enter your full name'),
            const SizedBox(height: 16),
            CustomTextField(label: 'Email', controller: _emailController, hintText: 'Enter your email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            CustomTextField(label: 'Phone Number', controller: _phoneController, hintText: 'Enter your phone number', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            
            // Seat Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Number of Seats', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EAF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedSeats,
                      isExpanded: true,
                      items: List.generate(remainingSeats > 0 ? (remainingSeats > 10 ? 10 : remainingSeats) : 1, (index) => index + 1)
                          .map((val) => DropdownMenuItem<int>(value: val, child: Text('$val Seats')))
                          .toList(),
                      onChanged: alreadyRegistered ? null : (val) {
                        if (val != null) setState(() => _selectedSeats = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Total Price Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\$${totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isValidToRegister ? () {
                  if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        event: widget.event,
                        attendeeName: _nameController.text,
                        attendeeEmail: _emailController.text,
                        attendeePhone: _phoneController.text,
                        seats: _selectedSeats,
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidToRegister ? AppColors.primary : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
