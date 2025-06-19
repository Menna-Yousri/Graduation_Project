import 'package:flutter/material.dart';
import 'veterinarian_home.dart';
import 'cow_history_sick.dart';
import 'cow_history_healthy.dart';

class CowListPage extends StatefulWidget {
  @override
  _CowListPageState createState() => _CowListPageState();
}

class _CowListPageState extends State<CowListPage> {
  final List<Map<String, dynamic>> cows = [
    {"id": "#1", "status": "Sick"},
    {"id": "#2", "status": "Healthy"},
    {"id": "#3", "status": "Healthy"},
    {"id": "#4", "status": "Healthy"},
    {"id": "#5", "status": "Sick"},
    {"id": "#6", "status": "Healthy"},
    {"id": "#7", "status": "Sick"},
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredCows = cows.where((cow) {
      return cow["id"].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => VetHomePage()),
            );
          },
        ),
        title: const Text(
          "Cow List",
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search by ID",
                  hintStyle: TextStyle(fontSize: 16),
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCows.length,
                itemBuilder: (context, index) {
                  final cow = filteredCows[index];
                  final isSick = cow["status"] == "Sick";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 8, offset: Offset(0, 3)),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => isSick
                                ? CowHistorySick(cowId: int.parse(cow["id"].replaceAll("#", "")))
                                : CowHistoryHealthy(cowId: int.parse(cow["id"].replaceAll("#", ""))),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSick ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cow ${cow["id"]}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cow["status"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSick ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
