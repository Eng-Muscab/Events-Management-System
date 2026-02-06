import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/registration_provider.dart';
import '../utils/constants.dart';
import 'main_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Event event;
  final String attendeeName;
  final String attendeeEmail;
  final String attendeePhone;
  final int seats;

  const CheckoutScreen({
    super.key,
    required this.event,
    required this.attendeeName,
    required this.attendeeEmail,
    required this.attendeePhone,
    this.seats = 1,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'card';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final double subtotal = widget.event.price * widget.seats;
    final double total = subtotal;

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
              'Checkout',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 32),
            Text(
              'Payment Method',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPaymentMethod('card', 'Credit/Debit Card', Icons.credit_card),
            const SizedBox(height: 12),
            _buildPaymentMethod('upi', 'UPI', Icons.account_balance_wallet_outlined),
            const SizedBox(height: 12),
            _buildPaymentMethod('wallet', 'Digital Wallets', Icons.account_balance_wallet),
            const SizedBox(height: 40),
            Text(
              'Order Summary',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSummaryRow('Booked Seats', '${widget.seats}'),
            const SizedBox(height: 12),
            _buildSummaryRow('Seat Price', '\$${widget.event.price.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildSummaryRow('Total Amount', '\$${total.toStringAsFixed(2)}', isTotal: true),
            const SizedBox(height: 100), // Push button down
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String value, String label, IconData icon) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE9EAF5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : Colors.grey, width: 2),
              ),
              child: isSelected ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary))) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 15,
            color: isTotal ? Colors.black : Colors.grey[600],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    try {
      final provider = Provider.of<RegistrationProvider>(context, listen: false);
      await provider.registerForEvent(widget.event.id, {
        'name': widget.attendeeName,
        'email': widget.attendeeEmail,
        'phone': widget.attendeePhone,
        'seats': widget.seats,
        'paymentMethod': _selectedMethod,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Registration successful!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
