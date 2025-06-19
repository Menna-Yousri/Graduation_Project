import 'package:flutter/material.dart';
import 'splash_screen.dart'; // تأكدي من المسار
import 'cow_list.dart';
import 'cow_profile_page.dart'; // استيراد صفحة البروفايل

void main() {
  runApp(VetApp());
}

class VetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VetHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VetHomePage extends StatelessWidget {
  final List<Map<String, String>> alerts = [
    {'id': '#1', 'time': '2 hours ago'},
    {'id': '#7', 'time': '5 hours ago'},
    {'id': '#50', 'time': '3 days ago'},
    {'id': '#1015', 'time': '1 week ago'},
    {'id': '#730', 'time': '3 weeks ago'},
    {'id': '#88', 'time': '1 month ago'},
  ];

  final Color lightGray = Color(0xFFF3F1F1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const VetDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/Empty.png'),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Hi Veterinarian!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: CowCard(
                      imagePath: 'assets/images/normal.png',
                      label: 'Total Cows',
                      count: '1150',
                      color: lightGray,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CowCard(
                      imagePath: 'assets/images/sick.png',
                      label: 'Sick Cows',
                      count: '43',
                      color: lightGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return AlertCard(
                          cowId: alert['id']!,
                          time: alert['time']!,
                          backgroundColor: lightGray,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CowListPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D83A6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Health',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class CowCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final String count;
  final Color color;

  CowCard({
    required this.imagePath,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(label, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final String cowId;
  final String time;
  final Color backgroundColor;

  AlertCard({
    required this.cowId,
    required this.time,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CowProfilePage(cowId: cowId)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/alerts/sick_alter.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cow $cowId is sick',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VetDrawer extends StatelessWidget {
  const VetDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => VetHomePage()),
                );
              },
              child: const ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/Empty.png'),
                ),
                title: Text(
                  'Veterinarian',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const Divider(thickness: 1.5),
            const DrawerItem(title: 'Settings'),
            const Divider(thickness: 1.5),
            const DrawerItem(title: 'FAQs'),
            const Divider(thickness: 1.5),
            const DrawerItem(title: 'Help Center'),
            const Divider(thickness: 1.5),
            const DrawerItem(title: 'Language'),
            const Divider(thickness: 1.5),
            const DrawerItem(title: 'Contact us'),
            const Divider(thickness: 1.5),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F7551),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;

  const DrawerItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
