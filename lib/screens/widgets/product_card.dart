import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart =
            cartProvider.items.any((item) => item.id == product.id);
        final cartItem = cartProvider.getItemById(product.id);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(isInCart, cartItem),
                _buildDetailsSection(isInCart, cartItem),
              ],
            ),
          ),
        );
      },
    );
  }

  // Update the _buildImageSection method
  Widget _buildImageSection(bool isInCart, cartItem) {
    // Use the original image URL directly without transformations
    final imageUrl = product.imageFullUrl;

    print('Displaying image for: ${product.name}');
    print('Image URL: $imageUrl');
    print('Is Cloudinary: ${product.isCloudinaryImage}');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          product.hasImage
              ? CachedNetworkImage(
                  imageUrl: imageUrl, // Use original URL directly
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.orange.shade200,
                    child: const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('ERROR loading image: $error');
                    print('URL: $url');
                    return Container(
                      height: 110,
                      width: double.infinity,
                      color: Colors.orange.shade100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fastfood,
                              size: 40,
                              color: Colors.orange.shade400,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.orange.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  height: 110,
                  width: double.infinity,
                  color: Colors.orange.shade200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          // Rating Badge
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 8, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    product.averageRating.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Preparation Time Badge
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 8, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    '${product.preparationTime}',
                    style:
                        GoogleFonts.poppins(fontSize: 8, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(bool isInCart, cartItem) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: const Color(0xFF1A1A1A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(Icons.restaurant, size: 9, color: Colors.orange.shade700),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  product.hotel?.hotelName ?? 'Hotel',
                  style: GoogleFonts.poppins(
                      fontSize: 8, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              product.category,
              style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ETB ${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isInCart && cartItem != null)
                      Text(
                        'Qty: ${cartItem.quantity}',
                        style: GoogleFonts.poppins(
                            fontSize: 8,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (isInCart)
                    InkWell(
                      onTap: onRemoveFromCart,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.remove,
                            size: 14, color: Colors.red.shade600),
                      ),
                    ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onAddToCart,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isInCart
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(isInCart ? Icons.check : Icons.add,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
