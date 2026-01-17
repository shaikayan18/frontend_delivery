// lib/models/restaurant.dart
class Restaurant {
  final String id;
  final String name;
  final String image;
  final double rating;

  Restaurant({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}