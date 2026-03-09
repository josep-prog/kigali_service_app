import 'package:firebase_core/firebase_core.dart';

/// Helper to get Firebase app instance
class FirebaseInit {
  /// Get Firebase app instance (already initialized in main.dart)
  static FirebaseApp? get app => Firebase.app();

  /// Check if Firebase is initialized
  static bool get isInitialized {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }
}
