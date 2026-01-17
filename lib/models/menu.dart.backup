class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final String image;
  final String category;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'],
      restaurantId: json['restaurant_id'],
      name: json['name'],
      price: (json['price']).toDouble(),
      image: json['image'] ?? 'https://via.placeholder.com/150',
      category: json['category'] ?? 'Main Course',
    );
  }
}