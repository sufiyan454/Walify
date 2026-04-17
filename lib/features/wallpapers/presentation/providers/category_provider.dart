import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final List<String> _categories = [
    'Premium Offline',
    'Nature',
    'Anime',
    'Cartoon',
    'Architecture',
    'Abstract',
    'Cars',
    'Animals',
    'Memes',
    'Minimal'
  ];

  List<String> get categories => _categories;
}
