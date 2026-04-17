import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../domain/entities/wallpaper_entity.dart';

class WallpaperCard extends StatelessWidget {
  final WallpaperEntity wallpaper;
  final VoidCallback onTap;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: wallpaper.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: wallpaper.thumbnailUrl.startsWith('assets/')
            ? Image.asset(wallpaper.thumbnailUrl, fit: BoxFit.cover)
            : CachedNetworkImage(
            imageUrl: wallpaper.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[850]!,
              highlightColor: Colors.grey[800]!,
              child: Container(color: Colors.black),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
