import 'package:flutter/material.dart';
import 'manager_home .dart'; // تأكدي إن اسم الملف صح
import 'splash_screen.dart';

class MoreManagerScreen extends StatefulWidget {
  const MoreManagerScreen({super.key});

  @override
  State<MoreManagerScreen> createState() => _MoreManagerScreenState();
}

class _MoreManagerScreenState extends State<MoreManagerScreen> {
  String _selectedTab = 'More';

  void _onTabSelect(String tab) {
    setState(() {
      _selectedTab = tab;
    });

    if (tab == 'Home') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeManagerScreen()));
    }
    // باقي الصفحات لو هتتنقل لها ضيفها هنا بنفس الطريقة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeManagerScreen()),
                      );
                    },
                    child: Image.asset('assets/icons/avatar.png', width: 48, height: 48),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Manager',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildOption('Settings'),
              _buildOption('FAQs'),
              _buildOption('Help Center'),
              _buildOption('Language'),
              _buildOption('Contact us'),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                    );
                  },
                  child: Container(
                    width: 250,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F7551),
                      borderRadius: BorderRadius.circular(7.115),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
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
            _buildNavIcon('Home', 'assets/icons/home.png', selectedPath: 'assets/icons/home3.png'),
            _buildNavIcon('Camera', 'assets/icons/camera.png'),
            _buildNavIcon('Feed', 'assets/icons/feed.png'),
            _buildNavIcon('Chat', 'assets/icons/chat.png'),
            _buildNavIcon('More', 'assets/icons/more.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title) {
    return Container(
      width: 324,
      height: 56,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(left: 44.5, top: 16.5, bottom: 15.6, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border.all(color: const Color(0xFFDCDCDC), width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              color: Color(0xFF333333),
            ),
          ),
          Image.asset(
            'assets/icons/next.png',
            width: 16.258,
            height: 9.474,
            color: const Color(0xFF4E4E4E),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(String label, String assetPath, {String? selectedPath}) {
    bool isActive = _selectedTab == label;
    return GestureDetector(
      onTap: () => _onTabSelect(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            selectedPath != null && isActive ? selectedPath : assetPath,
            width: 32,
            height: 32,
            color: selectedPath == null && isActive ? const Color(0xFF1F7551) : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF1F7551) : const Color(0xFF333333),
            ),
          )
        ],
      ),
    );
  }
}
