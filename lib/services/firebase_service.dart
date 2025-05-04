import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Firebase instances
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth
  static FirebaseAuth get auth => _auth;
  static User? get currentUser => _auth.currentUser;

  // Firestore
  static FirebaseFirestore get firestore => _firestore;

  // Collections
  static CollectionReference get doctorsCollection => _firestore.collection('doctors');
  static CollectionReference get appointmentsCollection => _firestore.collection('appointments');
  static CollectionReference get reviewsCollection => _firestore.collection('reviews');
  static CollectionReference get specialtiesCollection => _firestore.collection('specialties');
  static CollectionReference get usersCollection => _firestore.collection('users');

  // Storage
  static FirebaseStorage get storage => _storage;
}