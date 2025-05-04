import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_finder_flutter/providers/auth_provider.dart';
import 'package:doctor_finder_flutter/models/appointment_model.dart';
import 'package:doctor_finder_flutter/services/firestore_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<AppointmentModel> _appointments = [];
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationPermission = true;

  @override
  void initState() {
    super.initState();
    _loadUserAppointments();
  }

  void _loadUserAppointments() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      FirestoreService.getUserAppointmentsStream(user.id).listen((appointments) {
        if (mounted) {
          setState(() {
            _appointments = appointments.take(5).toList();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isLoggedIn) {
            return _buildGuestView();
          }

          return ListView(
            children: [
              _buildUserHeader(authProvider.currentUser!),
              _buildAppointmentsSection(),
              _buildSettingsSection(),
              _buildAccountSection(),
              _buildFooter(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Not logged in',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Log in to view your profile, appointments, and save preferences.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => context.push('/auth'),
              child: const Text('Log In / Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(user) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              user.name?.substring(0, 2).toUpperCase() ??
                  user.email?.substring(0, 2).toUpperCase() ?? 'U',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.name ?? 'User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            user.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _editProfile(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_appointments.isEmpty)
              _buildEmptyAppointments()
            else
              ..._appointments.map(_buildAppointmentItem),
            if (_appointments.isNotEmpty)
              TextButton(
                onPressed: () => _viewAllAppointments(),
                child: const Text('View All Appointments'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAppointments() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.calendar_month, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('No appointments yet'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => context.push('/home'),
              child: const Text('Find a Doctor'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(AppointmentModel appointment) {
    final appointmentDate = DateFormat('dd MMM yyyy, HH:mm').format(appointment.appointmentDateTime);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(appointment.status),
        child: const Icon(Icons.calendar_today, color: Colors.white),
      ),
      title: Text(appointment.doctorName),
      subtitle: Text('$appointmentDate\n${appointment.reason}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(appointment.status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          appointment.status.toString().split('.').last.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
      isThreeLine: true,
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Receive notifications about appointments'),
              secondary: const Icon(Icons.notifications),
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              secondary: const Icon(Icons.dark_mode),
              value: _darkModeEnabled,
              onChanged: (value) => setState(() => _darkModeEnabled = value),
            ),
            SwitchListTile(
              title: const Text('Location Access'),
              subtitle: const Text('Allow access to your location'),
              secondary: const Icon(Icons.location_on),
              value: _locationPermission,
              onChanged: (value) => setState(() => _locationPermission = value),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                onPressed: _savePreferences,
                child: const Text('Save Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () => _changePassword(),
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Privacy Policy'),
              onTap: () => _openPrivacyPolicy(),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              onTap: () => _openTermsOfService(),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () => context.push('/profile/about'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: _handleLogout,
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
          Text('© 2025 Doctor Finder', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.blue;
    }
  }

  void _editProfile() {
    // Implement edit profile functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon')),
    );
  }

  void _viewAllAppointments() {
    // Implement view all appointments functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View all appointments feature coming soon')),
    );
  }

  void _changePassword() {
    // Implement change password functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon')),
    );
  }

  void _openPrivacyPolicy() {
    // Implement privacy policy navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy feature coming soon')),
    );
  }

  void _openTermsOfService() {
    // Implement terms of service navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service feature coming soon')),
    );
  }

  void _savePreferences() async {
    try {
      // Save preferences using shared_preferences package
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save preferences')),
      );
    }
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              context.go('/auth');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}