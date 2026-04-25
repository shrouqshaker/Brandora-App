import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'inventory_screen.dart';
import 'production_screen.dart';
import 'store_screen.dart';
import 'orders_screen.dart';
import 'account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final isSeller = userData.role == 'seller';

    final List<Widget> pages = isSeller ? [
      const StoreScreen(),
      const OrdersScreen(),
      const InventoryScreen(),
      const ProductionScreen(),
      const AccountScreen(),
    ] : [
      const StoreScreen(),
      const OrdersScreen(),
      const AccountScreen(),
    ];

    final lowStockCount = userData.analytics?['lowStockCount'] ?? 0;

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: isSeller ? [
              _navItem(Icons.store_outlined, "MARKET", 0),
              _navItem(Icons.list_alt_rounded, "ORDERS", 1),
              _navItem(Icons.inventory_2, "INVENTORY", 2, badgeCount: lowStockCount),
              _navItem(Icons.precision_manufacturing_outlined, "PRODUCTION", 3),
              _navItem(Icons.person_outline, "ACCOUNT", 4),
            ] : [
              _navItem(Icons.store_outlined, "MARKET", 0),
              _navItem(Icons.list_alt_rounded, "ORDERS", 1),
              _navItem(Icons.person_outline, "ACCOUNT", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, {int badgeCount = 0}) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: isActive ? const Color(0xFF3F51B5) : Colors.grey),
              if (badgeCount > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
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