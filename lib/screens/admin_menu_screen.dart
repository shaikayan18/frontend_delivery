// lib/screens/admin_menu_screen.dart - FIXED
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart'; // CHANGED: was menu.dart
import '../services/api_service.dart';
import 'add_edit_menu_screen.dart'; // NEW: for add/edit functionality

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final ApiService _apiService = ApiService();
  List<Restaurant> _restaurants = [];
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String? _selectedRestaurantId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _restaurants = await _apiService.getRestaurants();
    if (_restaurants.isNotEmpty) {
      _selectedRestaurantId = _restaurants.first.id;
      await _loadMenuItems();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadMenuItems() async {
    if (_selectedRestaurantId != null) {
      final menu = await _apiService.getMenu(_selectedRestaurantId!);
      setState(() {
        _menuItems = menu; // Now types match
      });
    }
  }

  Future<void> _deleteMenuItem(String menuId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _apiService.deleteMenuItem(menuId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadMenuItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Restaurant Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: DropdownButtonFormField<String>(
                    value: _selectedRestaurantId,
                    decoration: const InputDecoration(
                      labelText: 'Select Restaurant',
                      border: OutlineInputBorder(),
                    ),
                    items: _restaurants.map((restaurant) {
                      return DropdownMenuItem(
                        value: restaurant.id,
                        child: Text(restaurant.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRestaurantId = value;
                        _loadMenuItems();
                      });
                    },
                  ),
                ),

                // Menu Items List
                Expanded(
                  child: _menuItems.isEmpty
                      ? const Center(child: Text('No menu items'))
                      : ListView.builder(
                          itemCount: _menuItems.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final item = _menuItems[index];
                            return Card(
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.fastfood),
                                      );
                                    },
                                  ),
                                ),
                                title: Text(item.name),
                                subtitle: Text('₹${item.price} • ${item.category}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit Button
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddEditMenuScreen(
                                              menuItem: item,
                                              restaurantId: _selectedRestaurantId!,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          await _loadMenuItems();
                                        }
                                      },
                                    ),
                                    // Delete Button
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteMenuItem(item.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _selectedRestaurantId != null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditMenuScreen(
                      restaurantId: _selectedRestaurantId!,
                    ),
                  ),
                );
                if (result == true) {
                  await _loadMenuItems();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            )
          : null,
    );
  }
}