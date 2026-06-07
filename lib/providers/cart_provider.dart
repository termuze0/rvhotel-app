import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  // Check if cart is not empty
  bool get isNotEmpty => _items.isNotEmpty;

  // Get total number of items (sum of quantities)
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Get subtotal (sum of all item totals)
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  // Delivery fee (you can make this dynamic from API)
  double get deliveryFee => 50.0;

  // Tax (e.g., 15% VAT in Ethiopia)
  double get tax => subtotal * 0.15;

  // Grand total
  double get total => subtotal + deliveryFee + tax;

  // Get unique item count (number of different products)
  int get uniqueItemCount => _items.length;

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    if (existingIndex != -1) {
      _items[existingIndex] = CartItem(
        id: _items[existingIndex].id,
        name: _items[existingIndex].name,
        price: _items[existingIndex].price,
        quantity: _items[existingIndex].quantity + item.quantity,
        hotelName: _items[existingIndex].hotelName,
        hotelId: _items[existingIndex].hotelId,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void increaseQuantity(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = CartItem(
        id: _items[index].id,
        name: _items[index].name,
        price: _items[index].price,
        quantity: _items[index].quantity + 1,
        image: _items[index].image, // ← keep image too
        hotelName: _items[index].hotelName,
        hotelId: _items[index].hotelId, // ← fix
      );
      notifyListeners();
    }
  }

  void decreaseQuantity(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index] = CartItem(
          id: _items[index].id,
          name: _items[index].name,
          price: _items[index].price,
          quantity: _items[index].quantity - 1,
          image: _items[index].image,
          hotelName: _items[index].hotelName,
          hotelId: _items[index].hotelId, // ← fix
        );
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void updateQuantity(int id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = CartItem(
          id: _items[index].id,
          name: _items[index].name,
          price: _items[index].price,
          quantity: quantity,
          image: _items[index].image,
          hotelName: _items[index].hotelName,
          hotelId: _items[index].hotelId, // ← fix
        );
      }
      notifyListeners();
    }
  }

  // Get item by id (returns nullable)
  CartItem? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all items
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get total by hotel
  Map<String, double> getTotalByHotel() {
    final Map<String, double> hotelTotals = {};
    for (var item in _items) {
      final hotelName = item.hotelName ?? 'Restaurant';
      hotelTotals[hotelName] = (hotelTotals[hotelName] ?? 0) + item.total;
    }
    return hotelTotals;
  }

  // Get items by hotel
  Map<String, List<CartItem>> getItemsByHotel() {
    final Map<String, List<CartItem>> groupedItems = {};
    for (var item in _items) {
      final hotelName = item.hotelName ?? 'Restaurant';
      if (!groupedItems.containsKey(hotelName)) {
        groupedItems[hotelName] = [];
      }
      groupedItems[hotelName]!.add(item);
    }
    return groupedItems;
  }
}
