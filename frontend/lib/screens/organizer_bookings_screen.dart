import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/registration_provider.dart';
import '../utils/constants.dart';

class OrganizerBookingsScreen extends StatefulWidget {
  const OrganizerBookingsScreen({super.key});

  @override
  State<OrganizerBookingsScreen> createState() => _OrganizerBookingsScreenState();
}

class _OrganizerBookingsScreenState extends State<OrganizerBookingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegistrationProvider>(context, listen: false).fetchOrganizerRegistrations();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    final bookings = registrationProvider.organizerRegistrations
        .where((reg) {
          final attendeeName = reg.user?.name.toLowerCase() ?? reg.attendeeDetails?['name']?.toString().toLowerCase() ?? '';
          final attendeePhone = reg.attendeeDetails?['phone']?.toString().toLowerCase() ?? '';
          final eventTitle = reg.event?.title.toLowerCase() ?? '';
          return attendeeName.contains(_searchQuery) || 
                 attendeePhone.contains(_searchQuery) ||
                 eventTitle.contains(_searchQuery);
        })
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Booked Users',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: null,
        automaticallyImplyLeading: false, // Clean look as requested
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search by name or phone',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: registrationProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No bookings found',
                                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: bookings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            final event = booking.event;
                            
                            // Safely read user data from populated object
                            final displayName = booking.user?.name ?? booking.attendeeDetails?['name']?.toString() ?? 'Unknown User';
                            final displayEmail = booking.user?.email ?? booking.attendeeDetails?['email']?.toString() ?? 'No email';
                            final displayPhone = booking.attendeeDetails?['phone']?.toString();

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayName,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                      _buildStatusBadge(booking.paymentStatus),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        displayEmail,
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  if (displayPhone != null && displayPhone.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          displayPhone,
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Divider(height: 30),
                                  Text(
                                    'Event Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[400],
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    event?.title ?? 'Unknown Event',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Seats', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                          Text(
                                            '${booking.seats} Booked',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text('Total Paid', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                          Text(
                                            '\$${booking.amount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isPaid = status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isPaid ? Colors.green[700] : Colors.orange[700],
        ),
      ),
    );
  }
}
