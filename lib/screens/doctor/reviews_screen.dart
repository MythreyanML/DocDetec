import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doctor_finder_flutter/models/doctor_model.dart';
import 'package:doctor_finder_flutter/models/review_model.dart';
import 'package:doctor_finder_flutter/providers/auth_provider.dart';
import 'package:doctor_finder_flutter/services/firestore_service.dart';
import 'package:doctor_finder_flutter/widgets/common/custom_text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsScreen extends StatefulWidget {
  final String doctorId;

  const ReviewsScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  DoctorModel? _doctor;
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  double _rating = 5.0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _loadData() async {
    final doctor = await FirestoreService.getDoctor(widget.doctorId);
    if (mounted) {
      setState(() {
        _doctor = doctor;
        _isLoading = false;
      });
    }

    FirestoreService.getDoctorReviewsStream(widget.doctorId).listen((reviews) {
      if (mounted) {
        setState(() {
          _reviews = reviews;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_doctor != null) _buildDoctorSummary(),
            _buildWriteReviewSection(),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _doctor!.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  final rating = _doctor!.rating ?? 4.5;
                  if (index < rating.floor()) {
                    return const Icon(Icons.star, size: 16, color: Colors.amber);
                  } else if (index == rating.floor() && rating % 1 >= 0.5) {
                    return const Icon(Icons.star_half, size: 16, color: Colors.amber);
                  } else {
                    return const Icon(Icons.star_outline, size: 16, color: Colors.amber);
                  }
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${(_doctor!.rating ?? 4.5).toStringAsFixed(1)} (${_reviews.length} reviews)',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text('Please log in to write a review'),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/auth'),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.all(15),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Write a Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Your Rating:'),
                    const SizedBox(width: 10),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 25,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(_rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _reviewController,
                  label: 'Your Review',
                  maxLines: 4,
                  hint: 'Share your experience with this doctor...',
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Review'),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Your review will help others find the right doctor for their needs.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            'All Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length,
            itemBuilder: (context, index) => _buildReviewItem(_reviews[index]),
          ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName.substring(0, 1).toUpperCase()
                        : 'A',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating ? Icons.star : Icons.star_outline,
                                size: 16,
                                color: Colors.amber,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.createdAt.toString().split(' ')[0],
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(review.text),
          ],
        ),
      ),
    );
  }

  void _submitReview() async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user == null) return;

      final review = ReviewModel(
        id: '',
        doctorId: widget.doctorId,
        userId: user.id,
        userName: user.name ?? user.email ?? 'Anonymous',
        rating: _rating,
        text: _reviewController.text,
        createdAt: DateTime.now(),
      );

      await FirestoreService.addReview(review);

      // Update doctor's average rating
      final allReviews = _reviews + [review];
      final totalRating = allReviews.fold(0.0, (sum, r) => sum + r.rating);
      final averageRating = totalRating / allReviews.length;

      await FirestoreService.updateDoctorRating(
        widget.doctorId,
        averageRating,
        allReviews.length,
      );

      _reviewController.clear();
      setState(() => _rating = 5.0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}