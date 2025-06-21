import 'package:flutter/material.dart';
import 'cow_profile_page.dart';
import 'environment_screen.dart';
import 'chat_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  final List<Map<String, dynamic>> alerts = const [
    {'title': 'Cow #1 is sick', 'time': '2 hours ago', 'icon': 'assets/icons/warning_1.png'},
    {'title': 'High temperature', 'time': '5 hours ago', 'icon': 'assets/icons/caution_1.png'},
    {'title': 'Cow #50 is sick', 'time': '3 days ago', 'icon': 'assets/icons/warning_1.png'},
    {'title': 'Cow #1015 is sick', 'time': '1 week ago', 'icon': 'assets/icons/warning_1.png'},
    {'title': 'Cow #7 is sick', 'time': '3 weeks ago', 'icon': 'assets/icons/warning_1.png'},
    {'title': 'No light', 'time': '1 month ago', 'icon': 'assets/icons/caution_1.png'},
    {'title': 'Cow #5 is sick', 'time': '2 months ago', 'icon': 'assets/icons/warning_1.png'},
    {'title': 'High gas', 'time': '5 months ago', 'icon': 'assets/icons/caution_1.png'},
    {'title': 'High temperature', 'time': '5 months ago', 'icon': 'assets/icons/caution_1.png'},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        'Alerts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Barlow',
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120), // padding from bottom علشان نسيب مساحة للروبوت
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return GestureDetector(
                        onTap: () {
                          final title = alert['title'].toString().toLowerCase();
                          if (title.contains('cow #')) {
                            final cowId = RegExp(r'Cow #(\d+)')
                                .firstMatch(alert['title'])!
                                .group(1)!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CowProfilePage(cowId: cowId),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EnvironmentScreen(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F1F1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                alert['icon'],
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Inter',
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        alert['time'],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w300,
                                          fontFamily: 'Inter',
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              right: -5,
              bottom: -2,
              child: Container(
                width: 384,
                height: 96,
                color: Colors.white,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 39),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatBotScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/icons/robot.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
