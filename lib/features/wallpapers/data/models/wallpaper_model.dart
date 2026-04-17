import '../../domain/entities/wallpaper_entity.dart';

class WallpaperModel extends WallpaperEntity {
  WallpaperModel({
    required super.id,
    required super.imageUrl,
    required super.thumbnailUrl,
    required super.category,
    required super.photographer,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json, String category) {
    return WallpaperModel(
      id: json['id'].toString(),
      imageUrl: json['urls'] != null ? json['urls']['full'] ?? json['urls']['regular'] ?? '' : '',
      thumbnailUrl: json['urls'] != null ? json['urls']['small'] ?? json['urls']['thumb'] ?? '' : '',
      photographer: json['user'] != null ? json['user']['name'] ?? 'Unknown' : 'Unknown',
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'photographer': photographer,
    };
  }

  factory WallpaperModel.fromLocalJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'].toString(),
      imageUrl: json['imageUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      photographer: json['photographer'] ?? 'Unknown',
      category: json['category'] ?? '',
    );
  }
}
