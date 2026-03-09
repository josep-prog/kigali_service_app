import 'package:firebase_core/firebase_core.dart';

class FirebaseInit {
  static FirebaseApp? get app => Firebase.app();

  static bool get isInitialized {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }
}
