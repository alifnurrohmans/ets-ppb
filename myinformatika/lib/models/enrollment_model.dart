import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String id;
  final String studentId;
  final String ecourseId;
  final DateTime enrolledAt;
  final bool completed;
  final DateTime? completedAt;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.ecourseId,
    required this.enrolledAt,
    this.completed = false,
    this.completedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'ecourseId': ecourseId,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'completed': completed,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  // Create from Firestore document
  factory EnrollmentModel.fromMap(Map<String, dynamic> map) {
    return EnrollmentModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      ecourseId: map['ecourseId'] ?? '',
      enrolledAt: (map['enrolledAt'] as Timestamp).toDate(),
      completed: map['completed'] ?? false,
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel.fromMap(json);
  }

  EnrollmentModel copyWith({
    String? id,
    String? studentId,
    String? ecourseId,
    DateTime? enrolledAt,
    bool? completed,
    DateTime? completedAt,
  }) {
    return EnrollmentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      ecourseId: ecourseId ?? this.ecourseId,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
