// lib/models/analytics_data.dart - NEW MODELS
class AnalyticsSummary {
  final Summary summary;
  final OrderStatus orderStatus;

  AnalyticsSummary({
    required this.summary,
    required this.orderStatus,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      summary: Summary.fromJson(json['summary']),
      orderStatus: OrderStatus.fromJson(json['orderStatus']),
    );
  }
}

class Summary {
  final int totalOrders;
  final double totalRevenue;
  final int activeUsers;

  Summary({
    required this.totalOrders,
    required this.totalRevenue,
    required this.activeUsers,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      activeUsers: json['activeUsers'] ?? 0,
    );
  }
}

class OrderStatus {
  final int completed;
  final int cancelled;
  final int placed;
  final int preparing;

  OrderStatus({
    required this.completed,
    required this.cancelled,
    required this.placed,
    required this.preparing,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      placed: json['placed'] ?? 0,
      preparing: json['preparing'] ?? 0,
    );
  }
}

class ChartDataPoint {
  final String date;
  final int orders;
  final double revenue;

  ChartDataPoint({
    required this.date,
    required this.orders,
    required this.revenue,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      date: json['date'] ?? '',
      orders: json['orders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class OrdersResponse {
  final List<AnalyticsOrder> orders;
  final Pagination pagination;

  OrdersResponse({
    required this.orders,
    required this.pagination,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] as List?)
              ?.map((item) => AnalyticsOrder.fromJson(item))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class AnalyticsOrder {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final double total;
  final String status;
  final DateTime createdAt;
  final int itemCount;

  AnalyticsOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.itemCount,
  });

  factory AnalyticsOrder.fromJson(Map<String, dynamic> json) {
    final user = json['user_id'];
    return AnalyticsOrder(
      id: json['_id'] ?? '',
      userId: user is String ? user : (user?['_id'] ?? ''),
      userName: user is Map ? (user['name'] ?? 'N/A') : 'N/A',
      userEmail: user is Map ? (user['email'] ?? 'N/A') : 'N/A',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      itemCount: (json['items'] as List?)?.length ?? 0,
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalOrders;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalOrders,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalOrders: json['totalOrders'] ?? 0,
      limit: json['limit'] ?? 10,
    );
  }
}
