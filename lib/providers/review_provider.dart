import 'package:flutter/material.dart';
import 'package:doctor_finder_flutter/models/review_model.dart';
import 'package:doctor_finder_flutter/services/firestore_service.dart';

class ReviewProvider extends ChangeNotifier {
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load doctor reviews
  void loadDoctorReviews(String doctorId) {
    FirestoreService.getDoctorReviewsStream(doctorId).listen((reviews) {
      _reviews = reviews;
      notifyListeners();
    });
  }

  // Add review
  Future<bool> addReview(ReviewModel review) async {
    try {
      _setLoading(true);
      await FirestoreService.addReview(review);

      // Update doctor's average rating
      final doctorReviews = _reviews.where((r) => r.doctorId == review.doctorId).toList();
      doctorReviews.add(review);

      final totalRating = doctorReviews.fold(0.0, (sum, r) => sum + r.rating);
      final averageRating = totalRating / doctorReviews.length;

      await FirestoreService.updateDoctorRating(
        review.doctorId,
        averageRating,
        doctorReviews.length,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}