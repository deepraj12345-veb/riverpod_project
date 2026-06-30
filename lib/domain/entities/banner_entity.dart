class BannerEntity {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String link;
  final String isActive;
  final int sortOrder;

  const BannerEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.link,
    required this.isActive,
    required this.sortOrder,
  });
}
