class MenuItem {
  final String id;
  final String name;
  final String route;
  final String icon;

  MenuItem({
    required this.id,
    required this.name,
    required this.route,
    required this.icon,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'],
      name: json['name'],
      route: json['route'],
      icon: json['icon'],
    );
  }
}
