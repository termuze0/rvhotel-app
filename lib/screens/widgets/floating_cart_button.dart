import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/cart_provider.dart';

class FloatingCartButton extends StatelessWidget {
  const FloatingCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.items.isEmpty) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/cart'),
          backgroundColor: Colors.orange.shade700,
          icon: const Icon(Icons.shopping_cart),
          label: Row(
            children: [
              Text('${cartProvider.itemCount}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Text('items'),
              const SizedBox(width: 8),
              Container(height: 20, width: 1, color: Colors.white54),
              const SizedBox(width: 8),
              Text('ETB ${cartProvider.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        );
      },
    );
  }
}
