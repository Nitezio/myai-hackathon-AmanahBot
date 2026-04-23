import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import 'dispute_chat_screen.dart';
import 'seller_dashboard.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const SellerDashboard(),
    const CheckoutScreen(), 
    const DisputeChatScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: Colors.blueAccent.withOpacity(0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined, color: Colors.white70), 
            selectedIcon: Icon(Icons.storefront, color: Colors.blueAccent),
            label: 'Seller',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined, color: Colors.white70), 
            selectedIcon: Icon(Icons.shield, color: Colors.blueAccent),
            label: 'Buyer',
          ),
          NavigationDestination(
            icon: Icon(Icons.gavel_outlined, color: Colors.white70), 
            selectedIcon: Icon(Icons.gavel, color: Colors.blueAccent),
            label: 'Disputes',
          ),
        ],
      ),
    );
  }
}
