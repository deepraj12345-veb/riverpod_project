class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final List<String> tags;
  final bool inStock;
  final String unit;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
    this.tags = const [],
    this.inStock = true,
    this.unit = '1 piece',
  });

  double get discountPercent =>
      ((originalPrice - price) / originalPrice * 100).roundToDouble();

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? category,
    double? rating,
    int? reviewCount,
    bool? isFavorite,
    List<String>? tags,
    bool? inStock,
    String? unit,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      inStock: inStock ?? this.inStock,
      unit: unit ?? this.unit,
    );
  }
}

