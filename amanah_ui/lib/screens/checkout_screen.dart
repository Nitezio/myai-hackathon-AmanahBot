import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/reasoning_bar.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String? escrowId;
  const CheckoutScreen({super.key, this.escrowId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _status = "Payment_Pending";
  String _reasoning = "AI Vision: Waiting for DuitNow receipt upload...";
  bool _isAnalyzing = false;
  Timer? _pollingTimer;

  void _pickAndUpload() async {
    final effectiveId = widget.escrowId ?? "TX-DEMO-999";
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _isAnalyzing = true;
        _reasoning = "AI Vision: Scanning receipt pixels for forensic anomalies...";
      });
      
      try {
        final res = await ApiService.uploadReceipt(effectiveId, image);
        setState(() {
          _status = res['current_status'] ?? _status;
          _reasoning = res['ai_verdict']?['reasoning'] ?? _reasoning;
          _isAnalyzing = false;
        });
        _startStatusPolling(effectiveId);
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
          _reasoning = "ERROR: ${e.toString().split(':').last.trim()}";
        });
      }
    }
  }

  void _startStatusPolling(String id) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final res = await ApiService.getEscrowStatus(id);
        if (mounted) {
          setState(() {
            _status = res['status'];
            if (_status == "Released") {
              _reasoning = "SUCCESS: Funds unlocked autonomously via Courier API.";
              timer.cancel();
            }
          });
        }
      } catch (e) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container()),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Text(
                    "Secure Escrow\nPayment",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      height: 1.1,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Colors.white, Colors.white70],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Review transaction and upload receipt.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  _buildStatusCard(),
                  const SizedBox(height: 32),
                  _buildActionButton(),
                  const SizedBox(height: 40),
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 12, color: Colors.white24),
                        SizedBox(width: 4),
                        Text(
                          "256-BIT ENCRYPTED ZERO-TRUST PROTOCOL",
                          style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        ),
                      ],
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0xFF3B82F6), blurRadius: 10, spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "AMANAH-BOT",
              style: TextStyle(
                letterSpacing: 3,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, size: 14, color: Colors.greenAccent),
                  SizedBox(width: 4),
                  Text("VERIFIED", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: Colors.white70, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.escrowId?.toUpperCase() ?? "NEW ESCROW",
                                style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                              ),
                              const Text(
                                "Jordan 1 Retro High",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TOTAL AMOUNT", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            SizedBox(height: 4),
                            Text("RM 450.00", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                          ],
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Chip(
                            key: ValueKey(_status),
                            label: Text(
                              _status.replaceAll("_", " "),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            backgroundColor: _status == "Released" ? Colors.green.withValues(alpha: 0.2) : Colors.blueAccent.withValues(alpha: 0.2),
                            side: BorderSide(color: _status == "Released" ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.blueAccent.withValues(alpha: 0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                ),
                child: ReasoningBar(reasoning: _reasoning, isAnalyzing: _isAnalyzing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (_status == "Payment_Pending")
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
        ),
        onPressed: _status == "Payment_Pending" ? _pickAndUpload : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isAnalyzing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(Icons.cloud_upload_outlined, size: 20),
            const SizedBox(width: 12),
            Text(_isAnalyzing ? "ANALYZING RECEIPT..." : "UPLOAD PROOF OF PAYMENT"),
          ],
        ),
      ),
    );
  }
}
