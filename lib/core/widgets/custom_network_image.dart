import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.color,
    this.colorBlendMode,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildErrorWidget(context);
    }

    final finalUrl = imageUrl.startsWith('http')
        ? imageUrl
        : 'https://vegimart-backend.vercel.app$imageUrl';

    return Image.network(
      finalUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: Container(color: Colors.white),
            );
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildErrorWidget(context),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.bgLight,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppTheme.textGrey, size: 24),
      ),
    );
  }
}
