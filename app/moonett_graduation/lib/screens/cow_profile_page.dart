import 'package:flutter/material.dart';
import 'chat_screen.dart'; // تأكدي إن الملف موجود ومسار الاستيراد صحيح

class CowProfilePage extends StatelessWidget {
  final String cowId;
  final String? diseaseOverride;
  final DateTime? dateTime;

  const CowProfilePage({
    super.key,
    required this.cowId,
    this.diseaseOverride,
    this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedCowId = cowId.replaceAll('#', '').trim();

    final String selectedDisease = diseaseOverride ??
        (['1', '5'].contains(normalizedCowId)
            ? 'mastitis'
            : ['7', '50', '1015', '730', '88'].contains(normalizedCowId)
            ? 'lumpy'
            : 'ketosis');

    final bool isMastitisCow = selectedDisease == 'mastitis';
    final bool isLumpySkinCow = selectedDisease == 'lumpy';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Cow #$cowId Profile",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMastitisCow || isLumpySkinCow)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMastitisCow ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isMastitisCow ? Icons.check_circle : Icons.close,
                      color: isMastitisCow ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMastitisCow ? "No ketosis" : "KETOSIS",
                      style: TextStyle(
                        color: isMastitisCow ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "ketosis",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            if (isMastitisCow)
              _buildMastitisReport(context)
            else if (isLumpySkinCow)
              _buildLumpySkinReport(context),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatBotScreen()),
                  );
                },
                child: Image.asset('assets/images/bot.png', width: 70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMastitisReport(BuildContext context) {
    return _buildReportContainer(
      context: context,
      title: "Health Report – Mastitis",
      description: "Inflammation of the udder due to bacterial infection.",
      causes: [
        "Bacterial Infection",
        "Poor hygiene",
        "Injuries to the teat",
        "Poor milking technique"
      ],
      symptoms: [
        "Swelling",
        "Redness",
        "Abnormal milk",
        "Pain reactions",
        "Temperature rise in udder"
      ],
      advice: "• Isolate affected quarter\n• Improve hygiene\n• Strip the udder gently",
    );
  }

  Widget _buildLumpySkinReport(BuildContext context) {
    return _buildReportContainer(
      context: context,
      title: "Health Report – Lumpy Skin",
      description:
      "A viral disease in cattle caused by the lumpy skin disease virus (LSDV), leading to nodules on the skin.",
      causes: [
        "Lumpy skin disease virus (LSDV)",
        "Insect bites (vectors)",
        "Contact with infected animals"
      ],
      symptoms: [
        "Nodules on skin",
        "Fever",
        "Swollen lymph nodes",
        "Loss of appetite"
      ],
      advice:
      "• Isolate infected cattle\n• Apply insect control\n• Use antibiotics for secondary infections",
    );
  }

  Widget _buildReportContainer({
    required BuildContext context,
    required String title,
    required String description,
    required List<String> causes,
    required List<String> symptoms,
    required String advice,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 6, spreadRadius: 1)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          const SizedBox(height: 8),
          if (dateTime != null) ...[
            Text("Date: ${dateTime!.toLocal().toString().split(' ')[0]}", style: TextStyle(fontSize: 18)),
            Text("Time: ${TimeOfDay.fromDateTime(dateTime!).format(context)}", style: TextStyle(fontSize: 18)),
          ],
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/cause.png', width: 40, height: 40),
                        const SizedBox(width: 8),
                        const Text("Causes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var item in causes)
                      Text("• $item", style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/symptom.png', width: 40, height: 40),
                        const SizedBox(width: 8),
                        const Text("Symptoms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var item in symptoms)
                      Text("• $item", style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/advice.png', width: 50, height: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Veterinary Advice",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(advice, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
