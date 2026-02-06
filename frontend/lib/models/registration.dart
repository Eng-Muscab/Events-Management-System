import '../models/event.dart';
import '../models/user.dart';

class Registration {
  final String id;
  final String status;
  final String paymentStatus;
  final double amount;
  final int seats;
  final String registeredAt;
  final Event? event;
  final User? user;
  final Map<String, dynamic>? attendeeDetails;
  final String? userName;
  final String? userEmail;

  Registration({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.amount,
    required this.seats,
    required this.registeredAt,
    this.event,
    this.user,
    this.attendeeDetails,
    this.userName,
    this.userEmail,
  });

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      amount: (json['amount'] ?? 0.0).toDouble(),
      seats: json['seats'] ?? 1,
      registeredAt: json['registeredAt'] ?? DateTime.now().toIso8601String(),
      event: json['event'] != null && json['event'] is Map ? Event.fromJson(json['event']) : null,
      user: json['user'] != null && json['user'] is Map ? User.fromJson(json['user']) : null,
      attendeeDetails: json['attendeeDetails'],
      userName: json['user'] != null && json['user'] is Map ? json['user']['name'] : null,
      userEmail: json['user'] != null && json['user'] is Map ? json['user']['email'] : null,
    );
  }
}
