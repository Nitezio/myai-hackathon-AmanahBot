import 'dart:async';
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
  Map<String, dynamic>? _escrowDetails;
  Timer? _pollingTimer;

  void _pickAndUpload() async {
    if (widget.escrowId == null) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _isAnalyzing = true;
        _reasoning = "AI Vision: Scanning receipt pixels for forensic anomalies...";
      });
      
      try {
        final res = await ApiService.uploadReceipt(widget.escrowId!, image);
        setState(() {
          _status = res['current_status'];
          _reasoning = res['ai_verdict']['reasoning'];
          _isAnalyzing = false;
        });
        _startStatusPolling();
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
          _reasoning = "ERROR: Could not bridge to AI Server.";
        });
      }
    }
  }

  void _startStatusPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final res = await ApiService.getEscrowStatus(widget.escrowId!);
        setState(() {
          _status = res['status'];
          if (_status == "Released") {
            _reasoning = "SUCCESS: Funds unlocked autonomously via Courier API.";
            timer.cancel();
          }
        });
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
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              const Text("Secure Escrow Payment", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 20),
              _buildStatusCard(),
              const SizedBox(height: 30),
              _buildActionButton(),
              const SizedBox(height: 40),
              const Center(child: Text("🔒 256-bit Encrypted Zero-Trust Protocol", style: TextStyle(color: Colors.white24, fontSize: 10))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      Container(width: 4, height: 24, color: Colors.yellowAccent),
      const SizedBox(width: 8),
      const Text("AMANAH-BOT", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white70)),
    ]);
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent.withOpacity(0.15), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(widget.escrowId ?? "Scan QR to Start", style: const TextStyle(color: Colors.white30, fontSize: 12)),
        const SizedBox(height: 10),
        const Text("Jordan 1 Retro High", style: TextStyle(color: Colors.white70)),
        const Text("RM 450.00", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 12),
        Chip(label: Text(_status.toUpperCase()), backgroundColor: _status == "Released" ? Colors.green : Colors.blueGrey),
        const SizedBox(height: 20),
        ReasoningBar(reasoning: _reasoning, isAnalyzing: _isAnalyzing),
      ]),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: _status == "Payment_Pending" ? _pickAndUpload : null,
        child: const Text("UPLOAD PROOF OF PAYMENT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
