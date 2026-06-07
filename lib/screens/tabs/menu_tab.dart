import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/product.dart';
import '../../../models/cart_item.dart';
import '../widgets/home_welcome_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/product_card.dart';
import '../home/food_detail_screen.dart';

class MenuTab extends StatefulWidget {
  final ScrollController scrollController;
  final TextEditingController searchController;
  final bool isSearching;
  final ValueChanged<bool> onSearchingChanged;

  const MenuTab({
    super.key,
    required this.scrollController,
    required this.searchController,
    required this.isSearching,
    required this.onSearchingChanged,
  });

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  void _addToCart(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final exists = cartProvider.items.any((item) => item.id == product.id);

    if (exists) {
      cartProvider.increaseQuantity(product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} quantity increased'),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      cartProvider.addItem(CartItem(
        id: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
        hotelName: product.hotel?.hotelName,
        hotelId: product.hotelId,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _removeFromCart(Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final exists = cartProvider.items.any((item) => item.id == product.id);

    if (exists) {
      final cartItem = cartProvider.getItemById(product.id);
      if (cartItem != null) {
        if (cartItem.quantity > 1) {
          cartProvider.decreaseQuantity(product.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} quantity decreased'),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          cartProvider.removeItem(product.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} removed from cart'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    }
  }

  void _navigateToFoodDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeSearchBar(
          controller: widget.searchController,
          onSearchChanged: (value) {
            widget.onSearchingChanged(value.isNotEmpty);
            Provider.of<ProductProvider>(context, listen: false)
                .searchProducts(value);
          },
          onClear: () {
            widget.searchController.clear();
            widget.onSearchingChanged(false);
            Provider.of<ProductProvider>(context, listen: false).clearSearch();
          },
        ),
        const HomeCategoriesSection(),
        Expanded(child: _buildProductsList()),
      ],
    );
  }

  Widget _buildProductsList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading && productProvider.products.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading delicious food...'),
              ],
            ),
          );
        }

        if (productProvider.error != null && productProvider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  productProvider.error!,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => productProvider.loadProducts(refresh: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        if (productProvider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fastfood_outlined,
                    size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  widget.isSearching ? 'No items found' : 'No items available',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isSearching
                      ? 'Try searching for something else'
                      : 'Check back later for delicious items',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey.shade500),
                ),
                if (widget.isSearching) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      widget.searchController.clear();
                      widget.onSearchingChanged(false);
                      Provider.of<ProductProvider>(context, listen: false)
                          .clearSearch();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700),
                    child: const Text('Clear Search'),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await productProvider.loadProducts(refresh: true);
          },
          child: GridView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return ProductCard(
                product: product,
                onTap: () => _navigateToFoodDetail(product),
                onAddToCart: () => _addToCart(product),
                onRemoveFromCart: () => _removeFromCart(product),
              );
            },
          ),
        );
      },
    );
  }
}
