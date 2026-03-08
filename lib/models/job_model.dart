class JobModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final double budget;
  final String timeline;
  final String status;
  final int proposalCount;
  final String customerId;
  final String? artisanId;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.budget,
    required this.timeline,
    required this.status,
    required this.proposalCount,
    required this.customerId,
    this.artisanId,
    required this.createdAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      location: map['location'] ?? 'Location not provided',
      budget: (map['budget'] != null) ? double.parse(map['budget'].toString()) : 0.0,
      timeline: map['job_timeline'] ?? 'Flexible',
      status: map['status'] ?? 'pending',
      proposalCount: map['proposal_count'] ?? 0,
      customerId: map['customer_id'] as String,
      artisanId: map['artisan_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'budget': budget,
      'job_timeline': timeline,
      'status': status,
      'proposal_count': proposalCount,
      'customer_id': customerId,
    };
  }
}
