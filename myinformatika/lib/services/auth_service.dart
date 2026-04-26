import 'package:firebase_auth/firebase_auth.dart';
import 'package:myinformatika/models/user_model.dart';
import 'package:myinformatika/services/firebase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firebaseService.createUser(userModel);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoUrl != null) {
        await _auth.currentUser?.updatePhotoURL(photoUrl);
      }
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Get user role from Firestore
  Future<UserRole?> getUserRole(String userId) async {
    try {
      final user = await _firebaseService.getUser(userId);
      return user?.role;
    } catch (e) {
      throw Exception('Error getting user role: $e');
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      // Use Firestore users collection to check if email exists instead of
      // relying on FirebaseAuth method (compatibility across versions).
      final user = await _firebaseService.getUserByEmail(email);
      return user != null;
    } catch (e) {
      throw Exception('Error checking email: $e');
    }
  }

  /// Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'Email is already registered. Please try signing in instead.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
