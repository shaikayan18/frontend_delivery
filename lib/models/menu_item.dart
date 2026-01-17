// lib/models/menu_item.dart
class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final String image;
  final String category;
  final String? description;
  final bool available;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.description,
    this.available = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] ?? '',
      restaurantId: json['restaurant_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
      available: json['available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'description': description,
      'available': available,
    };
  }
}