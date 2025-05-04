import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_finder_flutter/models/user_model.dart';
import 'package:doctor_finder_flutter/services/firebase_service.dart';

class AuthService {
  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final userCredential = await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
        );

        await FirebaseService.usersCollection
            .doc(userCredential.user!.uid)
            .set(user.toMap());
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await FirebaseService.auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return FirebaseService.currentUser;
  }

  // Get current user data
  static Future<UserModel?> getCurrentUserData() async {
    final user = getCurrentUser();
    if (user == null) return null;

    try {
      final doc = await FirebaseService.usersCollection.doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await FirebaseService.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Handle Auth errors
  static String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'The account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }
}