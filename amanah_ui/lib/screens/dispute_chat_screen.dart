import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../services/demo_state.dart';
import '../widgets/glass_card.dart';

class DisputeChatScreen extends StatefulWidget {
  const DisputeChatScreen({super.key});

  @override
  State<DisputeChatScreen> createState() => _DisputeChatScreenState();
}

class _DisputeChatScreenState extends State<DisputeChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _escrowId;
  String _itemName = "";
  String _itemPrice = "";
  String _bannerTitle = "NO ACTIVE CASE";
  String _bannerSubtitle = "Open Buyer Hub first";

  @override
  void initState() {
    super.initState();
    _loadEscrowContext();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _loadEscrowContext() async {
    final id = DemoState.activeEscrowId;
    if (id == null || id.isEmpty) {
      setState(() {
        _messages.add({
          "text": "Welcome. I am the Amanah AI Mediator.\n\nPlease open a transaction in the Buyer Hub first, then return here to raise a dispute.",
          "isAi": true,
        });
      });
      return;
    }

    _escrowId = id;

    try {
      final doc = await FirebaseFirestore.instance.collection('escrows').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        _itemName = data['item'] ?? "Unknown Item";
        _itemPrice = ((data['price'] ?? 0) as num).toStringAsFixed(2);
        final status = data['status'] ?? "Unknown";

        setState(() {
          _bannerTitle = "CASE: $_itemName \u2022 RM $_itemPrice";
          _bannerSubtitle = "Transaction: $id \u2022 Status: $status";
          _messages.addAll([
            {
              "text": "I've loaded transaction [$id] for '$_itemName' (RM $_itemPrice).\n\nCurrent status: $status. I have access to the full transaction log. What is your complaint?",
              "isAi": true,
            },
            {
              "text": "I paid RM $_itemPrice for '$_itemName' but the seller has not delivered the item after 48 hours.",
              "isAi": false,
            },
            {
              "text": "Complaint recorded regarding '$_itemName' (RM $_itemPrice).\n\nI will apply the Malaysian Consumer Protection Act 1999 to mediate. Would you like me to proceed with the autonomous verdict?",
              "isAi": true,
            },
          ]);
        });
      } else {
        setState(() {
          _messages.add({
            "text": "Transaction [$id] not found in our records. Please verify the escrow ID in the Buyer Hub.",
            "isAi": true,
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "text": "AI Mediator ready. Could not load transaction context. Please describe your dispute below.",
          "isAi": true,
        });
      });
    }
  }

  void _handleSend() async {
    if (_controller.text.isEmpty || _isLoading) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({"text": userMessage, "isAi": false});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final result = await ApiService.raiseDispute(
        _escrowId ?? "TX-DEMO-123",
        userMessage,
        "No response from seller after 48h.",
        _messages.map((m) => "${m['isAi'] ? 'AI Mediator' : 'Buyer'}: ${m['text']}").join("\n"),
      );

      final resolution = result['ai_resolution'] ?? {};
      final reasoning = resolution['reasoning'] ?? "Verdict has been reached.";
      final action = resolution['actionToTake'] ?? "PENDING";
      final winner = resolution['winner'] ?? "N/A";

      String actionText = action == "REFUND_BUYER"
          ? "\u26a1 VERDICT: REFUND initiated to buyer."
          : "\u2705 VERDICT: Funds RELEASED to seller.";

      setState(() {
        _messages.add({
          "text": "$reasoning\n\nRuling: $winner\n$actionText",
          "isAi": true,
        });
        _isLoading = false;
      });
      _scrollToBottom();
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
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
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
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const ChatBubble(text: "Analyzing case with AI...", isAi: true, isTyping: true);
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
          if (_escrowId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: const Text("LIVE", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
                  Text(
                    _bannerTitle,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF1D1D1B), letterSpacing: 1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _bannerSubtitle,
                    style: TextStyle(fontSize: 11, color: const Color(0xFF1D1D1B).withOpacity(0.4)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      child: GlassCard(
        borderRadius: 28,
        child: TextField(
          controller: _controller,
          onSubmitted: (_) => _handleSend(),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1B)),
          decoration: InputDecoration(
            hintText: _escrowId != null ? "Message AI Mediator..." : "Open Buyer Hub first...",
            hintStyle: TextStyle(color: const Color(0xFF1D1D1B).withOpacity(0.3), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(_isLoading ? Icons.hourglass_top : Icons.send_rounded, color: const Color(0xFF1D1D1B)),
                onPressed: (_isLoading || _escrowId == null) ? null : _handleSend,
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
          color: isAi ? Colors.white.withOpacity(0.4) : const Color(0xFF1D1D1B),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 4 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 4),
          ),
          border: isAi ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
          boxShadow: [
            if (isAi)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          text.replaceAll("**", ""),
          style: TextStyle(
            color: isAi ? const Color(0xFF1D1D1B) : Colors.white,
            fontSize: 15,
            height: 1.5,
            fontWeight: isTyping ? FontWeight.w300 : FontWeight.normal,
            fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}