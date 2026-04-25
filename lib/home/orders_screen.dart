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
    
    final List<dynamic> orders = orderData.orders;

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
      body: orderData.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        "No orders yet.",
                        style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
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
                          GestureDetector(
                            onTap: () {
                              final userData = Provider.of<UserData>(context, listen: false);
                              if (userData.role == 'seller') {
                                _showStatusPicker(context, order['_id'], order['status']);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order['status']).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    order['status'],
                                    style: TextStyle(color: _getStatusColor(order['status']), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  if (Provider.of<UserData>(context, listen: false).role == 'seller')
                                    const Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey),
                                ],
                              ),
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

  void _showStatusPicker(BuildContext context, String orderId, String currentStatus) {
    final orderData = Provider.of<OrderData>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Update Order Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map((status) {
                return ListTile(
                  title: Text(status),
                  trailing: status == currentStatus ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () async {
                    Navigator.pop(context);
                    bool success = await orderData.updateOrderStatus(orderId, status);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? "Status Updated!" : "Update Failed"), backgroundColor: success ? Colors.green : Colors.red),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
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
