import 'package:flutter/material.dart';
import 'chat_screen.dart'; // ضروري تأكدي إن الملف والكلاس موجودين

class EnvironmentScreen extends StatelessWidget {
  const EnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Environment status',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Barlow',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Environment Cards
                Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: [
                    _buildEnvCard('Temperature', 'High(40°C)', 'assets/icons/hot.png', const Color(0xFFD40808)),
                    _buildEnvCard('Light Level', 'Bright', 'assets/icons/sun.png', const Color(0xFF00913C)),
                    _buildEnvCard('Water Level', 'Medium', 'assets/icons/water.png', const Color(0xFFFFB800)),
                    _buildEnvCard('Water PH', 'Balanced', 'assets/icons/ph.png', const Color(0xFF00913C)),
                    _buildEnvCard('Ammonia Gaz', 'High', 'assets/icons/gas.png', const Color(0xFFD40808), width: 217),
                  ],
                ),

                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Alerts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildAlertCard('High temperature', '5 hours ago'),
                _buildAlertCard('No light', '1 month ago'),
                _buildAlertCard('High gas', '5 months ago'),
                _buildAlertCard('Alkaline PH', '8 months ago'),

                const SizedBox(height: 64),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatBotScreen()),
                        );
                      },
                      child: Image.asset('assets/icons/robot.png'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildEnvCard(String title, String value, String iconPath, Color color, {double width = 150}) {
    return Stack(
      children: [
        Container(
          width: width,
          height: 72,
          padding: const EdgeInsets.only(left: 40, right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Inter',
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: color,
            ),
          ),
        ),
        Positioned(
          left: 8,
          top: 18,
          child: Image.asset(
            iconPath,
            width: 32,
            height: 32,
          ),
        ),
      ],
    );
  }

  static Widget _buildAlertCard(String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12),
      child: Container(
        width: 257,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F1F1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/icons/caution_1.png', width: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Inter',
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
