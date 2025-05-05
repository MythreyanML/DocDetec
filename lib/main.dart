import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:doctor_finder_flutter/core/theme/app_theme.dart';
import 'package:doctor_finder_flutter/firebase_options.dart';
import 'package:doctor_finder_flutter/providers/auth_provider.dart';
import 'package:doctor_finder_flutter/providers/doctor_provider.dart';
import 'package:doctor_finder_flutter/providers/appointment_provider.dart';
import 'package:doctor_finder_flutter/providers/review_provider.dart';
import 'package:doctor_finder_flutter/router/app_router.dart';
import 'package:doctor_finder_flutter/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Then initialize Firebase services
    await FirebaseService.initialize();

    print('Firebase and Firebase services initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DoctorProvider>(
          create: (_) => DoctorProvider(),
          update: (_, auth, doctorProvider) => doctorProvider ?? DoctorProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>(
          create: (_) => AppointmentProvider(),
          update: (_, auth, appointmentProvider) => appointmentProvider ?? AppointmentProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ReviewProvider>(
          create: (_) => ReviewProvider(),
          update: (_, auth, reviewProvider) => reviewProvider ?? ReviewProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Doctor Finder',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}