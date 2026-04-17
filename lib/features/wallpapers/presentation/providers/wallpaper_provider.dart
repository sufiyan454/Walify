import 'package:flutter/material.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../../data/services/wallpaper_api_service.dart';

class WallpaperProvider with ChangeNotifier {
  final WallpaperApiService _apiService = WallpaperApiService();
  
  final List<WallpaperEntity> _wallpapers = [];
  bool _isLoading = false;
  String _error = '';
  int _currentPage = 1;
  String _currentQuery = 'Nature';
  bool _hasMore = true;

  List<WallpaperEntity> get wallpapers => _wallpapers;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;
  String get currentQuery => _currentQuery;

  Future<void> fetchWallpapers(String query, {bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _wallpapers.clear();
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _currentQuery = query;
    _error = '';
    
    Future.microtask(() => notifyListeners());

    if (_currentQuery == 'Premium Offline') {
      _wallpapers.clear();
      _wallpapers.addAll([
        WallpaperEntity(id: 'off_1', imageUrl: 'assets/images/nature_offline.png', thumbnailUrl: 'assets/images/nature_offline.png', category: 'Premium Offline', photographer: 'AI Generator'),
        WallpaperEntity(id: 'off_2', imageUrl: 'assets/images/anime_offline.png', thumbnailUrl: 'assets/images/anime_offline.png', category: 'Premium Offline', photographer: 'AI Generator'),
        WallpaperEntity(id: 'off_3', imageUrl: 'assets/images/car_offline.png', thumbnailUrl: 'assets/images/car_offline.png', category: 'Premium Offline', photographer: 'AI Generator'),
        WallpaperEntity(id: 'off_4', imageUrl: 'assets/images/minimal_offline.png', thumbnailUrl: 'assets/images/minimal_offline.png', category: 'Premium Offline', photographer: 'AI Generator'),
      ]);
      _hasMore = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final newWallpapers = await _apiService.fetchWallpapers(
        query: _currentQuery,
        page: _currentPage,
      );

      if (newWallpapers.isEmpty) {
        _hasMore = false;
      } else {
        _wallpapers.addAll(newWallpapers);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
