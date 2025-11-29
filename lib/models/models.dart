class User {
  final int id;
  final String username;
  User({required this.id, required this.username});
  factory User.fromJson(Map<String, dynamic> json) => User(id: json['id'], username: json['username']);
}

class Delivery {
  final int id;
  final String destination_address;
  final String recipient;
  final bool delivered;
  final double? lat;
  final double? lon;
  final String? photo_path;

  Delivery({
    required this.id,
    required this.destination_address,
    required this.recipient,
    required this.delivered,
    this.lat,
    this.lon,
    this.photo_path,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      destination_address: json['destination_address'],
      recipient: json['recipient'] ?? '',
      delivered: json['delivered'] ?? false,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lon: json['lon'] != null ? (json['lon'] as num).toDouble() : null,
      photo_path: json['photo_path'],
    );
  }
}
