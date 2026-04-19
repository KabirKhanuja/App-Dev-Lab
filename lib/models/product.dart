class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
    );
  }
}
