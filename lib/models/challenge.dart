class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final String organizerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.organizerId,
    this.startDate,
    this.endDate,
    this.status = 'open',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'organizerId': organizerId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      organizerId: map['organizerId'] ?? '',
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'])
          : null,
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'])
          : null,
      status: map['status'] ?? 'open',
    );
  }
}
