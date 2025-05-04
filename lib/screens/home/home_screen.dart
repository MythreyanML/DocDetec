import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_finder_flutter/providers/doctor_provider.dart';
import 'package:doctor_finder_flutter/providers/auth_provider.dart';
import 'package:doctor_finder_flutter/widgets/common/doctor_card.dart';
import 'package:doctor_finder_flutter/widgets/common/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
      ),
      body: Consumer2<DoctorProvider, AuthProvider>(
        builder: (context, doctorProvider, authProvider, child) {
          // Show loading if authentication is still being determined
          if (authProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          return Column(
            children: [
              _buildSearchHeader(doctorProvider),
              _buildSpecialtyChips(doctorProvider),
              Expanded(
                child: _buildDoctorsList(doctorProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader(DoctorProvider provider) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by name or city',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.isLocationMode
                      ? 'Showing doctors within 200km'
                      : 'Showing all doctors',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                OutlinedButton(
                  onPressed: provider.toggleLocationMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: Text(
                    provider.isLocationMode ? 'Show All' : 'Show Nearby',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyChips(DoctorProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            const Text(
              'Specialties: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...provider.specialties.map((specialty) {
              final isSelected = provider.selectedSpecialty?.id == specialty.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(specialty.name),
                  selected: isSelected,
                  onSelected: (_) => provider.setSpecialtyFilter(
                    isSelected ? null : specialty,
                  ),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList(DoctorProvider provider) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (provider.doctors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No doctors found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Try changing your search criteria',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: provider.doctors.length,
      itemBuilder: (context, index) {
        final doctor = provider.doctors[index];
        final distance = provider.getDoctorDistance(doctor);

        return DoctorCard(
          doctor: doctor,
          distance: distance,
          onTap: () => context.push('/home/doctor/${doctor.id}'),
        );
      },
    );
  }
}