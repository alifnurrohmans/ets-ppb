import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myinformatika/models/user_model.dart';
import 'package:myinformatika/models/ecourse_model.dart';
import 'package:myinformatika/models/enrollment_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  
  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ USER OPERATIONS ============

  /// Create a new user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user by email: $e');
    }
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  /// Stream of all users with specific role
  Stream<List<UserModel>> getUsersByRole(UserRole role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // ============ ECOURSE OPERATIONS ============

  /// Create a new ecourse
  Future<String> createECourse(ECourseModel ecourse) async {
    try {
      final docRef = await _firestore
          .collection('ecourses')
          .add(ecourse.toMap());
      
      // Update document with its ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating ecourse: $e');
    }
  }

  /// Get ecourse by ID
  Future<ECourseModel?> getECourse(String ecourseId) async {
    try {
      final doc = await _firestore
          .collection('ecourses')
          .doc(ecourseId)
          .get();
      
      if (doc.exists) {
        return ECourseModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting ecourse: $e');
    }
  }

  /// Update ecourse
  Future<void> updateECourse(ECourseModel ecourse) async {
    try {
      await _firestore
          .collection('ecourses')
          .doc(ecourse.id)
          .update(ecourse.toMap());
    } catch (e) {
      throw Exception('Error updating ecourse: $e');
    }
  }

  /// Delete ecourse
  Future<void> deleteECourse(String ecourseId) async {
    try {
      await _firestore
          .collection('ecourses')
          .doc(ecourseId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting ecourse: $e');
    }
  }

  /// Get all ecourses by instructor
  Stream<List<ECourseModel>> getECoursesByInstructor(String instructorId) {
    return _firestore
        .collection('ecourses')
        .where('instructorId', isEqualTo: instructorId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ECourseModel.fromMap(doc.data()))
            .toList());
  }

  /// Get all available ecourses
  Stream<List<ECourseModel>> getAllECourses() {
    return _firestore
        .collection('ecourses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ECourseModel.fromMap(doc.data()))
            .toList());
  }

  // ============ ENROLLMENT OPERATIONS ============

  /// Create enrollment
  Future<String> createEnrollment(EnrollmentModel enrollment) async {
    try {
      final docRef = await _firestore
          .collection('enrollments')
          .add(enrollment.toMap());
      
      // Update document with its ID
      await docRef.update({'id': docRef.id});

      // Increment enrollment count on ecourse
      await _firestore
          .collection('ecourses')
          .doc(enrollment.ecourseId)
          .update({
        'enrollmentCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error creating enrollment: $e');
    }
  }

  /// Get enrollment by ID
  Future<EnrollmentModel?> getEnrollment(String enrollmentId) async {
    try {
      final doc = await _firestore
          .collection('enrollments')
          .doc(enrollmentId)
          .get();
      
      if (doc.exists) {
        return EnrollmentModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting enrollment: $e');
    }
  }

  /// Update enrollment
  Future<void> updateEnrollment(EnrollmentModel enrollment) async {
    try {
      await _firestore
          .collection('enrollments')
          .doc(enrollment.id)
          .update(enrollment.toMap());
    } catch (e) {
      throw Exception('Error updating enrollment: $e');
    }
  }

  /// Delete enrollment
  Future<void> deleteEnrollment(String enrollmentId, String ecourseId) async {
    try {
      await _firestore
          .collection('enrollments')
          .doc(enrollmentId)
          .delete();

      // Decrement enrollment count on ecourse
      await _firestore
          .collection('ecourses')
          .doc(ecourseId)
          .update({
        'enrollmentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Error deleting enrollment: $e');
    }
  }

  /// Get enrollments by student
  Stream<List<EnrollmentModel>> getEnrollmentsByStudent(String studentId) {
    return _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EnrollmentModel.fromMap(doc.data()))
            .toList());
  }

  /// Get enrollments by ecourse
  Stream<List<EnrollmentModel>> getEnrollmentsByECourse(String ecourseId) {
    return _firestore
        .collection('enrollments')
        .where('ecourseId', isEqualTo: ecourseId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EnrollmentModel.fromMap(doc.data()))
            .toList());
  }

  /// Check if student is enrolled in ecourse
  Future<bool> isStudentEnrolled(String studentId, String ecourseId) async {
    try {
      final query = await _firestore
          .collection('enrollments')
          .where('studentId', isEqualTo: studentId)
          .where('ecourseId', isEqualTo: ecourseId)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking enrollment: $e');
    }
  }

  /// Get enrollment by student and course
  Future<EnrollmentModel?> getEnrollmentByStudentAndCourse(String studentId, String ecourseId) async {
    try {
      final query = await _firestore
          .collection('enrollments')
          .where('studentId', isEqualTo: studentId)
          .where('ecourseId', isEqualTo: ecourseId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return EnrollmentModel.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Error getting enrollment by student and course: $e');
    }
  }

  /// Delete enrollment by student and course (if exists)
  Future<void> deleteEnrollmentByStudentAndCourse(String studentId, String ecourseId) async {
    try {
      final query = await _firestore
          .collection('enrollments')
          .where('studentId', isEqualTo: studentId)
          .where('ecourseId', isEqualTo: ecourseId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await _firestore.collection('enrollments').doc(docId).delete();

        // Decrement enrollment count on ecourse
        await _firestore
            .collection('ecourses')
            .doc(ecourseId)
            .update({
          'enrollmentCount': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      throw Exception('Error deleting enrollment by student and course: $e');
    }
  }

  /// Get student course count
  Future<int> getStudentEnrollmentCount(String studentId) async {
    try {
      final query = await _firestore
          .collection('enrollments')
          .where('studentId', isEqualTo: studentId)
          .count()
          .get();
      
      return query.count ?? 0;
    } catch (e) {
      throw Exception('Error getting enrollment count: $e');
    }
  }
}
