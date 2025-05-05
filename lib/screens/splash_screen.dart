import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:doctor_finder_flutter/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Add delay for splash screen
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.isLoggedIn) {
          context.go('/home');
        } else {
          context.go('/auth');
        }
      }
    } catch (e) {
      print('Error in splash navigation: $e');
      if (mounted) {
        // Navigate to auth on error
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/fullLogo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.medical_services,
                  size: 150,
                  color: Colors.white,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Doctor Finder',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Detect your Doctors!',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 100),
            const Text(
              'Developed by yours truly: Mythreyan Manjesh Lal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const Text(
              'MM23019011',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}