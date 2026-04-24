import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/reasoning_bar.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Text(
                    "Secure Escrow\nPayment",
                    style: Theme.of(context).textTheme.displayLarge,
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
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 12, color: const Color(0xFF1D1D1B).withValues(alpha: 0.2)),
                        const SizedBox(width: 4),
                        Text(
                          "256-BIT ENCRYPTED ZERO-TRUST PROTOCOL",
                          style: TextStyle(color: const Color(0xFF1D1D1B).withValues(alpha: 0.2), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 4),
              Text("VERIFIED", style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return GlassCard(
      isInteractive: true,
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
                        color: const Color(0xFF1D1D1B).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF1D1D1B), size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.escrowId?.toUpperCase() ?? "NEW ESCROW",
                            style: TextStyle(color: const Color(0xFF1D1D1B).withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                          const Text(
                            "Jordan 1 Retro High",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D1D1B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: const Color(0xFF1D1D1B).withValues(alpha: 0.05), height: 1),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TOTAL AMOUNT", style: TextStyle(color: const Color(0xFF1D1D1B).withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        const Text("RM 450.00", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1D1D1B))),
                      ],
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(_status),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _status == "Released" ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFF1D1D1B).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _status == "Released" ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFF1D1D1B).withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          _status.replaceAll("_", " "),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _status == "Released" ? const Color(0xFF10B981) : const Color(0xFF1D1D1B)),
                        ),
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
              color: const Color(0xFF1D1D1B).withValues(alpha: 0.02),
              border: Border(top: BorderSide(color: const Color(0xFF1D1D1B).withValues(alpha: 0.05))),
            ),
            child: ReasoningBar(reasoning: _reasoning, isAnalyzing: _isAnalyzing),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (_status == "Payment_Pending")
            BoxShadow(
              color: const Color(0xFF1D1D1B).withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D1D1B),
          disabledBackgroundColor: const Color(0xFF1D1D1B).withValues(alpha: 0.05),
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
