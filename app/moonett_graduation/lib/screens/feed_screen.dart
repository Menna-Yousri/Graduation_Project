import 'package:flutter/material.dart';
import 'nutrition_guide.dart';
import 'nutritionadjst.dart';
import 'Topfeed.dart';

class NutritionFormScreen extends StatefulWidget {
  const NutritionFormScreen({super.key});

  @override
  State<NutritionFormScreen> createState() => _NutritionFormScreenState();
}

class _NutritionFormScreenState extends State<NutritionFormScreen> {
  String cowType = 'Dairy';
  bool? isPregnant;
  bool? isHealthy;
  String selectedBreed = '';
  String selectedActivity = '';
  String selectedSeason = '';
  String _selectedTab = 'Home';

  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final milkController = TextEditingController();
  final currentFeedController = TextEditingController();

  final List<String> breedOptions = ['Holstein', 'Jersey', 'Angus'];
  final List<String> activityOptions = ['Low', 'Medium', 'High'];
  final List<String> seasonOptions = ['Winter', 'Summer', 'Spring', 'Autumn'];

  void _onTabSelect(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F9),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 130),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF9F9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF40434D),
                      blurRadius: 8,
                      offset: Offset(0, 0),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCowTypeCard(),
                      _buildInputCard('assets/icons/age.png', 'Age (Years)', ageController),
                      _buildInputCard('assets/icons/weight.png', 'Weight (Kg)', weightController),
                      _buildInputCard('assets/icons/milk.png', 'Milk Yield (liters/day)', milkController),
                      _buildPregnantCard(),
                      _buildDropdownCard('assets/icons/breed.png', 'Breed', selectedBreed, breedOptions, (val) => setState(() => selectedBreed = val)),
                      _buildDropdownCard('assets/icons/activity_level.png', 'Activity Level', selectedActivity, activityOptions, (val) => setState(() => selectedActivity = val)),
                      _buildHealthStatusCard(),
                      _buildDropdownCard('assets/icons/seson.png', 'Season', selectedSeason, seasonOptions, (val) => setState(() => selectedSeason = val)),
                      _buildFeedCard(),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            _buildButton('Cow Nutrition Guide', () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FeedPlanScreen()));
                            }),
                            const SizedBox(height: 12),
                            _buildButton('Nutrition Adjustment', () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => NutritionAdjustmentScreen()));
                            }),
                            const SizedBox(height: 12),
                            _buildButton('Top Feed Recommender', () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TopFeedRecommenderScreen()));
                            }),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 24,
                    child: Container(
                      width: 34,
                      height: 34,
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          'assets/icons/back.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Feed Inputs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
          _buildNavIcon('Home', isHome: true),
          _buildNavIcon('Camera'),
          _buildNavIcon('Feed'),
          _buildNavIcon('Chat'),
          _buildNavIcon('More'),
        ],
      ),
    );
  }

  Widget _buildCowTypeCard() => _buildRadioRowCard('assets/icons/cowtype.png', 'Cow Type', ['Dairy', 'Beef'], cowType, (val) => setState(() => cowType = val));

  Widget _buildPregnantCard() => _buildRadioRowCard(
    'assets/icons/pregnant.png',
    'Pregnant',
    ['Yes', 'No'],
    isPregnant == null ? '' : isPregnant! ? 'Yes' : 'No',
        (val) => setState(() => isPregnant = (val == 'Yes')),
  );

  Widget _buildHealthStatusCard() => _buildRadioRowCard(
    'assets/icons/healths.png',
    'Health Status',
    ['Healthy', 'Sick'],
    isHealthy == null ? '' : isHealthy! ? 'Healthy' : 'Sick',
        (val) => setState(() => isHealthy = (val == 'Healthy')),
  );

  Widget _buildInputCard(String iconPath, String hint, TextEditingController controller) => Container(
    width: 320,
    height: 80,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: _boxDecoration(),
    child: Row(
      children: [
        Image.asset(iconPath, height: 24),
        const SizedBox(width: 12),
        Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: hint, border: InputBorder.none))),
      ],
    ),
  );

  Widget _buildDropdownCard(String iconPath, String hint, String selectedValue, List<String> options, Function(String) onChanged) => Container(
    width: 320,
    height: 80,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: _boxDecoration(),
    child: Row(
      children: [
        Image.asset(iconPath, height: 24),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String>(
            value: selectedValue.isEmpty ? null : selectedValue,
            hint: Text(hint),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (val) => onChanged(val!),
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
        ),
      ],
    ),
  );

  Widget _buildFeedCard() => Container(
    width: 320,
    height: 212,
    margin: const EdgeInsets.only(bottom: 24),
    padding: const EdgeInsets.all(12),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/icons/currfeed.png', height: 20),
            const SizedBox(width: 8),
            const Text("Current Feed Used", style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 300,
          height: 156,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD9D6D6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: currentFeedController,
            maxLines: null,
            decoration: const InputDecoration(hintText: 'Enter current feed here', border: InputBorder.none),
          ),
        ),
      ],
    ),
  );

  Widget _buildButton(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 250,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1F7551),
        borderRadius: BorderRadius.circular(7.115),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    ),
  );

  Widget _buildRadioRowCard(String iconPath, String label, List<String> options, String selectedValue, Function(String) onChanged) => Container(
    width: 320,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Image.asset(iconPath, height: 20), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: options
              .map((option) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio(value: option, groupValue: selectedValue, onChanged: (val) => onChanged(val!), activeColor: const Color(0xFF1F7551)),
              Text(option, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
            ],
          ))
              .toList(),
        )
      ],
    ),
  );

  Widget _buildNavIcon(String label, {bool isHome = false}) {
    bool isActive = _selectedTab == label;
    String assetPath = isHome && isActive ? 'assets/icons/home3.png' : 'assets/icons/${label.toLowerCase()}.png';

    return GestureDetector(
      onTap: () => _onTabSelect(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: (isHome || !isActive)
                ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                : const ColorFilter.mode(Color(0xFF1F7551), BlendMode.srcIn),
            child: Image.asset(
              assetPath,
              width: 32,
              height: 32,
            ),
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

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        offset: Offset(4, 4),
        blurRadius: 16,
        spreadRadius: 4,
      )
    ],
  );
}
