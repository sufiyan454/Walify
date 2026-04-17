import 'package:flutter/material.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../../data/services/local_storage_service.dart';

class FavoritesProvider with ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();
  
  List<WallpaperEntity> _favorites = [];
  
  List<WallpaperEntity> get favorites => _favorites;

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _favorites = await _localStorageService.getFavorites();
    notifyListeners();
  }

  bool isFavorite(WallpaperEntity wallpaper) {
    return _favorites.any((fav) => fav.id == wallpaper.id);
  }

  Future<void> toggleFavorite(WallpaperEntity wallpaper) async {
    if (isFavorite(wallpaper)) {
      _favorites.removeWhere((fav) => fav.id == wallpaper.id);
    } else {
      _favorites.add(wallpaper);
    }
    
    notifyListeners();
    await _localStorageService.saveFavorites(_favorites);
  }
}
