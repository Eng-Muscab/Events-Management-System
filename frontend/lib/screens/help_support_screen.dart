import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help & Support',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Welcome to EventMaster',
              content: 'Our application is designed to bridge the gap between organizers and attendees, making event management and participation seamless and efficient.',
            ),
            _buildSection(
              title: 'What is this app used for?',
              content: 'EventMaster allows users to discover exciting events in their city, join conferences, workshops, and concerts. Organizers can manage events, track registrations, and engage with their audience.',
            ),
            _buildSection(
              title: 'How to register for an event?',
              content: '1. Navigate to the Home tab.\n2. Tap on any event that interests you.\n3. Fill in your details (Full Name, Email, Phone).\n4. Proceed to Checkout and select your payment method.\n5. Once confirmed, you can find your ticket in "My Bookings".',
            ),
            _buildSection(
              title: 'Contact Support',
              content: 'If you encounter any issues or have questions, please feel free to reach out to our dedicated support team.',
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildContactItem(Icons.email_outlined, 'support@eventmaster.com'),
                  const SizedBox(height: 16),
                  _buildContactItem(Icons.phone_outlined, '+1 (555) 000-1234'),
                  const SizedBox(height: 16),
                  _buildContactItem(Icons.language_outlined, 'www.eventmaster.com'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
