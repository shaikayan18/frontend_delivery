// lib/services/api_service.dart - COMPLETE WORKING VERSION
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import '../config/api_config.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import 'auth_service.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // ==================== RESTAURANTS ====================
  
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/restaurants'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Restaurant.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get restaurants error: $e');
      return [];
    }
  }

  Future<bool> updateRestaurantImage(String restaurantId, String imageUrl) async {
    try {
      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/api/restaurants/$restaurantId/image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'image': imageUrl}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update restaurant image error: $e');
      return false;
    }
  }

  // ==================== MENU ====================
  
  Future<List<MenuItem>> getMenu(String restaurantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/$restaurantId/menu'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MenuItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get menu error: $e');
      return [];
    }
  }

  Future<bool> addMenuItem(MenuItem menuItem) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/menu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(menuItem.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Add menu error: $e');
      return false;
    }
  }

  Future<bool> updateMenuItem(String menuId, MenuItem menuItem) async {
    try {
      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/api/menu/$menuId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(menuItem.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update menu error: $e');
      return false;
    }
  }

  Future<bool> deleteMenuItem(String menuId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/menu/$menuId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Delete menu error: $e');
      return false;
    }
  }

  // ==================== ORDERS ====================
  
  Future<bool> placeOrder(List<Map<String, dynamic>> items, double total) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': items,
          'total': total,
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Place order error: $e');
      return false;
    }
  }

  Future<List<Order>> getOrderHistory() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get order history error: $e');
      return [];
    }
  }

  Future<List<Order>> getAllOrders() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get all orders error: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final token = await _authService.getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Update order status error: $e');
      return false;
    }
  }

  // ==================== IMAGE UPLOAD ====================
  
  Future<String?> uploadImage(File imageFile) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null || token.isEmpty) {
        print('Upload error: No authentication token');
        return null;
      }

      print('Starting upload...');
      print('File path: ${imageFile.path}');
      print('Base URL: $baseUrl');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      
      // Get proper file extension and MIME type
      final filename = imageFile.path.split('/').last;
      MediaType? contentType;
      
      if (filename.toLowerCase().endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (filename.toLowerCase().endsWith('.jpg') || filename.toLowerCase().endsWith('.jpeg')) {
        contentType = MediaType('image', 'jpeg');
      } else if (filename.toLowerCase().endsWith('.gif')) {
        contentType = MediaType('image', 'gif');
      } else if (filename.toLowerCase().endsWith('.webp')) {
        contentType = MediaType('image', 'webp');
      }
      
      print('File name: $filename');
      print('Content type: $contentType');
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: filename,
          contentType: contentType,
        ),
      );

      print('Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          final imageUrl = jsonData['imageUrl'];
          print('Upload successful: $imageUrl');
          return imageUrl;
        } catch (e) {
          print('JSON parse error: $e');
          print('Response was: ${response.body}');
          return null;
        }
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}