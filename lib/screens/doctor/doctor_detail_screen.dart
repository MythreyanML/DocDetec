import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_finder_flutter/models/doctor_model.dart';
import 'package:doctor_finder_flutter/models/review_model.dart';
import 'package:doctor_finder_flutter/services/firestore_service.dart';
import 'package:doctor_finder_flutter/services/location_service.dart';
import 'package:doctor_finder_flutter/widgets/common/loading_indicator.dart';
import 'package:doctor_finder_flutter/widgets/map/doctor_map_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  DoctorModel? _doctor;
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  void _loadDoctorData() async {
    final doctor = await FirestoreService.getDoctor(widget.doctorId);
    if (mounted) {
      setState(() {
        _doctor = doctor;
        _isLoading = false;
      });
    }

    // Load reviews
    FirestoreService.getDoctorReviewsStream(widget.doctorId).listen((reviews) {
      if (mounted) {
        setState(() {
          _reviews = reviews.take(5).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    if (_doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Profile')),
        body: const Center(child: Text('Doctor not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDoctorHeader(),
            _buildActionButtons(),
            _buildAboutSection(),
            _buildContactInfo(),
            _buildPracticeInfo(),
            if (_doctor!.location != null) _buildMapSection(),
            _buildReviewsSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDoctorHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _doctor!.photoUrl != null
                ? Image.network(
              _doctor!.photoUrl!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _defaultAvatar(),
            )
                : _defaultAvatar(),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctor!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _doctor!.specialty ?? 'General Practitioner',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      final rating = _doctor!.rating ?? 4.5;
                      if (index < rating.floor()) {
                        return const Icon(Icons.star, size: 16, color: Colors.amber);
                      } else if (index == rating.floor() && rating % 1 >= 0.5) {
                        return const Icon(Icons.star_half, size: 16, color: Colors.amber);
                      } else {
                        return const Icon(Icons.star_outline, size: 16, color: Colors.amber);
                      }
                    }),
                    const SizedBox(width: 5),
                    Text(
                      '${(_doctor!.rating ?? 4.5).toStringAsFixed(1)} (${_doctor!.reviewCount ?? 24} reviews)',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(Icons.phone, 'Call', () => _makeCall()),
          _buildActionButton(Icons.email, 'Email', () => _sendEmail()),
          _buildActionButton(Icons.calendar_today, 'Book', () => _bookAppointment()),
          _buildActionButton(Icons.directions, 'Directions', () => _openDirections()),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _doctor!.about ??
                  'Dr. ${_doctor!.name} is a dedicated healthcare professional committed to providing the highest quality of care to patients.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: Text(_doctor!.phone),
              subtitle: const Text('Phone'),
              onTap: _makeCall,
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: Text(_doctor!.email ?? 'info@doctorfinder.com'),
              subtitle: const Text('Email'),
              onTap: _sendEmail,
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: Text('${_doctor!.address}, ${_doctor!.city}'),
              subtitle: const Text('Address'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Practice Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Accepts Insurance:', _doctor!.acceptsInsurance ? 'Yes' : 'No'),
            _buildInfoRow('Years of Experience:', '${_doctor!.experience ?? 10}+ years'),
            _buildInfoRow('Languages:', _doctor!.languages ?? 'English, Setswana'),
            _buildInfoRow('Opening Hours:', _doctor!.openingHours ?? 'Mon-Fri: 8:00 AM - 5:00 PM'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: DoctorMapView(doctor: _doctor!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/home/doctor/${widget.doctorId}/reviews'),
                  child: const Text('View All'),
                ),
              ],
            ),
            if (_reviews.isEmpty)
              const Text('No reviews yet. Be the first to review!')
            else
              ..._reviews.map((review) => _buildReviewItem(review)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.push('/home/doctor/${widget.doctorId}/reviews'),
              child: const Text('Write a Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_outline,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        review.createdAt.toString().split(' ')[0],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.text),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: _bookAppointment,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Book Appointment'),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  void _makeCall() async {
    final uri = Uri.parse('tel:${_doctor!.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendEmail() async {
    final uri = Uri.parse('mailto:${_doctor!.email ?? "info@doctorfinder.com"}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _bookAppointment() {
    context.push('/home/doctor/${widget.doctorId}/appointment');
  }

  void _openDirections() async {
    if (_doctor!.location != null) {
      await LocationService.openMapsDirections(
        _doctor!.location!.latitude,
        _doctor!.location!.longitude,
      );
    }
  }
}