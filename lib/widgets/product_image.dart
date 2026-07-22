import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  final Uint8List? imageBytes;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    this.imageBytes,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, width: width, height: height, fit: fit, errorBuilder: _errorBuilder);
    }
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: _errorBuilder,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _placeholder();
      },
    );
  }

  Widget _errorBuilder(BuildContext ctx, Object e, StackTrace? st) => _placeholder();

  Widget _placeholder() => Container(
    width: width,
    height: height,
    color: kDarkSurface,
    child: const Center(child: Icon(Icons.image_not_supported_outlined, color: kTextMuted, size: 32)),
  );
}
