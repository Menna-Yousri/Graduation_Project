import 'package:flutter/material.dart';
import 'nutrition_guide.dart';
import 'Topfeed.dart';
import 'chat_screen.dart'; // تأكدي من اسم الملف والكلاس

class NutritionAdjustmentScreen extends StatelessWidget {
  const NutritionAdjustmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
                child: Row(
                  children: [
                    Image.asset('assets/icons/back.png', width: 34, height: 34),
                    const SizedBox(width: 16),
                    const Text(
                      'Nutrition Adjustment',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Barlow',
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Date: 2025-06-08", style: TextStyle(fontSize: 12)),
                      const Text("Time: 11:47 AM", style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Image.asset('assets/icons/balance.png', width: 24),
                          const SizedBox(width: 8),
                          const Text('Balance Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBalanceCard(),
                      const SizedBox(height: 6),
                      const Text(
                        "The current diet keeps the cow healthy, but it’s missing some key nutrients especially for pregnant or milking cows. Protein is a bit high and might need reducing.",
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Image.asset('assets/icons/goodf.png', width: 24),
                          const SizedBox(width: 8),
                          const Text('Better Feed Plan', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildMiniCard("Roughage", "Alfalfa Hay", "6 kg / day", "Good for protein and fiber. Ensure it’s clean and dry."),
                      const SizedBox(height: 12),
                      _buildMiniCard("Concentrate", "Corn Grain", "2 kg / day", "Gives extra energy. Should be crushed to help digestion."),
                      const SizedBox(height: 12),
                      _buildMiniCard("Supplements", "Mineral Block", "0.05 kg / day", "Provides salts and important minerals. Keep it available all the time."),
                      const SizedBox(height: 12),
                      _buildMiniCard("Supplements", "Vitamin A, D, E Mix", "0.01 kg / day", "Helps with health and immunity. Add to food or water."),
                      const SizedBox(height: 12),
                      _buildMiniCard("Supplements", "Salt (NaCl)", "0.03 kg / day", "Needed for muscles and nerves to work well."),
                      const SizedBox(height: 12),
                      _buildMiniCard("Supplements", "Vegetable Oil", "0.1 kg / day", "Adds healthy fats and energy."),
                      const SizedBox(height: 12),
                      _buildMiniCard("Supplements", "Brewer’s Yeast", "0.02 kg / day", "Gives B vitamins and helps digestion."),
                      const SizedBox(height: 12),
                      _buildWaterCard("30.0 liters", "10–15°C", "Clean water should always be available. Water needs increase in hot weather.", "Farm supply"),
                      const SizedBox(height: 16),
                      _buildNotes(),
                      const SizedBox(height: 16),

                      // الزرين المعدلين:
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FeedPlanScreen()),
                            );
                          },
                          child: _buildGreenButton("Cow Nutrition Guide"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TopFeedRecommenderScreen()),
                            );
                          },
                          child: _buildGreenButton("Top Feed Recommender"),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // صورة الروبوت + التنقل إلى شاشة الـ Chat
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                    blurRadius: 32,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 39,
                    bottom: 36,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChatBotScreen()), // غيّري الاسم لو الكلاس مختلف
                        );
                      },
                      child: Image.asset(
                        'assets/icons/robot.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(4, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Balanced: False", style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text("Missing Nutrients:"),
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("• Salts"),
                Text("• Fats"),
                Text("• Vitamin B group"),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text("Extra Nutrients:"),
          Text("• Protein (might be too much depending on cow’s condition)"),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String title, String name, String amount, String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != "Supplements") Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          width: 300,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                offset: Offset(4, 4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabelValue("Name", name),
                  _buildLabelValue("Amount", amount),
                ],
              ),
              const SizedBox(height: 12),
              _buildLabelValue("Notes", notes),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterCard(String amount, String temp, String notes, String source) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(4, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabelValue("Daily Amount", amount),
              _buildLabelValue("Temperature", temp),
            ],
          ),
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
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(4, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: const Text(
        "- Now the feed has salts, fats, and Vitamin B.\n"
            "- Watch the cow and change amounts if needed.\n"
            "- Ask a vet or expert if unsure.",
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
      ),
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

  Widget _buildGreenButton(String text) {
    return Container(
      width: 250,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1F7551),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
