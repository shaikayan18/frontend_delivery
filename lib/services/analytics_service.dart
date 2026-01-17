// lib/services/analytics_service.dart - NEW SERVICE
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/analytics_data.dart';
import 'auth_service.dart';

class AnalyticsService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Get summary data
  Future<AnalyticsSummary?> getSummary(String dateRange) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/analytics/summary?dateRange=$dateRange'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnalyticsSummary.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Analytics summary error: $e');
      return null;
    }
  }

  // Get chart data
  Future<List<ChartDataPoint>> getOrdersChart(String dateRange) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/analytics/orders-chart?dateRange=$dateRange'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> chartData = data['chartData'];
        return chartData
            .map((item) => ChartDataPoint.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Analytics chart error: $e');
      return [];
    }
  }

  // Get paginated orders
  Future<OrdersResponse?> getOrders({
    int page = 1,
    int limit = 10,
    String status = 'all',
    String dateRange = '7days',
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/analytics/orders?page=$page&limit=$limit&status=$status&dateRange=$dateRange',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrdersResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Analytics orders error: $e');
      return null;
    }
  }
}
