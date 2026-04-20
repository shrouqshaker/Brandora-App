import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winterproject/home/data.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final Color primaryColor = const Color(0xFF3F51B5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userData = Provider.of<UserData>(context, listen: false);
      Provider.of<OrderData>(context, listen: false).fetchOrders(userData.role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderData>(context);
    
    // Dummy data if server list is empty (as requested)
    final List<dynamic> orders = orderData.orders.isEmpty ? [
      {
        "_id": "ORD12345",
        "customerName": "Ahmed Ali",
        "status": "Pending",
        "createdAt": DateTime.now().subtract(const Duration(days: 1)).toString(),
        "totalPrice": 1200.0
      },
      {
        "_id": "ORD12346",
        "customerName": "Sara Mohamed",
        "status": "Processing",
        "createdAt": DateTime.now().subtract(const Duration(days: 2)).toString(),
        "totalPrice": 850.0
      },
      {
        "_id": "ORD12347",
        "customerName": "John Doe",
        "status": "Delivered",
        "createdAt": DateTime.now().subtract(const Duration(days: 5)).toString(),
        "totalPrice": 2100.0
      }
    ] : orderData.orders;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Orders", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryColor),
            onPressed: () {
              final userData = Provider.of<UserData>(context, listen: false);
              orderData.fetchOrders(userData.role);
            },
          ),
        ],
      ),
      body: orders.isEmpty 
          ? const Center(child: Text("No orders found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['status']).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.receipt_long_outlined, color: _getStatusColor(order['status'])),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #${order['_id'].toString().substring(order['_id'].toString().length - 5)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(order['customerName'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${order['totalPrice']} EGP",
                            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order['status'],
                              style: TextStyle(color: _getStatusColor(order['status']), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
