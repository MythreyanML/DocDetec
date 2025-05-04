import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_finder_flutter/models/doctor_model.dart';
import 'package:doctor_finder_flutter/core/utils/distance_calculator.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final double? distance;
  final VoidCallback? onTap;

  const DoctorCard({
    Key? key,
    required this.doctor,
    this.distance,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: doctor.photoUrl != null
                        ? Image.network(
                      doctor.photoUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar(),
                    )
                        : _defaultAvatar(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          doctor.specialty ?? 'General Practitioner',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Text(
                          doctor.rating?.toStringAsFixed(1) ?? '4.5',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (doctor.city != null || doctor.address != null)
                _buildDetailRow(
                  Icons.location_on,
                  '${doctor.city ?? ''}, ${doctor.address ?? ''}'.trim(),
                ),
              if (distance != null)
                _buildDetailRow(
                  Icons.navigation,
                  '${DistanceCalculator.formatDistance(distance!)} away',
                ),
              _buildDetailRow(Icons.phone, doctor.phone),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (doctor.acceptsInsurance)
                    Chip(
                      avatar: const Icon(Icons.shield, size: 16),
                      label: const Text('Insurance'),
                      backgroundColor: Colors.green.shade50,
                      labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  Chip(
                    label: Text('${doctor.reviewCount ?? 24} reviews'),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      child: const Text('View Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/home/doctor/${doctor.id}/appointment'),
                      child: const Text('Book Appointment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.person,
        size: 32,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}