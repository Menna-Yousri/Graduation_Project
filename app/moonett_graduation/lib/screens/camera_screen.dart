import 'package:flutter/material.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  String _selectedTab = 'Camera';

  void _onTabSelect(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header Row with Back Arrow + Centered Title
            Row(
              children: [
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text(
                  'Live Camera',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Barlow',
                    color: Colors.black,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),

            const SizedBox(height: 24),

            // Image Content
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icons/ms_normal.png',
                width: 343,
                height: 512,
                fit: BoxFit.cover,
              ),
            ),
          ],
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
            _buildNavIcon('Home', 'assets/icons/home.png', 'assets/icons/home3.png'),
            _buildNavIcon('Camera', 'assets/icons/camera.png'),
            _buildNavIcon('Feed', 'assets/icons/feed.png'),
            _buildNavIcon('Chat', 'assets/icons/chat.png'),
            _buildNavIcon('More', 'assets/icons/more.png'),
          ],
        ),
      ),
    );
  }

  // 🟩 Navigation icon builder with optional selectedImage
  Widget _buildNavIcon(String label, String assetPath, [String? selectedPath]) {
    bool isActive = _selectedTab == label;
    return GestureDetector(
      onTap: () => _onTabSelect(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isActive && selectedPath != null ? selectedPath : assetPath,
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
