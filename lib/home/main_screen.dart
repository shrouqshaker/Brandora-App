import 'package:flutter/material.dart';
import 'inventory_screen.dart'; // ملف الانفنتوري بتاعك
import 'production_screen.dart'; // ملف البرودكشن بتاعك
import 'store_screen.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // نبدأ بالانفنتوري كديفولت

  // قائمة الصفحات اللي هيتنقل بينها
  final List<Widget> _pages = [
    const StoreScreen(),                           // Index 0
    const Center(child: Text("Dashboard Page")),  // Index 1
    const InventoryScreen(),                      // Index 2
    const ProductionScreen(),                     // Index 3 (اللي هنعمله حالا)
    const Center(child: Text("Account Page")),    // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.store_outlined, "MARKET", 0),
              _navItem(Icons.grid_view_rounded, "DASHBOARD", 1),
              _navItem(Icons.inventory_2, "INVENTORY", 2),
              _navItem(Icons.precision_manufacturing_outlined, "PRODUCTION", 3),
              _navItem(Icons.person_outline, "ACCOUNT", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF3F51B5) : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: isActive ? const Color(0xFF3F51B5) : Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.bold
          )),
        ],
      ),
    );
  }
}