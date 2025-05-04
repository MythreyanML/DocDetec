import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  // Firebase instances
  static late FirebaseAuth _auth;
  static late FirebaseFirestore _firestore;
  static late FirebaseStorage _storage;
  static bool _initialized = false;

  // Initialize Firebase services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;

      // Enable Firestore offline persistence
      await _firestore.enablePersistence();

      _initialized = true;
      print('Firebase services initialized successfully');
    } catch (e) {
      print('Error initializing Firebase services: $e');
      // If persistence fails, continue without it
      if (e.toString().contains('persistence')) {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        _storage = FirebaseStorage.instance;
        _initialized = true;
      } else {
        rethrow;
      }
    }
  }

  // Auth
  static FirebaseAuth get auth {
    _checkInitialization();
    return _auth;
  }

  static User? get currentUser => auth.currentUser;

  // Firestore
  static FirebaseFirestore get firestore {
    _checkInitialization();
    return _firestore;
  }

  // Collections
  static CollectionReference get doctorsCollection => firestore.collection('doctors');
  static CollectionReference get appointmentsCollection => firestore.collection('appointments');
  static CollectionReference get reviewsCollection => firestore.collection('reviews');
  static CollectionReference get specialtiesCollection => firestore.collection('specialties');
  static CollectionReference get usersCollection => firestore.collection('users');

  // Storage
  static FirebaseStorage get storage {
    _checkInitialization();
    return _storage;
  }

  static void _checkInitialization() {
    if (!_initialized) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
  }
}