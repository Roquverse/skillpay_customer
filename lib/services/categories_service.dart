import 'package:flutter/foundation.dart';
import 'api_client.dart';

class CategoryItemModel {
  final String id;
  final String name;
  final String? icon;
  final String? image;

  CategoryItemModel({
    required this.id,
    required this.name,
    this.icon,
    this.image,
  });

  factory CategoryItemModel.fromMap(Map<String, dynamic> map) {
    return CategoryItemModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Service',
      icon: map['icon']?.toString(),
      image: map['image']?.toString(),
    );
  }
}

class CategoriesService {
  final _api = ApiClient.instance;
  static List<CategoryItemModel>? _cachedCategories;

  List<CategoryItemModel>? getCachedCategories() => _cachedCategories;

  /// Fetch active categories from the backend
  Future<List<CategoryItemModel>> fetchCategories() async {
    try {
      final response = await _api.get('/categories');
      if (response is List) {
        final categories = response
            .map((item) => CategoryItemModel.fromMap(item as Map<String, dynamic>))
            .toList();
        _cachedCategories = categories;
        return categories;
      }
      return _cachedCategories ?? _defaultCategories();
    } catch (e) {
      debugPrint('[CategoriesService] Error fetching categories: $e');
      return _cachedCategories ?? _defaultCategories();
    }
  }

  static List<CategoryItemModel> _defaultCategories() {
    return [
      CategoryItemModel(
        id: 'cat-cleaning',
        name: 'Cleaning',
        image: 'assets/images/cat_cleaning.png',
      ),
      CategoryItemModel(
        id: 'cat-plumbing',
        name: 'Plumbing',
        image: 'assets/images/cat_plumbing.png',
      ),
      CategoryItemModel(
        id: 'cat-electrical',
        name: 'Electrical',
        image: 'assets/images/cat_electrical.png',
      ),
    ];
  }
}
