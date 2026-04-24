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
  String _reasoning = "AGENT: Waiting for DuitNow receipt upload...";
  bool _isAnalyzing = false;
  Timer? _pollingTimer;
  final TextEditingController _idController = TextEditingController(); // FIXED: Added missing controller

  @override
  void initState() {
    super.initState();
    if (widget.escrowId != null) {
      _idController.text = widget.escrowId!;
    }
  }

  // Visual Stepper Logic
  int _currentStep() {
    switch (_status) {
      case "Payment_Pending": return 0;
      case "Funded": return 1;
      case "In_Transit": return 2;
      case "Delivered": return 3;
      case "Released": return 4;
      default: return 0;
    }
  }

  void _pickAndUpload() async {
    final id = _idController.text.trim(); // FIXED: Uses the controller value
    
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid Escrow ID first"), backgroundColor: Colors.redAccent)
      );
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _isAnalyzing = true;
        _reasoning = "AGENT: Scanning pixels for forensic manipulation...";
      });
      
      try {
        final res = await ApiService.uploadReceipt(id, image);
        setState(() {
          _status = res['current_status'];
          // V2/V3 Bridge Logic
          _reasoning = res['ai_verdict']['reasoning'] ?? "AI confirmed authenticity.";
          _isAnalyzing = false;
        });
        _startStatusPolling(id);
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
          _reasoning = "CRITICAL: Backend bridge failure. Ensure Node.js server is on Port 3400.";
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _startStatusPolling(String id) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final res = await ApiService.getEscrowStatus(id);
        setState(() {
          _status = res['status'];
          if (_status == "Released") {
            _reasoning = "AGENT: Funds released autonomously. Transaction Closed.";
            timer.cancel();
          } else if (_status == "In_Transit") {
            _reasoning = "AGENT: Courier confirmed pickup. Monitoring delivery...";
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
    _idController.dispose();
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
              _buildStepper(),
              const SizedBox(height: 40),
              _buildStatusCard(),
              const SizedBox(height: 30),
              if (_status == "Payment_Pending") _buildUploadButton(),
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
      const Icon(Icons.shield, color: Colors.blueAccent, size: 28),
      const SizedBox(width: 12),
      const Text("AMANAH CHECKOUT", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
        child: const Text("V3.0 HYBRID", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      )
    ]);
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        bool isDone = index < _currentStep();
        bool isCurrent = index == _currentStep();
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? Colors.greenAccent : (isCurrent ? Colors.blueAccent : Colors.white10),
                ),
                child: Center(
                  child: isDone 
                    ? const Icon(Icons.check, size: 16, color: Colors.black)
                    : Text("${index + 1}", style: TextStyle(color: isCurrent ? Colors.white : Colors.white24, fontWeight: FontWeight.bold)),
                ),
              ),
              if (index < 4) Expanded(child: Container(height: 2, color: isDone ? Colors.greenAccent.withOpacity(0.3) : Colors.white10)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: [
        TextField(
          controller: _idController,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: "Enter Escrow ID from Seller",
            hintStyle: TextStyle(color: Colors.white24),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.link, color: Colors.white24, size: 16),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Product: Secure Transaction", style: TextStyle(color: Colors.white38, fontSize: 14)),
        const SizedBox(height: 24),
        ReasoningBar(reasoning: _reasoning, isAnalyzing: _isAnalyzing),
      ]),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: _isAnalyzing ? null : _pickAndUpload,
        icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
        label: const Text("UPLOAD DUITNOW RECEIPT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
        ),
      ),
    );
  }
}
