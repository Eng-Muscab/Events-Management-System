import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/registration_provider.dart';
import '../utils/constants.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegistrationProvider>(context, listen: false).fetchRegistrations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    final registrations = registrationProvider.registrations;

    if (registrationProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            'My Bookings',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: registrations.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No bookings yet',
                      style: GoogleFonts.inter(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: registrations.length,
                itemBuilder: (context, index) {
                  final booking = registrations[index];
                  final event = booking.event;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Event Image Section
                        if (event != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              image: const DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1492684223066-81342ee5ff30?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                   Expanded(
                                     child: Text(
                                      event?.title ?? 'Unknown Event',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                   ),
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.end,
                                     children: [
                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(
                                           color: booking.status == 'registered' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                         child: Text(
                                           booking.status.toUpperCase(),
                                           style: TextStyle(
                                             fontSize: 10,
                                             fontWeight: FontWeight.bold,
                                             color: booking.status == 'registered' ? Colors.green : Colors.red,
                                           ),
                                         ),
                                       ),
                                       const SizedBox(height: 4),
                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(
                                           color: booking.paymentStatus == 'paid' ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                         child: Text(
                                           booking.paymentStatus.toUpperCase(),
                                           style: TextStyle(
                                             fontSize: 10,
                                             fontWeight: FontWeight.bold,
                                             color: booking.paymentStatus == 'paid' ? Colors.blue : Colors.orange,
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (event != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(DateTime.parse(event.date)),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.time,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.location,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                if (booking.paymentStatus == 'pending') ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await Provider.of<RegistrationProvider>(context, listen: false).payForRegistration(booking.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: $e')));
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                      child: Text('Pay \$${booking.amount.toStringAsFixed(0)} Now'),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
