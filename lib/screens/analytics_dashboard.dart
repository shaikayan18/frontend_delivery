// lib/screens/analytics_dashboard.dart - NEW SCREEN
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analytics_data.dart';
import '../services/analytics_service.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final AnalyticsService _analyticsService = AnalyticsService();

  AnalyticsSummary? _summary;
  List<ChartDataPoint> _chartData = [];
  OrdersResponse? _ordersResponse;

  bool _isLoading = true;
  String _selectedDateRange = '7days';
  String _selectedStatus = 'all';
  int _currentPage = 1;

  DateTime? _lastRefresh;
  static const _refreshInterval = Duration(minutes: 15);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load all data in parallel
    final results = await Future.wait([
      _analyticsService.getSummary(_selectedDateRange),
      _analyticsService.getOrdersChart(_selectedDateRange),
      _analyticsService.getOrders(
        page: _currentPage,
        status: _selectedStatus,
        dateRange: _selectedDateRange,
      ),
    ]);

    setState(() {
      _summary = results[0] as AnalyticsSummary?;
      _chartData = results[1] as List<ChartDataPoint>;
      _ordersResponse = results[2] as OrdersResponse?;
      _isLoading = false;
      _lastRefresh = DateTime.now();
    });
  }

  bool _shouldAutoRefresh() {
    if (_lastRefresh == null) return false;
    return DateTime.now().difference(_lastRefresh!) >= _refreshInterval;
  }

  @override
  Widget build(BuildContext context) {
    // Auto-refresh check
    if (_shouldAutoRefresh()) {
      Future.microtask(() => _loadData());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          // Date Range Filter
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (value) {
              setState(() {
                _selectedDateRange = value;
                _currentPage = 1;
              });
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: '7days', child: Text('Last 7 Days')),
            ],
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: 24),

                    // Order Status
                    _buildOrderStatusSection(),
                    const SizedBox(height: 24),

                    // Chart
                    _buildChartSection(),
                    const SizedBox(height: 24),

                    // Orders Table
                    _buildOrdersSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    if (_summary == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Orders',
                _summary!.summary.totalOrders.toString(),
                Icons.shopping_bag,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Revenue',
                '₹${_summary!.summary.totalRevenue.toStringAsFixed(0)}',
                Icons.currency_rupee,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Active Users',
          _summary!.summary.activeUsers.toString(),
          Icons.people,
          Colors.orange,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusSection() {
    if (_summary == null) return const SizedBox();

    final status = _summary!.orderStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusChip(
                'Completed',
                status.completed,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusChip(
                'Preparing',
                status.preparing,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusChip(
                'Placed',
                status.placed,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusChip(
                'Cancelled',
                status.cancelled,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    if (_chartData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No chart data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orders Over Time',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: CustomPaint(
                    painter: LineChartPainter(_chartData),
                    child: Container(),
                  ),
                ),
                const SizedBox(height: 16),
                // Chart Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Orders', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildOrdersSection() {
    if (_ordersResponse == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // Status Filter
            DropdownButton<String>(
              value: _selectedStatus,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'Placed', child: Text('Placed')),
                DropdownMenuItem(value: 'Preparing', child: Text('Preparing')),
                DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                  _currentPage = 1;
                });
                _loadData();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._ordersResponse!.orders.map((order) => _buildOrderCard(order)),
        const SizedBox(height: 16),
        // Pagination
        if (_ordersResponse!.pagination.totalPages > 1) _buildPagination(),
      ],
    );
  }

  Widget _buildOrderCard(AnalyticsOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: Text(
            order.itemCount.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('Order #${order.id.substring(order.id.length - 6)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${order.userName} (${order.userEmail})',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${order.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final pagination = _ordersResponse!.pagination;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1
              ? () {
                  setState(() => _currentPage--);
                  _loadData();
                }
              : null,
        ),
        Text(
          'Page $_currentPage of ${pagination.totalPages}',
          style: const TextStyle(fontSize: 14),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < pagination.totalPages
              ? () {
                  setState(() => _currentPage++);
                  _loadData();
                }
              : null,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Placed':
        return Colors.blue;
      case 'Preparing':
        return Colors.orange;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Simple Line Chart Painter
class LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxOrders = data.map((e) => e.orders).reduce((a, b) => a > b ? a : b);
    if (maxOrders == 0) return;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].orders / maxOrders * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = Colors.blue,
      );
    }

    canvas.drawPath(path, paint);

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      
      // Date label
      final dateLabel = data[i].date.substring(5); // MM-DD
      textPainter.text = TextSpan(
        text: dateLabel,
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 15, size.height + 5));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
