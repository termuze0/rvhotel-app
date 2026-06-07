import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../payment/telebirr_payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.orange.shade700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (cartProvider.isNotEmpty)
            TextButton(
              onPressed: () => _showClearCartDialog(context, cartProvider),
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: cartProvider.isEmpty
            ? _buildEmptyCart()
            : Column(
                children: [
                  Expanded(child: _buildCartItemsList()),
                  _buildOrderSummary(),
                ],
              ),
      ),
    );
  }

  // ─── Empty Cart ───────────────────────────────────────────────────────────

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.orange.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Cart is Empty',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Looks like you haven\'t added any\nitems to your cart yet',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Browse Menu',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cart Items List ──────────────────────────────────────────────────────

  Widget _buildCartItemsList() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final groupedItems = cartProvider.getItemsByHotel();
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: groupedItems.keys.length,
          itemBuilder: (context, index) {
            final hotelName = groupedItems.keys.elementAt(index);
            final items = groupedItems[hotelName]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelHeader(hotelName, items),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, itemIndex) =>
                      _buildCartItem(items[itemIndex]),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHotelHeader(String hotelName, List<CartItem> items) {
    final totalItems = items.fold(0, (sum, item) => sum + item.quantity);
    final totalPrice = items.fold(0.0, (sum, item) => sum + item.total);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(Icons.restaurant, color: Colors.orange.shade700, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$totalItems item${totalItems > 1 ? 's' : ''} • ETB ${totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(Icons.fastfood, size: 25, color: Colors.orange.shade300),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'ETB ${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (item.quantity > 1) {
                          cartProvider.decreaseQuantity(item.id);
                        } else {
                          _showRemoveItemDialog(context, cartProvider, item);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.remove,
                            size: 14, color: Colors.red.shade600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${item.quantity}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => cartProvider.increaseQuantity(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ETB ${item.total.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _showRemoveItemDialog(context, cartProvider, item),
                child: Icon(Icons.delete_outline,
                    size: 18, color: Colors.red.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Order Summary ────────────────────────────────────────────────────────

  Widget _buildOrderSummary() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Order Summary',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Subtotal',
                  'ETB ${cartProvider.subtotal.toStringAsFixed(2)}'),
              _buildSummaryRow('Delivery Fee',
                  'ETB ${cartProvider.deliveryFee.toStringAsFixed(2)}'),
              _buildSummaryRow(
                  'Tax (15%)', 'ETB ${cartProvider.tax.toStringAsFixed(2)}'),
              const Divider(height: 20),
              _buildSummaryRow(
                'Total',
                'ETB ${cartProvider.total.toStringAsFixed(2)}',
                isTotal: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed to Checkout',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.orange.shade700 : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Checkout Flow ────────────────────────────────────────────────────────

  Future<void> _proceedToCheckout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Your cart is empty'), backgroundColor: Colors.red),
      );
      return;
    }

    final userPhone = authProvider.user?.phone ?? '';
    if (userPhone.isEmpty) {
      _showPhoneNumberDialog();
      return;
    }

    final address = await _showAddressDialog();
    if (address == null || address.isEmpty) return;

    final specialInstructions = await _showInstructionsDialog();

    final paymentMethod = await _showPaymentMethodDialog();
    if (paymentMethod == null) return;

    final hotelId = cartProvider.items.first.hotelId ?? 1;
    final items = cartProvider.items
        .map((item) =>
            OrderItemRequest(productId: item.id, quantity: item.quantity))
        .toList();

    // ── Step 1: Place Order ──
    _showLoadingDialog('Placing your order...');

    final success = await orderProvider.placeOrder(
      hotelId: hotelId,
      deliveryAddress: address,
      customerPhone: userPhone,
      specialInstructions: specialInstructions,
      paymentMethod: paymentMethod,
      items: items,
    );

    if (mounted) Navigator.pop(context); // close loading

    if (!success || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(orderProvider.error ?? 'Failed to place order'),
            backgroundColor: Colors.red),
      );
      return;
    }

    cartProvider.clearCart();

    if (paymentMethod == 'telebirr') {
      // ── Step 2: Get Telebirr Payment URL ──
      final orderId = orderProvider.currentOrder?.id;

      print('Order placed. ID: $orderId'); // debug

      if (orderId == null || orderId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Order ID not found. Cannot initiate payment.'),
              backgroundColor: Colors.red),
        );
        return;
      }

      _showLoadingDialog('Initiating Telebirr payment...');

      final paymentUrl = await orderProvider.initiatePayment(orderId);

      print('Payment URL: $paymentUrl'); // debug

      if (mounted) Navigator.pop(context); // close loading

      if (paymentUrl != null && paymentUrl.isNotEmpty && mounted) {
        // ── Step 3: Open Telebirr WebView ──
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelebirrPaymentScreen(
              paymentUrl: paymentUrl,
              orderNumber: orderProvider.currentOrder?.orderNumber ?? '',
              onPaymentComplete: () async {
                await orderProvider.loadMyOrders();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment completed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(orderProvider.error ??
                  'Could not get Telebirr payment link.'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      // ── Cash on Delivery ──
      await orderProvider.loadMyOrders();
      _showOrderSuccessDialog(orderProvider.currentOrder);
    }
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  Future<String?> _showPaymentMethodDialog() async {
    String selectedMethod = 'telebirr';

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Select Payment Method',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone_android,
                          color: Colors.blue, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Telebirr',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  ],
                ),
                value: 'telebirr',
                groupValue: selectedMethod,
                activeColor: Colors.orange.shade700,
                onChanged: (value) => setState(() => selectedMethod = value!),
              ),
              const Divider(),
              RadioListTile<String>(
                title: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.money,
                          color: Colors.green, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('Cash on Delivery',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  ],
                ),
                value: 'cod',
                groupValue: selectedMethod,
                activeColor: Colors.orange.shade700,
                onChanged: (value) => setState(() => selectedMethod = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedMethod),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Continue',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhoneNumberDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Phone Number Required',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Enter your phone number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = controller.text.trim();
              if (phone.isNotEmpty) {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.updateProfile({'phone': phone});
                if (mounted) Navigator.pop(context);
                _proceedToCheckout();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showAddressDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delivery Address',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'Enter your delivery address'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showInstructionsDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Special Instructions',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
              hintText: 'Any special requests? (optional)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.orange.shade700),
            const SizedBox(height: 16),
            Text(message, style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }

  void _showOrderSuccessDialog(OrderData? order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.green.shade50, shape: BoxShape.circle),
              child: Icon(Icons.check_circle,
                  size: 50, color: Colors.green.shade600),
            ),
            const SizedBox(height: 16),
            Text('Order Placed!',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Order #: ${order?.orderNumber ?? 'N/A'}',
                style: GoogleFonts.poppins(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Total: ETB ${order?.total.toStringAsFixed(2) ?? '0'}',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.orange.shade700)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // back to menu
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Continue',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear Cart',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Cart cleared'),
                    backgroundColor: Colors.green),
              );
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(
      BuildContext context, CartProvider cartProvider, CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Item',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Remove ${item.name} from cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              cartProvider.removeItem(item.id);
              Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
