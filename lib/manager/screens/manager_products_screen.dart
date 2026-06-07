import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manager_provider.dart';
import '../../../models/product.dart';
import './manager_add_product_screen.dart';

class ManagerProductsScreen extends StatelessWidget {
  const ManagerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, managerProvider, child) {
        if (managerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = managerProvider.products;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManagerAddProductScreen()),
              );
              if (result == true) {
                managerProvider.loadProducts();
              }
            },
            backgroundColor: Colors.orange.shade700,
            child: const Icon(Icons.add),
          ),
          body: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No products yet',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first product',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => managerProvider.loadProducts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(
                          context, managerProvider, product);
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProductCard(
      BuildContext context, ManagerProvider provider, Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.hasImage
                      ? CachedNetworkImage(
                          imageUrl: product.imageFullUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.orange.shade100,
                            child: Icon(Icons.fastfood,
                                size: 40, color: Colors.orange.shade400),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.orange.shade100,
                          child: Icon(Icons.fastfood,
                              size: 40, color: Colors.orange.shade400),
                        ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ETB ${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit & Delete buttons
                Column(
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showEditDialog(context, provider, product),
                      icon: Icon(Icons.edit, color: Colors.blue.shade600),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () =>
                          _showDeleteDialog(context, provider, product),
                      icon: Icon(Icons.delete, color: Colors.red.shade600),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Availability toggle row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: product.isAvailable
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: product.isAvailable
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        product.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: product.isAvailable
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.isAvailable
                            ? 'Available for order'
                            : 'Unavailable',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: product.isAvailable
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: product.isAvailable,
                    onChanged: (value) =>
                        _toggleAvailability(context, provider, product),
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red.shade400,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAvailability(
      BuildContext context, ManagerProvider provider, Product product) async {
    final success = await provider.toggleProductAvailability(product.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${product.name} is now ${product.isAvailable ? 'unavailable' : 'available'}'
                : 'Failed to update availability',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showEditDialog(
      BuildContext context, ManagerProvider provider, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController =
        TextEditingController(text: product.price.toString());
    final categoryController = TextEditingController(text: product.category);
    final descriptionController =
        TextEditingController(text: product.description);
    final preparationTimeController =
        TextEditingController(text: product.preparationTime?.toString() ?? '');
    final isAvailable = ValueNotifier<bool>(product.isAvailable);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Product',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (ETB)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: preparationTimeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Preparation Time (minutes)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder(
                valueListenable: isAvailable,
                builder: (context, value, child) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available for order',
                            style: GoogleFonts.poppins(fontSize: 14)),
                        Switch(
                          value: value,
                          onChanged: (v) => isAvailable.value = v,
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedData = {
                'name': nameController.text.trim(),
                'price': double.tryParse(priceController.text) ?? product.price,
                'category': categoryController.text.trim(),
                'description': descriptionController.text.trim(),
                'preparation_time':
                    int.tryParse(preparationTimeController.text) ?? 0,
                'is_available': isAvailable.value,
              };
              final success =
                  await provider.updateProduct(product.id, updatedData);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Product updated successfully'),
                      backgroundColor: Colors.green),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(provider.error ?? 'Failed to update product'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
            child:
                Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, ManagerProvider provider, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Product',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.red.shade700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 60, color: Colors.red.shade400),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to delete "${product.name}"?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog first
              final success = await provider.deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '${product.name} deleted'
                        : provider.error ?? 'Failed to delete product'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child:
                Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
