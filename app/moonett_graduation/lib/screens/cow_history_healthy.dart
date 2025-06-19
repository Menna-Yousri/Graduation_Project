import 'package:flutter/material.dart';
import 'chat_screen.dart'; // ← تأكد إن اسم الملف صح

class CowHistoryHealthy extends StatelessWidget {
  final int cowId;

  const CowHistoryHealthy({required this.cowId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cow #$cowId History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Card(
              elevation: 6,
              margin: EdgeInsets.symmetric(horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 40),
                    SizedBox(height: 16),
                    Text(
                      "This cow has always\nbeen healthy.\nNo health issues\nrecorded.",
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatBotScreen()),
                );
              },
              child: Image.asset(
                'assets/images/bot.png',
                width: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
