// lib/screens/admin_dashboard.dart (ENHANCED VERSION)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';
import 'add_edit_menu_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
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
      _menuItems = await _apiService.getMenu(_selectedRestaurantId!);
      setState(() {});
    }
  }

  Future<void> _updateRestaurantImage() async {
    if (_selectedRestaurantId == null) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _isLoading = true);
      
      final imageUrl = await _apiService.uploadImage(File(image.path));
      if (imageUrl != null) {
        final success = await _apiService.updateRestaurantImage(
          _selectedRestaurantId!,
          imageUrl,
        );
        
        if (success) {
          _showMessage('Restaurant image updated successfully', Colors.green);
          await _loadData();
        } else {
          _showMessage('Failed to update image', Colors.red);
        }
      }
      
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
        _showMessage('Item deleted successfully', Colors.green);
        await _loadMenuItems();
      } else {
        _showMessage('Failed to delete item', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          if (_selectedRestaurantId != null)
            IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: _updateRestaurantImage,
              tooltip: 'Update Restaurant Image',
            ),
        ],
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
                      prefixIcon: Icon(Icons.restaurant),
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
                      ? const Center(
                          child: Text('No menu items. Tap + to add.'),
                        )
                      : ListView.builder(
                          itemCount: _menuItems.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final item = _menuItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
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
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('₹${item.price} • ${item.category}'),
                                    if (item.description != null)
                                      Text(
                                        item.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
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