import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        children: [
          _buildHeader(),
          _buildAboutSection(),
          _buildFeaturesSection(),
          _buildDeveloperSection(),
          _buildContactSection(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 100,
            height: 100,
            errorBuilder: (_, __, ___) => const Icon(Icons.medical_services, size: 100, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          const Text(
            'Doctor Finder',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Find Doctors Near You',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return const Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Doctor Finder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Doctor Finder is a mobile application designed to help users find private doctors in their area. The app was created to address the challenge of finding medical help when in unfamiliar locations.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 10),
            Text(
              'With Doctor Finder, users can search for doctors by location and specialty, view doctor profiles, read reviews, and book appointments.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFeatureItem(
              Icons.map,
              'Find Nearby Doctors',
              'Search for doctors within 200km of your location',
            ),
            _buildFeatureItem(
              Icons.filter_alt,
              'Specialty Search',
              'Filter doctors by specialty to find the right care',
            ),
            _buildFeatureItem(
              Icons.person,
              'Doctor Profiles',
              'View detailed profiles with reviews and ratings',
            ),
            _buildFeatureItem(
              Icons.calendar_today,
              'Book Appointments',
              'Schedule appointments directly through the app',
            ),
            _buildFeatureItem(
              Icons.shield,
              'Insurance Information',
              'See which doctors accept medical insurance in Botswana',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return const Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.account_circle, size: 50, color: Colors.blue),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'NB22000934',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    Text(
                      'COMP 302 - Data Structures and Algorithms',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'If you have any questions, feedback, or suggestions, please feel free to contact us:',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('support@doctorfinder.com'),
              subtitle: const Text('Email'),
              onTap: () => _launchEmail('support@doctorfinder.com'),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('+267 12345678'),
              subtitle: const Text('Phone'),
              onTap: () => _launchPhone('+26712345678'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
          Text('© 2025 Doctor Finder. All rights reserved.', style: TextStyle(color: Colors.grey)),
          Text(
            'This application was developed as part of a university project.',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}