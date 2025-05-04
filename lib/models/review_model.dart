class ReviewModel {
  final String id;
  final String doctorId;
  final String userId;
  final String userName;
  final double rating;
  final String text;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      doctorId: map['doctorId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      rating: (map['rating'] ?? 0.0).toDouble(),
      text: map['text'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'text': text,
      'createdAt': createdAt.toUtc(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    return DateTime.parse(value.toString());
  }
}