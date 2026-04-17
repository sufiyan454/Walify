import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallpaper_model.dart';
import '../../domain/entities/wallpaper_entity.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_wallpapers';

  Future<List<WallpaperEntity>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString(_favoritesKey);

    if (favoritesString != null) {
      final List<dynamic> decoded = json.decode(favoritesString);
      return decoded.map((json) => WallpaperModel.fromLocalJson(json)).toList();
    }
    return [];
  }

  Future<void> saveFavorites(List<WallpaperEntity> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mappedList = favorites.map((e) {
      return WallpaperModel(
        id: e.id,
        imageUrl: e.imageUrl,
        thumbnailUrl: e.thumbnailUrl,
        category: e.category,
        photographer: e.photographer,
      ).toJson();
    }).toList();

    await prefs.setString(_favoritesKey, json.encode(mappedList));
  }
}
