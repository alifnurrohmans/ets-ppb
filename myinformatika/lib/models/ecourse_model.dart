import 'package:cloud_firestore/cloud_firestore.dart';

class ECourseModel {
  final String id;
  final String instructorId;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final String? category;
  final double? price;
  final int? enrollmentCount;

  ECourseModel({
    required this.id,
    required this.instructorId,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.createdAt,
    this.category,
    this.price,
    this.enrollmentCount,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'instructorId': instructorId,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
      'price': price,
      'enrollmentCount': enrollmentCount ?? 0,
    };
  }

  // Create from Firestore document
  factory ECourseModel.fromMap(Map<String, dynamic> map) {
    return ECourseModel(
      id: map['id'] ?? '',
      instructorId: map['instructorId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      category: map['category'],
      price: (map['price'] as num?)?.toDouble(),
      enrollmentCount: map['enrollmentCount'] ?? 0,
    );
  }

  factory ECourseModel.fromJson(Map<String, dynamic> json) {
    return ECourseModel.fromMap(json);
  }

  ECourseModel copyWith({
    String? id,
    String? instructorId,
    String? title,
    String? description,
    String? thumbnailUrl,
    DateTime? createdAt,
    String? category,
    double? price,
    int? enrollmentCount,
  }) {
    return ECourseModel(
      id: id ?? this.id,
      instructorId: instructorId ?? this.instructorId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      price: price ?? this.price,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
    );
  }
}
