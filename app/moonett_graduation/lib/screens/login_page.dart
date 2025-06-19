import 'package:flutter/material.dart';
import 'veterinarian_home.dart';
import 'manager_home .dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(), // خليها تبدأ من شاشة اللوجين
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedRole = 0; // 0 = Veterinarian, 1 = Manager

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ListView(
          children: [
            const SizedBox(height: 0),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: Image.asset('assets/images/cow.png'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome to MooNet',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Continue as:',
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: 0,
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          const Text('Veterinarian', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          Radio(
                            value: 1,
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          const Text('Manager', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text('Forgot Password?', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // هنا بيتم التوجيه بناءً على الدور المختار
                      if (_selectedRole == 0) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>  VetHomePage()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeManagerScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F7551),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(fontSize: 20)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('Sign UP', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
