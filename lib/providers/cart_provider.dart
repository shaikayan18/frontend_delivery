// lib/providers/cart_provider.dart - FIXED
import 'package:flutter/material.dart';
import '../models/menu_item.dart'; // CHANGED: was menu.dart

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.menuItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(MenuItem menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity++;
    } else {
      _items[menuItem.id] = CartItem(menuItem: menuItem);
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    _items.remove(menuItemId);
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (_items.containsKey(menuItemId)) {
      if (quantity > 0) {
        _items[menuItemId]!.quantity = quantity;
      } else {
        _items.remove(menuItemId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Get order items in the format expected by the API
  List<Map<String, dynamic>> getOrderItems() {
    return _items.values.map((cartItem) {
      return {
        'menu_id': cartItem.menuItem.id,
        'name': cartItem.menuItem.name,
        'price': cartItem.menuItem.price,
        'quantity': cartItem.quantity,
      };
    }).toList();
  }
}