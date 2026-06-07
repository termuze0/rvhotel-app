import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/order.dart';
import '../../../models/cart_item.dart';
import '../widgets/order_card.dart';

class OrdersTab extends StatefulWidget {
  final Function(int) onTabChanged;

  const OrdersTab({super.key, required this.onTabChanged});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  void _showOrderDetails(OrderData order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Order Details',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow('Order ID', order.orderNumber),
                    _buildDetailRow('Hotel ID', order.hotelId.toString()),
                    _buildDetailRow('Date', _formatDate(order.createdAt)),
                    _buildDetailRow('Items', order.items.length.toString()),
                    _buildDetailRow(
                        'Subtotal', 'ETB ${order.subtotal.toStringAsFixed(2)}'),
                    _buildDetailRow('Delivery Fee',
                        'ETB ${order.deliveryFee.toStringAsFixed(2)}'),
                    _buildDetailRow(
                        'Total', 'ETB ${order.total.toStringAsFixed(2)}'),
                    _buildDetailRow('Payment Method', order.paymentMethod),
                    _buildDetailRow('Delivery Address', order.deliveryAddress),
                    if (order.specialInstructions != null)
                      _buildDetailRow(
                          'Special Instructions', order.specialInstructions!),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Order Items',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ETB ${item.total.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReorderDialog(OrderData order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.repeat, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text('Reorder',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Do you want to reorder the same items?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);
              for (var item in order.items) {
                cartProvider.addItem(CartItem(
                  id: item.productId,
                  name: item.product.name,
                  price: item.price,
                  quantity: item.quantity,
                  hotelName: 'Hotel ${order.hotelId}',
                  hotelId: order.hotelId,
                ));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Items added to cart'),
                    backgroundColor: Colors.green),
              );
              widget.onTabChanged(0);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }

  void _showTrackOrderDialog(OrderData order) {
    bool isStepCompleted(String step) {
      final status = order.status.toLowerCase();
      switch (step) {
        case 'confirmed':
          return ['pending', 'preparing', 'out', 'done'].contains(status);
        case 'preparing':
          return ['preparing', 'out', 'done'].contains(status);
        case 'out':
          return ['out', 'done'].contains(status);
        case 'done':
          return status == 'done';
        default:
          return false;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delivery_dining, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Track Order',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTrackingStep(isStepCompleted('confirmed'),
                  'Order Confirmed', 'Your order has been confirmed'),
              _buildTrackingStep(isStepCompleted('preparing'), 'Preparing Food',
                  'Chef is preparing your meal'),
              _buildTrackingStep(isStepCompleted('out'), 'Out for Delivery',
                  'Rider is on the way'),
              _buildTrackingStep(
                  isStepCompleted('done'), 'Delivered', 'Enjoy your meal!'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _trackingMessage(order.status),
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  String _trackingMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Estimated preparation time: 25-35 minutes';
      case 'preparing':
        return 'Your food is being cooked';
      case 'out':
        return 'Your food is on the way!';
      case 'done':
        return 'Order delivered successfully!';
      default:
        return 'Track your order status';
    }
  }

  // ── Detail row: label left, value right — value wraps instead of overflowing
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed-width label so values always align
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(bool isCompleted, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade600 : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.access_time,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isCompleted ? Colors.black : Colors.grey.shade500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 80, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    orderProvider.error!,
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => orderProvider.loadMyOrders(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (orderProvider.orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No Orders Yet',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    'Start ordering your favorite food',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => widget.onTabChanged(0),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700),
                    child: const Text('Browse Menu'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => orderProvider.loadMyOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return OrderCard(
                order: order,
                onViewDetails: () => _showOrderDetails(order),
                onReorder: () => _showReorderDialog(order),
                onTrackOrder: () => _showTrackOrderDialog(order),
              );
            },
          ),
        );
      },
    );
  }
}
