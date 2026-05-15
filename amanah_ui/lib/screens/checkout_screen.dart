import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import '../services/demo_state.dart';

class CheckoutScreen extends StatefulWidget {
  final String? escrowId;
  const CheckoutScreen({super.key, this.escrowId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _status = "Payment_Pending";
  String _reasoning = "Waiting for DuitNow receipt upload...";
  String _itemName = "Scanning for ID...";
  String _itemPrice = "0.00";
  List<String> _agentLogs = ["SYSTEM: Connection established.", "READY: Waiting for user action."];
  bool _isAnalyzing = false;
  Map<String, dynamic> _fullData = {};
  StreamSubscription? _escrowSubscription;
  Timer? _pollingTimer;
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onIdChanged);
    if (widget.escrowId != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _idController.text = widget.escrowId!;
        _startSync(widget.escrowId!);
      });
    }
  }

  @override
  void dispose() {
    _escrowSubscription?.cancel();
    _pollingTimer?.cancel();
    _idController.dispose();
    super.dispose();
  }

  void _onIdChanged() {
    final id = _idController.text.trim();
    if (id.length == 8) {
      _startSync(id);
    } else if (id.isEmpty) {
      _stopSync();
      setState(() {
        _itemName = "Enter valid Escrow ID";
        _itemPrice = "0.00";
        _agentLogs = ["READY: Awaiting input."];
      });
    }
  }

  void _stopSync() {
    _escrowSubscription?.cancel();
    _pollingTimer?.cancel();
  }

  void _startSync(String id) {
    _stopSync();
    DemoState.activeEscrowId = id;
    print("DEBUG: Starting Sync for ID: $id");
    _startFirestoreSubscription(id);
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchViaRest(id);
    });
    _fetchViaRest(id);
  }

  void _startFirestoreSubscription(String id) {
    _escrowSubscription = FirebaseFirestore.instance
        .collection('escrows')
        .doc(id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _updateUIFromData(snapshot.data() as Map<String, dynamic>);
      }
    }, onError: (error) {
      print("DEBUG: Firestore Stream blocked. Falling back to REST.");
    });
  }

  Future<void> _fetchViaRest(String id) async {
    try {
      final data = await ApiService.getEscrowStatus(id);
      _updateUIFromData(data);
    } catch (e) {
      print("DEBUG: REST Fetch Error: $e");
    }
  }

  void _updateUIFromData(Map<String, dynamic> data) {
    if (!mounted) return;
    setState(() {
      _fullData = data;
      _status = data['status'] ?? "Payment_Pending";
      _itemName = data['item'] ?? "Secure Item";
      _itemPrice = (data['price'] ?? 0.0).toStringAsFixed(2);
      
      final rawLogs = data['logs'] as List<dynamic>? ?? [];
      _agentLogs = rawLogs.map((e) => e.toString()).toList();
      
      if (_status != "Payment_Pending") _isAnalyzing = false;

      // 🔥 DYNAMIC REASONING
      final String rejectionType = data['rejection_type'] ?? "NONE";
      final String rejectionReason = data['rejection_reason'] ?? "";

      if (_status == "Disputed") {
        if (rejectionType == "FAKE_RECEIPT") {
          _reasoning = "🚨 SCAM ALERT: This receipt is FORGED or INVALID.";
        } else if (rejectionType == "AMOUNT_MISMATCH") {
          _reasoning = "🚨 REJECTED: $rejectionReason";
        } else {
          _reasoning = "🚨 REJECTED: Security check failed.";
        }
      } else if (_status == "Released") {
        _reasoning = "SUCCESS: Autonomous payout executed.";
      } else if (_status == "Delivered") {
        _reasoning = "AGENT: Delivery confirmed. Verifying release...";
      } else if (_status == "In_Transit") {
        _reasoning = "AGENT: Parcel in transit. Monitoring courier...";
      } else if (_status == "Funded") {
        _reasoning = "AI verified receipt. Waiting for pickup...";
      } else {
        _reasoning = "Waiting for DuitNow receipt upload...";
      }
    });
  }

  double _getProgress() {
    switch (_status) {
      case "Payment_Pending": return 0.1;
      case "Disputed": return 0.4; 
      case "Funded": return 0.4; 
      case "In_Transit": return 0.6;
      case "Delivered": return 0.8;
      case "Released": return 1.0;
      default: return 0.1;
    }
  }

  void _showFullLogs() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, color: Colors.blueAccent),
                  SizedBox(width: 12),
                  Text("TRANSACTION AUDIT LOG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _agentLogs.length,
                  itemBuilder: (context, index) {
                    final log = _agentLogs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        log,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickAndUpload() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _isAnalyzing = true;
        _reasoning = "AGENT: Running multimodal pixel forensics...";
      });
      try {
        await ApiService.uploadReceipt(id, image);
      } catch (e) {
        if (mounted) setState(() { _isAnalyzing = false; _reasoning = "ERROR: Bridge failed."; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildAnimatedProgress(),
              const SizedBox(height: 40),
              _buildProductCard(),
              if (_status == "Disputed") _buildWarningCard(),
              const SizedBox(height: 24),
              _buildAgentConsole(),
              const SizedBox(height: 24),
              if (_status == "Payment_Pending" || _status == "Disputed") _buildActionButton(),
              const SizedBox(height: 40),
              const Center(child: Text("🔒 AMANAH-CORE PROTOCOL ACTIVE", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      const Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 24),
      const SizedBox(width: 10),
      const Text("AMANAH", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
      const Spacer(),
      if (_status != "Payment_Pending" && _status != "Scanning for ID...")
        IconButton(
          onPressed: () => PdfService.generateEvidenceReport(_fullData, _idController.text.trim()),
          icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white38, size: 20),
        ),
      if (_isAnalyzing) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent)),
    ]);
  }

  Widget _buildAnimatedProgress() {
    bool isError = _status == "Disputed";
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                ),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOutCubic,
                  height: 12,
                  width: barWidth * _getProgress(),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: isError ? [Colors.red, Colors.redAccent] : [Colors.blueAccent, Colors.greenAccent]
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: (isError ? Colors.red : Colors.blueAccent).withOpacity(0.3), blurRadius: 10)],
                  ),
                ),
                if (isError)
                  Positioned(
                    left: (barWidth * 0.4) - 10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatusText("IDENTIFIED", true, false),
            _buildStatusText("VERIFIED", _getProgress() >= 0.4, isError),
            _buildStatusText("TRANSIT", _getProgress() >= 0.6, false),
            _buildStatusText("RELEASE", _getProgress() >= 1.0, false),
          ],
        )
      ],
    );
  }

  Widget _buildStatusText(String label, bool active, bool isError) {
    Color color = Colors.white24;
    if (active) {
      color = isError ? Colors.redAccent : Colors.blueAccent;
    }
    return Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1));
  }

  Widget _buildWarningCard() {
    final String rejectionType = _fullData['rejection_type'] ?? "NONE";
    final String rejectionReason = _fullData['rejection_reason'] ?? "Receipt check failed.";
    
    String title = "SCAM DETECTED";
    if (rejectionType == "AMOUNT_MISMATCH") title = "AMOUNT MISMATCH";

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(rejectionReason, style: TextStyle(color: Colors.redAccent.withOpacity(0.7), fontSize: 11)),
          ],
        )),
      ]),
    );
  }

  Widget _buildProductCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        TextField(
          controller: _idController,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(hintText: "PASTE ESCROW ID", hintStyle: TextStyle(color: Colors.white10), border: InputBorder.none),
        ),
        const SizedBox(height: 12),
        Text(_itemName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        Text("RM $_itemPrice", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
      ]),
    );
  }

  Widget _buildAgentConsole() {
    return Container(
      width: double.infinity,
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueAccent.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.terminal, color: Colors.greenAccent, size: 14),
            const SizedBox(width: 8),
            const Text("AGENT_ACTIVITY_LOG", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(onTap: () => _showFullLogs(), child: const Text("EXPAND", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _agentLogs.length,
              itemBuilder: (context, index) {
                final log = _agentLogs.reversed.toList()[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text("> $log", style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace')),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    bool isError = _status == "Disputed";
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: isError ? Colors.redAccent : Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        onPressed: _pickAndUpload,
        child: Text(isError ? "RE-UPLOAD VALID PROOF" : "UPLOAD PROOF OF PAYMENT", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
