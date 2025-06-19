import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
//import 'screens/home_screen.dart';

void main() {
  runApp(const MooNetApp());
}

class MooNetApp extends StatelessWidget {
  const MooNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MooNet',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        //'/home': (context) => const HomeScreen(),
      },
    );
  }
}