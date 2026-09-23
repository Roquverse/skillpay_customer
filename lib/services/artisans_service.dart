import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/artisan_model.dart';

class ArtisansService {
  final _api = ApiClient.instance;
  static List<ArtisanModel>? _cachedTopArtisans;

  List<ArtisanModel>? getCachedTopArtisans() => _cachedTopArtisans;

  /// Fetch top rated artisans for the dashboard
  Future<List<ArtisanModel>> fetchTopArtisans({int limit = 10}) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      final data = await _api.get('/artisans', query: query);
      if (data is List) {
        final artisans = data
            .map((json) => ArtisanModel.fromMap(json as Map<String, dynamic>))
            .toList();
        _cachedTopArtisans = artisans;
        return artisans;
      }
      return _cachedTopArtisans ?? _mockArtisans();
    } catch (e) {
      debugPrint('[ArtisansService] Error fetching top artisans: $e');
      return _cachedTopArtisans ?? _mockArtisans();
    }
  }

  /// Search and filter artisans for the Artisans browse screen
  Future<List<ArtisanModel>> fetchArtisans({
    String? search,
    String? categoryId,
    int limit = 30,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      };
      final data = await _api.get('/artisans', query: query);
      if (data is List) {
        return data
            .map((json) => ArtisanModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return _mockArtisans();
    } catch (e) {
      debugPrint('[ArtisansService] Error searching artisans: $e');
      return _mockArtisans();
    }
  }

  /// Fetch single artisan profile by ID
  Future<ArtisanModel?> fetchArtisan(String id) async {
    try {
      final data = await _api.get('/artisans/$id') as Map<String, dynamic>;
      return ArtisanModel.fromMap(data);
    } catch (e) {
      debugPrint('[ArtisansService] Error fetching artisan $id: $e');
      return null;
    }
  }

  static List<ArtisanModel> _mockArtisans() {
    return [
      ArtisanModel(
        id: 'mock-1',
        userId: 'user-1',
        fullName: 'James Walker',
        profession: 'Plumber',
        rating: 4.8,
        jobsCompleted: 45,
        profilePhoto: 'assets/images/avatar_james.png',
        categoryNames: ['Plumbing'],
        isVerified: true,
      ),
      ArtisanModel(
        id: 'mock-2',
        userId: 'user-2',
        fullName: 'Marcus Bell',
        profession: 'Electrician',
        rating: 4.9,
        jobsCompleted: 32,
        profilePhoto: 'assets/images/avatar_james.png',
        categoryNames: ['Electrical'],
        isVerified: true,
      ),
    ];
  }
}
