class CategoryEntity {
  final String id;
  final String name;
  final String? typeId;
  final String? imageUrl;

  CategoryEntity({
    required this.id,
    required this.name,
    this.typeId,
    this.imageUrl,
  });
}
