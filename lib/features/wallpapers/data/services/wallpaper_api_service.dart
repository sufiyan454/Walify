import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/wallpaper_model.dart';
import '../../domain/entities/wallpaper_entity.dart';

class WallpaperApiService {
  Future<List<WallpaperEntity>> fetchWallpapers({
    required String query,
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}search/photos?query=$query&per_page=${ApiConstants.perPage}&page=$page'),
      headers: {
        'Authorization': 'Client-ID ${ApiConstants.apiKey}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> photos = data['results'];
      
      return photos.map((json) => WallpaperModel.fromJson(json, query)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Unsplash API Key is Missing or Invalid. Please enter it in api_constants.dart!');
    } else {
      throw Exception('Failed to load wallpapers. Status: ${response.statusCode}');
    }
  }
}
