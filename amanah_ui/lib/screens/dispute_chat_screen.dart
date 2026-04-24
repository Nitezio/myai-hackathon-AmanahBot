import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class DisputeChatScreen extends StatefulWidget {
  const DisputeChatScreen({super.key});

  @override
  State<DisputeChatScreen> createState() => _DisputeChatScreenState();
}

class _DisputeChatScreenState extends State<DisputeChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Greetings. I am Amanah AI Mediator. I've reviewed your transaction for 'Jordan 1 Retro High'. The seller has not provided tracking updates within the agreed 48h window.",
      "isAi": true,
    },
    {
      "text": "Would you like to initiate an autonomous refund protocol now?",
      "isAi": true,
    },
  ];
  bool _isLoading = false;

  void _handleSend() async {
    if (_controller.text.isEmpty || _isLoading) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({"text": userMessage, "isAi": false});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final result = await ApiService.raiseDispute(
        "TX-DEMO-123",
        userMessage,
        "No response from seller after 48h.",
        _messages.map((m) => "${m['isAi'] ? 'AI' : 'User'}: ${m['text']}").join("\n"),
      );

      setState(() {
        _messages.add({
          "text": result['ai_resolution']['reasoning'] ?? "Verdict reached: ${result['ai_resolution']['actionToTake']}",
          "isAi": true,
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "text": "Error connecting to AI Mediator. Please try again.",
          "isAi": true,
        });
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (Light Grey)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF3F4F6),
                  Color(0xFFE5E7EB),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(),
                _buildStatusBanner(),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const ChatBubble(text: "AI is analyzing case...", isAi: true, isTyping: true);
                      }
                      return ChatBubble(
                        text: _messages[index]["text"],
                        isAi: _messages[index]["isAi"],
                      );
                    },
                  ),
                ),
                
                _buildChatInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "AI MEDIATOR",
            style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1D1D1B)),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: const Color(0xFF1D1D1B).withValues(alpha: 0.2)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.gavel_rounded, color: Color(0xFF1D1D1B), size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "STATUS: ACTIVE MEDIATION",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1D1D1B), letterSpacing: 1),
                  ),
                  Text(
                    "Applying MY Consumer Act 1999 Section 12",
                    style: TextStyle(fontSize: 12, color: const Color(0xFF1D1D1B).withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120), // Extra bottom padding for floating nav
      child: GlassCard(
        borderRadius: 28,
        child: TextField(
          controller: _controller,
          onSubmitted: (_) => _handleSend(),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1B)),
          decoration: InputDecoration(
            hintText: "Message AI Mediator...",
            hintStyle: TextStyle(color: const Color(0xFF1D1D1B).withValues(alpha: 0.3), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(_isLoading ? Icons.hourglass_top : Icons.send_rounded, color: const Color(0xFF1D1D1B)),
                onPressed: _handleSend,
              ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isAi;
  final bool isTyping;
  const ChatBubble({super.key, required this.text, required this.isAi, this.isTyping = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isAi ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF1D1D1B),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 4 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 4),
          ),
          border: isAi ? Border.all(color: Colors.white.withValues(alpha: 0.3)) : null,
          boxShadow: [
            if (isAi)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text.replaceAll("**", ""), // Basic cleanup if needed
              style: TextStyle(
                color: isAi ? const Color(0xFF1D1D1B) : Colors.white,
                fontSize: 15,
                height: 1.5,
                fontWeight: isTyping ? FontWeight.w300 : FontWeight.normal,
                fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
