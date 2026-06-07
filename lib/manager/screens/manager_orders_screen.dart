import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/manager_provider.dart';
import '../../../models/order.dart';

class ManagerOrdersScreen extends StatelessWidget {
  const ManagerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, managerProvider, child) {
        if (managerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = managerProvider.orders;

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => managerProvider.loadOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, managerProvider, order);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(
      BuildContext context, ManagerProvider provider, OrderData order) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'preparing':
          return Colors.blue;
        case 'out':
          return Colors.deepOrange;
        case 'done':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    String getStatusText(String status) {
      switch (status) {
        case 'pending':
          return 'Pending';
        case 'preparing':
          return 'Preparing';
        case 'out':
          return 'Out for Delivery';
        case 'done':
          return 'Delivered';
        default:
          return status;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStatusText(order.status),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Customer: ${order.customerPhone}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            Text(
              'Address: ${order.deliveryAddress}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${item.quantity}x ${item.product.name}',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                )),
            if (order.items.length > 2)
              Text(
                '+${order.items.length - 2} more items',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ETB ${order.total.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange.shade700,
                  ),
                ),
                // Status update dropdown
                DropdownButton<String>(
                  value: order.status,
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'preparing', child: Text('Preparing')),
                    DropdownMenuItem(
                        value: 'out', child: Text('Out for Delivery')),
                    DropdownMenuItem(value: 'done', child: Text('Delivered')),
                  ],
                  onChanged: (newStatus) async {
                    if (newStatus != null && newStatus != order.status) {
                      final success =
                          await provider.updateOrderStatus(order.id, newStatus);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Order status updated to ${getStatusText(newStatus)}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
