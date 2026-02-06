class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final int capacity;
  final String categoryName;
  final String organizerName;
  final double price;
  final int registrationCount;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.capacity,
    required this.categoryName,
    required this.organizerName,
    this.price = 0.0,
    this.registrationCount = 0,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      date: json['date'] ?? DateTime.now().toIso8601String(),
      time: json['time'] ?? '00:00',
      location: json['location'] ?? 'Online',
      capacity: json['capacity'] ?? 0,
      categoryName: (json['category'] != null && json['category'] is Map) ? (json['category']['name'] ?? 'General') : 'General',
      organizerName: (json['organizer'] != null && json['organizer'] is Map) ? (json['organizer']['name'] ?? 'Organizer') : 'Organizer',
      price: (json['price'] ?? 0.0).toDouble(),
      registrationCount: json['registrationCount'] ?? 0,
    );
  }
}
