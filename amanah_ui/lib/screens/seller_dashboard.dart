import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  final _trackingController = TextEditingController();
  bool _isLoading = false;
  String? _generatedId;

  void _createLink() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.createEscrow(
        _itemController.text,
        double.parse(_priceController.text),
        _trackingController.text,
      );
      setState(() {
        _generatedId = res['escrow_id'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("SELLER HUB", style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Generate Secure Link", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            _buildField("Item Name", _itemController, Icons.shopping_bag_outlined),
            _buildField("Price (RM)", _priceController, Icons.payments_outlined, keyboardType: TextInputType.number),
            _buildField("Tracking Number", _trackingController, Icons.local_shipping_outlined),
            const SizedBox(height: 30),
            if (_generatedId != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.greenAccent.withOpacity(0.3))),
                child: SelectableText("Link ID: $_generatedId\nShare: amanah.bot/pay/$_generatedId", style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _isLoading ? null : _createLink,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("CREATE ESCROW LINK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white30),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white30),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent)),
        ),
      ),
    );
  }
}
