class JobModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? categoryId;
  final String location;
  final double budget;
  final String timeline;
  final String status;
  final int proposalCount;
  final String customerId;
  final String? artisanId;
  final String? artisanName;
  final List<String> images;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.categoryId,
    required this.location,
    required this.budget,
    required this.timeline,
    required this.status,
    required this.proposalCount,
    required this.customerId,
    this.artisanId,
    this.artisanName,
    this.images = const [],
    required this.createdAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    // Category resolution
    String categoryName = 'General';
    String? categoryId;
    if (map['category'] is Map) {
      final catMap = map['category'] as Map<String, dynamic>;
      categoryName = catMap['name']?.toString() ?? 'General';
      categoryId = catMap['id']?.toString();
    } else if (map['category'] is String) {
      categoryName = map['category'] as String;
      categoryId = map['categoryId']?.toString();
    }

    // Booking or artisan resolution
    String? resolvedArtisanId = map['artisanId']?.toString() ?? map['artisan_id']?.toString();
    String? resolvedArtisanName = map['artisanName']?.toString();

    if (map['booking'] is Map) {
      final booking = map['booking'] as Map<String, dynamic>;
      resolvedArtisanId ??= booking['artisanId']?.toString();
      if (booking['artisan'] is Map) {
        final artisan = booking['artisan'] as Map<String, dynamic>;
        resolvedArtisanName ??= artisan['fullName']?.toString() ?? artisan['full_name']?.toString();
      }
    }

    // Images
    List<String> imagesList = [];
    if (map['images'] is List) {
      imagesList = (map['images'] as List).map((e) => e.toString()).toList();
    }

    // Date
    DateTime parsedDate = DateTime.now();
    if (map['createdAt'] != null) {
      parsedDate = DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now();
    } else if (map['created_at'] != null) {
      parsedDate = DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now();
    }

    final budgetVal = map['budget'];
    final double parsedBudget = (budgetVal is num)
        ? budgetVal.toDouble()
        : (double.tryParse(budgetVal?.toString() ?? '0') ?? 0.0);

    return JobModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled Job',
      description: map['description']?.toString() ?? '',
      category: categoryName,
      categoryId: categoryId,
      location: map['address']?.toString() ?? map['location']?.toString() ?? 'Location not provided',
      budget: parsedBudget,
      timeline: map['preferredDate']?.toString() ?? map['job_timeline']?.toString() ?? 'Flexible',
      status: map['status']?.toString() ?? 'PENDING',
      proposalCount: (map['applicationCount'] as int?) ??
          (map['application_count'] as int?) ??
          (map['proposal_count'] as int?) ??
          0,
      customerId: map['homeownerId']?.toString() ??
          map['homeowner_id']?.toString() ??
          map['customer_id']?.toString() ??
          '',
      artisanId: resolvedArtisanId,
      artisanName: resolvedArtisanName,
      images: imagesList,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      if (categoryId != null && categoryId!.isNotEmpty) 'categoryId': categoryId,
      'address': location,
      'budget': budget,
      'preferredDate': timeline,
      'images': images,
    };
  }
}
