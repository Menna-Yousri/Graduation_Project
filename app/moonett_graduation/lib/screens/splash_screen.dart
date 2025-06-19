import 'package:flutter/material.dart';
import 'login_page.dart'; // عدلي حسب المسار لو مختلف

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // تبدأ انيميشن الشريط
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _progress = 1.0;
      });
    });

    // بعد 3 ثواني تروحي للـ LoginPage
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // اللوجو + MooNet
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: size.width * 0.6, // أكبر من 0.5
                    child: Image.asset(
                      'assets/images/cow.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Moo',
                          style: TextStyle(
                            color: Color(0xFF1F7551),
                            fontSize: 34, // أكبر من 28
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        TextSpan(
                          text: 'Net',
                          style: TextStyle(
                            color: Color(0xFF1D83A6),
                            fontSize: 34, // أكبر من 28
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 4),

            // Progress Bar + Subtitle
            Column(
              children: [
                Container(
                  width: 260, // كان 200
                  height: 4,  // كان 2
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.grey[300],
                  ),
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    width: 260 * _progress,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: const Color(0xFF3C97E7),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'INTELLIGENT FARMING',
                  style: TextStyle(
                    color: Color(0xFF3C3F44),
                    fontSize: 16, // كان 14
                    fontWeight: FontWeight.w700, // بولد أكتر
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
