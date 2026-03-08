class ProposalModel {
  final String id;
  final String jobId;
  final String artisanId;
  final String coverLetter;
  final double price;
  final String status;
  
  // Artisan Details (Joined)
  final String artisanName;
  final String artisanLocation;
  final String artisanBio;
  final List<String> artisanBadges;
  final double artisanRating;
  final int artisanJobsCompleted;
  final String artisanAvatarUrl;

  ProposalModel({
    required this.id,
    required this.jobId,
    required this.artisanId,
    required this.coverLetter,
    required this.price,
    required this.status,
    required this.artisanName,
    required this.artisanLocation,
    required this.artisanBio,
    required this.artisanBadges,
    required this.artisanRating,
    required this.artisanJobsCompleted,
    required this.artisanAvatarUrl,
  });

  factory ProposalModel.fromMap(Map<String, dynamic> map) {
    // Assuming a join with user_profiles table aliased or embedded as 'artisan'
    final artisanData = map['artisan'] ?? {};
    
    return ProposalModel(
      id: map['id'] as String,
      jobId: map['job_id'] as String,
      artisanId: map['artisan_id'] as String,
      coverLetter: map['cover_letter'] ?? '',
      price: (map['price'] != null) ? double.parse(map['price'].toString()) : 0.0,
      status: map['status'] ?? 'pending',
      artisanName: artisanData['full_name'] ?? 'Unknown Artisan',
      artisanLocation: artisanData['home_address'] ?? 'Unknown Location',
      artisanBio: artisanData['bio'] ?? 'No bio provided.',
      artisanBadges: List<String>.from(artisanData['badges'] ?? ['General']),
      artisanRating: (artisanData['rating'] != null) ? double.parse(artisanData['rating'].toString()) : 4.5,
      artisanJobsCompleted: artisanData['jobs_completed'] ?? 0,
      artisanAvatarUrl: artisanData['profile_image_url'] ?? 'assets/images/avatar_james.png',
    );
  }
}
