import 'package:flutter/material.dart';
import 'dart:math';
import 'cow_profile_page.dart';
import 'chat_screen.dart'; // تأكدي إن الملف موجود والمسار صح

class CowHistorySick extends StatelessWidget {
  final int cowId;

  CowHistorySick({required this.cowId});

  final List<DateTime> entries = List.generate(
    Random().nextInt(6) + 2,
        (index) => DateTime.now().subtract(Duration(days: index * 2, hours: index * 3)),
  );

  final List<String> possibleDiseases = ["mastitis", "lumpy"];

  String getRandomDisease() {
    final rand = Random();
    return possibleDiseases[rand.nextInt(possibleDiseases.length)];
  }

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
        title: Text('Cow #$cowId History',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final disease = getRandomDisease();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text("Date: ${entry.toLocal().toString().split(' ')[0]}"),
                    subtitle: Text("Time: ${TimeOfDay.fromDateTime(entry).format(context)}"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CowProfilePage(
                            cowId: "$cowId-$index",
                            diseaseOverride: disease,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatBotScreen()),
                );
              },
              child: Image.asset('assets/images/bot.png', width: 60),
            ),
          )
        ],
      ),
    );
  }
}
