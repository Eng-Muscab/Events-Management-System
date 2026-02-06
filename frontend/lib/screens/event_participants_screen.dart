import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event.dart';
import '../providers/registration_provider.dart';
import '../utils/constants.dart';

class EventParticipantsScreen extends StatefulWidget {
  final Event event;
  const EventParticipantsScreen({super.key, required this.event});

  @override
  State<EventParticipantsScreen> createState() => _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegistrationProvider>(context, listen: false).fetchEventParticipants(widget.event.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String val) {
    Provider.of<RegistrationProvider>(context, listen: false).fetchEventParticipants(widget.event.id, search: val);
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    final participants = registrationProvider.eventParticipants;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Summary Header (Clean sub-header)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FF),
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat('Booked', '${widget.event.registrationCount}'),
                    _buildStat('Capacity', '${widget.event.capacity}'),
                    _buildStat('Remaining', '${widget.event.capacity - widget.event.registrationCount}', color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Search by name or phone',
                  hintStyle: TextStyle(fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Participants List
          Expanded(
            child: registrationProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : participants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text('No bookings found for this event', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: participants.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final reg = participants[index];
                          // Read fields safely from populated user object or fallback to attendeeDetails
                          final userName = reg.user?.name ?? reg.attendeeDetails?['name']?.toString() ?? 'Unknown User';
                          final userEmail = reg.user?.email ?? reg.attendeeDetails?['email']?.toString() ?? 'No email';
                          final bool isPaid = reg.paymentStatus == 'paid';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                    ),
                                  ),
                                  _buildStatusBadge(isPaid),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildInfoChip(Icons.chair_alt, '${reg.seats} Seats'),
                                      const SizedBox(width: 8),
                                      _buildInfoChip(Icons.payments_outlined, '\$${reg.amount.toStringAsFixed(0)}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusBadge(bool isPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? 'PAID' : 'PENDING',
        style: TextStyle(
          color: isPaid ? Colors.green[700] : Colors.orange[700],
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
