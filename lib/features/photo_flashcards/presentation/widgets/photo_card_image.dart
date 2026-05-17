import 'dart:io';

import 'package:flutter/material.dart';

class PhotoCardImage extends StatelessWidget {
  const PhotoCardImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.borderRadius = 10,
    this.cacheWidth,
  });

  final String? path;
  final BoxFit fit;
  final double borderRadius;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final imagePath = path;
    final radius = BorderRadius.circular(borderRadius);
    if (imagePath == null || imagePath.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: radius,
        ),
        child: const Center(child: Icon(Icons.image_outlined)),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.file(
        File(imagePath),
        fit: fit,
        cacheWidth: cacheWidth,
        errorBuilder: (_, __, ___) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: radius,
          ),
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }
}
