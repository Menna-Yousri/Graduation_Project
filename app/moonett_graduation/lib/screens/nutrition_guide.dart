import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'nutritionadjst.dart';
import 'Topfeed.dart';

class FeedPlanScreen extends StatelessWidget {
  const FeedPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Top bar
              Container(
                padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/back.png',
                      width: 34,
                      height: 34,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Cow Nutrition Guide',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 2. Middle body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Date: 2025-06-08", style: TextStyle(fontSize: 12)),
                      const Text("Time: 11:47 AM", style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 16),
                      ..._buildSection("Roughage", "Alfalfa Hay", "12 kg / day", "18.2%", "25.4%", "2.4 Mcal", "High-quality alfalfa hay provides excellent protein content and digestibility. Feed in multiple portions throughout the day.", "Meadowbrook Farm (Lot #A-2435)"),
                      const SizedBox(height: 16),
                      ..._buildSection("Concentrate", "Dairy Mix #42", "8.5 kg / day", "22.5%", "8.7%", "3.2 Mcal", "Custom grain mix formulated for lactating dairy cows. Divide into 3-4 feedings per day based on milk production.", "Valley Nutrition Services (Batch#F-8721)"),
                      const SizedBox(height: 16),
                      const Text("Supplements", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildSuppCard("Vitamin(A, D, E)", "0.01 kg / day", null, null, null, "Vitamins are important for the cow’s health and immune system. Can be added to feed or water.", "Veterinary Clinic\nLivestock Supply Store"),
                      const SizedBox(height: 12),
                      _buildSuppCard("Mineral Block", "0.05 kg / day", null, null, null, "Provides essential minerals like calcium and phosphorus. Should always be available to the cow.", "Livestock Supply Store\nOnline Retailer"),
                      const SizedBox(height: 16),
                      const Text("Water", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildWaterCard("80–115 liters", "10–15°C", "Fresh, clean water should be available at all times. Water consumption increases with milk production and ambient temperature.", "Well water (tested quarterly for quality)"),
                      const SizedBox(height: 16),
                      const Text("General Notes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildNotes(),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            _buildGreenButton(
                              "Nutrition Adjustment",
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NutritionAdjustmentScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildGreenButton(
                              "Top Feed Recommender",
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TopFeedRecommenderScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 180), // Space for white container
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. White container at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 32,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 39, bottom: 36),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatBotScreen()),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/robot.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSection(String title, String name, String amount, String protein, String fiber, String energy, String notes, String source) {
    return [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        width: 300,
        padding: const EdgeInsets.all(12),
        decoration: _boxStyle(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildLabelValue("Name", name), _buildLabelValue("Amount", amount)]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildLabelValue("Protein", protein), _buildLabelValue("Fiber", fiber), _buildLabelValue("Energy", energy)]),
            const SizedBox(height: 12),
            _buildLabelValue("Notes", notes),
            const SizedBox(height: 8),
            _buildLabelValue("Source", source),
          ],
        ),
      )
    ];
  }

  Widget _buildSuppCard(String name, String amount, String? protein, String? fiber, String? energy, String notes, String source) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildLabelValue("Name", name), _buildLabelValue("Amount", amount)]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildLabelValue("Protein", protein), _buildLabelValue("Fiber", fiber), _buildLabelValue("Energy", energy)]),
          const SizedBox(height: 12),
          _buildLabelValue("Notes", notes),
          const SizedBox(height: 8),
          _buildLabelValue("Source", source),
        ],
      ),
    );
  }

  Widget _buildWaterCard(String dailyAmount, String temp, String notes, String source) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: _boxStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildLabelValue("Daily Amount", dailyAmount), _buildLabelValue("Temperature", temp)]),
          const SizedBox(height: 12),
          _buildLabelValue("Notes", notes),
          const SizedBox(height: 8),
          _buildLabelValue("Source", source),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: _boxStyle(),
      child: const Text(
        "- Feed should be distributed in multiple portions...\n"
            "- Monitor body condition score weekly...\n"
            "- Transition period (3 weeks pre/post calving)...\n"
            "- Ensure salt blocks are available...\n"
            "- Consult veterinarian before major changes.",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Color(0xFF333333)),
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(4, 4), blurRadius: 16)],
    );
  }

  Widget _buildLabelValue(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF797979), fontWeight: FontWeight.w300)),
        const SizedBox(height: 2),
        Text(value ?? 'null', style: const TextStyle(fontSize: 14, color: Color(0xFF333333), fontWeight: FontWeight.w300)),
      ],
    );
  }

  Widget _buildGreenButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1F7551),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
