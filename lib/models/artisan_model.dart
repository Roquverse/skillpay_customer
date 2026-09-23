class ArtisanModel {
  final String id;
  final String userId;
  final String fullName;
  final String? businessName;
  final String? bio;
  final String profession;
  final double rating;
  final int jobsCompleted;
  final double? hourlyRate;
  final String? profilePhoto;
  final String availabilityStatus;
  final double? latitude;
  final double? longitude;
  final List<String> categoryNames;
  final bool isVerified;

  ArtisanModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.businessName,
    this.bio,
    required this.profession,
    required this.rating,
    required this.jobsCompleted,
    this.hourlyRate,
    this.profilePhoto,
    this.availabilityStatus = 'AVAILABLE',
    this.latitude,
    this.longitude,
    required this.categoryNames,
    this.isVerified = false,
  });

  factory ArtisanModel.fromMap(Map<String, dynamic> map) {
    final rawCats = map['categories'] as List<dynamic>? ?? [];
    final categoryNames = rawCats.map((c) {
      if (c is String) return c;
      if (c is Map) {
        final cat = c['category'] as Map<String, dynamic>?;
        return cat?['name']?.toString() ?? c['name']?.toString() ?? '';
      }
      return '';
    }).where((s) => s.isNotEmpty).toList();

    final profession = categoryNames.isNotEmpty
        ? categoryNames.first
        : (map['profession']?.toString() ?? map['trade']?.toString() ?? 'General Artisan');

    final verificationStatus = map['verificationStatus']?.toString() ??
        map['verification_status']?.toString() ??
        'UNVERIFIED';

    final ratingVal = map['averageRating'] ?? map['average_rating'] ?? map['rating'] ?? 5.0;
    final rating = (ratingVal is num)
        ? ratingVal.toDouble()
        : (double.tryParse(ratingVal.toString()) ?? 5.0);

    final completedJobsVal = map['completedJobs'] ?? map['completed_jobs'] ?? 0;
    final completedJobs = (completedJobsVal is int)
        ? completedJobsVal
        : (int.tryParse(completedJobsVal.toString()) ?? 0);

    return ArtisanModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? map['user_id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? map['full_name']?.toString() ?? 'Artisan',
      businessName: map['businessName']?.toString() ?? map['business_name']?.toString(),
      bio: map['bio']?.toString(),
      profession: profession,
      rating: rating,
      jobsCompleted: completedJobs,
      hourlyRate: map['hourlyRate'] != null ? double.tryParse(map['hourlyRate'].toString()) : null,
      profilePhoto: map['profilePhoto']?.toString() ?? map['profile_photo']?.toString(),
      availabilityStatus: map['availabilityStatus']?.toString() ?? 'AVAILABLE',
      latitude: map['latitude'] != null ? double.tryParse(map['latitude'].toString()) : null,
      longitude: map['longitude'] != null ? double.tryParse(map['longitude'].toString()) : null,
      categoryNames: categoryNames,
      isVerified: verificationStatus.toUpperCase() == 'VERIFIED',
    );
  }
}
