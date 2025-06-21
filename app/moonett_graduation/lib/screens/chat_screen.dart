import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(text);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ==== Chat Header + Bubble + Messages ====
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Chat Bot',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Barlow',
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ==== Note Bubble ====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: 256,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/icons/note.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Each question is answered separately. It's recommended to clarify your question fully each time.",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              color: Color(0xFF232323),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==== Chat Messages ====
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD0F0E8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _messages[index],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80), // space for input
              ],
            ),
          ),

          // ==== Input Bar ====
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFBF9F9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A40434D),
                    blurRadius: 8,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type here...",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        'assets/icons/send.png',
                        width: 25,
                        height: 25,
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
}
