import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

// ─── Auth Service ─────────────────────────────────────────────────────────────

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> reloadUser() async => await _auth.currentUser?.reload();
  
  // Send Firebase email verification link
  Future<void> sendEmailVerification() async {
    if (_auth.currentUser != null) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }
}

// ─── Firestore Service ────────────────────────────────────────────────────────

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ListingModel>> getListingsStream() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }

  Stream<List<ListingModel>> getUserListingsStream(String userId) {
    return _firestore
        .collection('listings')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final listings =
          snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList();
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    });
  }

  Future<String> createListing(ListingModel listing) async {
    final docRef =
        await _firestore.collection('listings').add(listing.toFirestore());
    return docRef.id;
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _firestore.collection('listings').doc(id).update(data);
  }

  Future<void> deleteListing(String id) async {
    await _firestore.collection('listings').doc(id).delete();
  }

  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateUserVerification(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'emailVerified': true,
      'verifiedAt': FieldValue.serverTimestamp(),
    });
  }

}
