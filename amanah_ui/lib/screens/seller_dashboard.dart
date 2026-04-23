import 'dart:ui';
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glow Orbs
          Positioned(
            top: -100,
            left: -100,
            child: _buildGlowOrb(const Color(0xFF6366F1).withValues(alpha: 0.15)),
          ),
          Positioned(
            bottom: 200,
            right: -50,
            child: _buildGlowOrb(const Color(0xFF8B5CF6).withValues(alpha: 0.1)),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Text(
                    "Seller Hub",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create AI-protected payment links instantly.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),
                  
                  _buildFormSection(),
                  
                  const SizedBox(height: 32),
                  
                  if (_generatedId != null) _buildSuccessCard(),
                  
                  const SizedBox(height: 40),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createLink,
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("GENERATE SECURE LINK"),
                  ),
                  const SizedBox(height: 100), // Space for nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb(Color color) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: Container()),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "AMANAH-SELLER",
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white38),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: const Row(
            children: [
              Icon(Icons.bolt, color: Colors.amber, size: 14),
              SizedBox(width: 4),
              Text("PRO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        _buildField("Item Description", _itemController, Icons.shopping_bag_rounded),
        _buildField("Price in MYR", _priceController, Icons.payments_rounded, keyboardType: TextInputType.number),
        _buildField("Courier Tracking #", _trackingController, Icons.local_shipping_rounded),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6366F1)),
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "LINK READY FOR SECURE PAYMENT",
                style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              SelectableText(
                "amanah.bot/pay/$_generatedId",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "Copy this link and send it to your buyer.",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

