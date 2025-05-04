import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_finder_flutter/models/doctor_model.dart';
import 'package:doctor_finder_flutter/models/appointment_model.dart';
import 'package:doctor_finder_flutter/models/review_model.dart';
import 'package:doctor_finder_flutter/models/specialty_model.dart';
import 'package:doctor_finder_flutter/services/firebase_service.dart';

class FirestoreService {
  // Add debug method to test connection
  static Future<void> testConnection() async {
    try {
      print('Testing Firestore connection...');
      final testCollection = FirebaseService.firestore.collection('test');
      await testCollection.doc('test').set({'timestamp': DateTime.now()});
      print('Firestore connection successful!');
    } catch (e) {
      print('Firestore connection failed: $e');
    }
  }

  // Doctor operations
  static Stream<List<DoctorModel>> getDoctorsStream() {
    return FirebaseService.doctorsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  static Future<DoctorModel?> getDoctor(String doctorId) async {
    try {
      final doc = await FirebaseService.doctorsCollection.doc(doctorId).get();
      if (doc.exists) {
        return DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting doctor: $e');
      return null;
    }
  }

  static Future<void> updateDoctorRating(String doctorId, double averageRating, int reviewCount) async {
    try {
      await FirebaseService.doctorsCollection.doc(doctorId).update({
        'rating': averageRating,
        'reviewCount': reviewCount,
      });
    } catch (e) {
      print('Error updating doctor rating: $e');
      rethrow;
    }
  }

  // Appointment operations
  static Future<String> addAppointment(AppointmentModel appointment) async {
    try {
      final docRef = await FirebaseService.appointmentsCollection.add(appointment.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding appointment: $e');
      rethrow;
    }
  }

  static Stream<List<AppointmentModel>> getUserAppointmentsStream(String userId) {
    return FirebaseService.appointmentsCollection
        .where('patientId', isEqualTo: userId)
        .orderBy('appointmentDateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  static Stream<List<AppointmentModel>> getDoctorAppointmentsStream(String doctorId) {
    return FirebaseService.appointmentsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDateTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  static Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await FirebaseService.appointmentsCollection.doc(appointmentId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }

  // Review operations
  static Future<String> addReview(ReviewModel review) async {
    try {
      final docRef = await FirebaseService.reviewsCollection.add(review.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  static Stream<List<ReviewModel>> getDoctorReviewsStream(String doctorId) {
    return FirebaseService.reviewsCollection
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  // Specialty operations
  static Stream<List<SpecialtyModel>> getSpecialtiesStream() {
    return FirebaseService.specialtiesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SpecialtyModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList()
    );
  }

  static Future<SpecialtyModel?> getSpecialty(String specialtyId) async {
    try {
      final doc = await FirebaseService.specialtiesCollection.doc(specialtyId).get();
      if (doc.exists) {
        return SpecialtyModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting specialty: $e');
      return null;
    }
  }

  // Search doctors
  static Stream<List<DoctorModel>> searchDoctors({String? city, String? name}) {
    Query query = FirebaseService.doctorsCollection;

    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }

    return query.snapshots().map((snapshot) {
      var doctors = snapshot.docs.map((doc) => DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

      if (name != null) {
        doctors = doctors.where((doctor) =>
            doctor.name.toLowerCase().contains(name.toLowerCase())
        ).toList();
      }

      return doctors;
    });
  }
}