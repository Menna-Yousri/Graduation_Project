import 'package:flutter/material.dart';
import 'nutrition_guide.dart';
import 'nutritionadjst.dart';
import 'chat_screen.dart'; // تأكدي إن اسم الملف والكلاس صح

class TopFeedRecommenderScreen extends StatelessWidget {
  const TopFeedRecommenderScreen({super.key});

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
                  padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Top Feed Recommender',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Barlow',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Date: 2025-06-08", style: TextStyle(fontSize: 12)),
                        const Text("Time: 11:47 AM", style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 16),
                        _buildFeedCard(
                          title: "Cattle Fattening Feed – 18% Protein",
                          protein: "18%",
                          price: "13.6 EGP/kg",
                          link: "https://invest.egyprojects.info/price-feed-bag-50-kilograms",
                          isBest: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFeedCard(
                          title: "Super Fattening Starter – 23% Protein",
                          protein: "23%",
                          price: "20.1 EGP/kg",
                          link: "https://invest.egyprojects.info/price-feed-bag-50-kilograms",
                          isBest: false,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))
                            ],
                            color: Colors.white,
                          ),
                          child: const Text(
                            "Best value based on price. Request full ingredient details before purchase.",
                            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("General Notes",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
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
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("• ",
                                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black)),
                              Expanded(
                                child: Text(
                                  "These are current market suggestions. Always check ingredient composition with the supplier before choosing a feed product.",
                                  style: TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w300),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(child: _buildGreenButton(context, "Cow Nutrition Guide", const FeedPlanScreen())),
                        const SizedBox(height: 12),
                        Center(child: _buildGreenButton(context, "Nutrition Adjustment", const NutritionAdjustmentScreen())),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCard({
    required String title,
    required String protein,
    required String price,
    required String link,
    required bool isBest,
  }) {
    final card = Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isBest ? Border(left: BorderSide(color: const Color(0xFF00913C), width: 6)) : null,
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
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Protein:", style: TextStyle(color: Colors.black.withOpacity(0.6))),
              Text(protein, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text("Price:", style: TextStyle(color: Colors.black.withOpacity(0.6))),
              Text(price, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text("Ingredients Known: False", style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text("Matches Ideal Diet: False", style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          const Text(
            "Missing ingredient details to check if it matches the recommended formula.",
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            link,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );

    if (!isBest) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: -10,
          right: -10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF00913C),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Text(
              "The Best",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildGreenButton(BuildContext context, String text, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      child: Container(
        width: 250,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF1F7551),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
