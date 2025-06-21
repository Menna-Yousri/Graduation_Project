import 'package:flutter/material.dart';
import 'alerts_screen.dart';
import 'cow_list.dart';
import 'environment_screen.dart';
import 'cow_profile_page.dart';
import 'camera_screen.dart';
import 'feed_screen.dart';
import 'chat_screen.dart';
import 'more_screen.dart';

class HomeManagerScreen extends StatefulWidget {
  const HomeManagerScreen({super.key});

  @override
  State<HomeManagerScreen> createState() => _HomeManagerScreenState();
}

class _HomeManagerScreenState extends State<HomeManagerScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const LiveCameraScreen(),
    const NutritionFormScreen(),
    const ChatBotScreen(),
    const MoreManagerScreen(),
  ];

  void _onNavTapped(int index) {
    if (index == 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _screens[index - 1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // <<< Added scroll
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/icons/avatar.png', height: 28),
                        const SizedBox(width: 8),
                        const Text(
                          'Hi Manager!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AlertsScreen()),
                        );
                      },
                      child: Image.asset('assets/icons/notification_bell.png', height: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cards layout
                Column(
                  children: [
                    _buildCowCardFullWidth('1150', 'Total Cows', 'assets/icons/cow.png'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCowCard('738', 'Pregnant Cows', 'assets/images/pregnant.png'),
                        _buildCowCard('43', 'Sick Cows', 'assets/icons/health_leaf.png'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCowCard('Dairy', 'Farm Type', 'assets/icons/milk_bottle.png'),
                        _buildCowCard('32', 'Farm Size km²', 'assets/icons/barn_trees.png'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  'Recent Alerts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildAlertCard(context, 'Cow #1 is sick', '2 hours ago', 'assets/icons/warning_1.png'),
                const SizedBox(height: 12),
                _buildAlertCard(context, 'High temperature', '5 hours ago', 'assets/icons/caution_1.png'),
                const SizedBox(height: 12),
                _buildAlertCard(context, 'Cow #7 is sick', '9 hours ago', 'assets/icons/warning_1.png'),
                const SizedBox(height: 20),

                // Buttons below alerts
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CowListPage()),
                          );
                        },
                        child: _buildRoundedButton('Health', const Color(0xFF1D83A6)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EnvironmentScreen()),
                          );
                        },
                        child: _buildRoundedButton('Environment', const Color(0xFF1F7551)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BottomIcon(path: 'assets/icons/home.png', label: 'Home', onTap: () => _onNavTapped(0)),
            BottomIcon(path: 'assets/icons/camera.png', label: 'Camera', onTap: () => _onNavTapped(1)),
            BottomIcon(path: 'assets/icons/feed.png', label: 'Feed', onTap: () => _onNavTapped(2)),
            BottomIcon(path: 'assets/icons/chat.png', label: 'Chat', onTap: () => _onNavTapped(3)),
            BottomIcon(path: 'assets/icons/more.png', label: 'More', onTap: () => _onNavTapped(4)),
          ],
        ),
      ),
    );
  }

  Widget _buildCowCard(String number, String label, String iconPath) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1F1),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 48, height: 48), // enlarged
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              fontFamily: 'Inter',
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCowCardFullWidth(String number, String label, String iconPath) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1F1),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 48, height: 48),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Inter',
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, String title, String time, String iconPath) {
    return GestureDetector(
      onTap: () {
        if (title.toLowerCase().contains('cow #')) {
          final cowId = RegExp(r'Cow #(\d+)').firstMatch(title)?.group(1);
          if (cowId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CowProfilePage(cowId: cowId)),
            );
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EnvironmentScreen()),
          );
        }
      },
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F1F1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(iconPath, height: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF454545))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedButton(String label, Color bgColor) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7.115),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class BottomIcon extends StatelessWidget {
  final String path;
  final String label;
  final VoidCallback onTap;

  const BottomIcon({super.key, required this.path, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(path, height: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF333333))),
        ],
      ),
    );
  }
}
