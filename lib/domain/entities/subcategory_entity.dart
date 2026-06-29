class SubcategoryEntity {
  final String id;
  final String name;
  final String? categoryId;
  final String? imageUrl;

  SubcategoryEntity({
    required this.id,
    required this.name,
    this.categoryId,
    this.imageUrl,
  });
}
