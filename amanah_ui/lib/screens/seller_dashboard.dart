import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

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
    // Validate inputs before calling API
    if (_itemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an item description.")),
      );
      return;
    }
    if (_priceController.text.trim().isEmpty || double.tryParse(_priceController.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid price (numbers only).")),
      );
      return;
    }
    if (_trackingController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a courier tracking number.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.createEscrow(
        _itemController.text.trim(),
        double.parse(_priceController.text.trim()),
        _trackingController.text.trim(),
      );
      setState(() {
        _generatedId = res['escrow_id'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection error: Check that the backend is running on port 8000.")),
        );
      }
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
                  
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1D1B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("GENERATE SECURE LINK", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                    ),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "AMANAH-SELLER",
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 12, color: const Color(0xFF1D1D1B).withValues(alpha: 0.3)),
        ),
        // PRO badge removed
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
      child: GlassCard(
        borderRadius: 20,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D1D1B)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1D1D1B).withValues(alpha: 0.4)),
            labelText: label,
            labelStyle: TextStyle(color: const Color(0xFF1D1D1B).withValues(alpha: 0.4), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return GlassCard(
      borderRadius: 24,
      isInteractive: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "LINK READY FOR SECURE PAYMENT",
              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    "amanah.bot/pay/$_generatedId",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Color(0xFF1D1D1B)),
                  ),
                ),
                IconButton(
                  tooltip: "Copy link",
                  icon: const Icon(Icons.copy_rounded, size: 20, color: Color(0xFF1D1D1B)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: "amanah.bot/pay/$_generatedId"));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Link copied to clipboard!")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Copy this link and send it to your buyer.",
              style: TextStyle(color: const Color(0xFF1D1D1B).withValues(alpha: 0.4), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

