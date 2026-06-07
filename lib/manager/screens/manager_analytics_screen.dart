import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/manager_provider.dart';
import '../../models/order.dart';
import '../../models/product.dart';

class ManagerAnalyticsScreen extends StatefulWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  State<ManagerAnalyticsScreen> createState() => _ManagerAnalyticsScreenState();
}

class _ManagerAnalyticsScreenState extends State<ManagerAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, managerProvider, child) {
        if (managerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  'Analytics Dashboard',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.orange.shade700,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                floating: true,
                pinned: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey.shade600,
                          indicator: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          dividerColor: Colors.transparent,
                          labelStyle:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          tabs: const [
                            Tab(text: 'Overview'),
                            Tab(text: 'Orders'),
                            Tab(text: 'Products'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: _buildTabContent(managerProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(ManagerProvider provider) {
    switch (_tabController.index) {
      case 0:
        return _buildOverviewTab(provider);
      case 1:
        return _buildOrdersTab(provider);
      case 2:
        return _buildProductsTab(provider);
      default:
        return _buildOverviewTab(provider);
    }
  }

  // ==================== OVERVIEW TAB ====================

  Widget _buildOverviewTab(ManagerProvider provider) {
    return Column(
      children: [
        _buildPeriodSelector(),
        const SizedBox(height: 16),
        _buildKeyMetricsRow(provider),
        const SizedBox(height: 16),
        _buildRevenueChart(),
        const SizedBox(height: 16),
        _buildOrdersChart(),
        const SizedBox(height: 16),
        _buildOrderStatusDistribution(provider),
        const SizedBox(height: 16),
        _buildTopProducts(provider),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.orange.shade700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    period,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyMetricsRow(ManagerProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Revenue',
            value: 'ETB ${provider.totalRevenue.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
            change: '+12.5%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'Total Orders',
            value: provider.orders.length.toString(),
            icon: Icons.receipt_long,
            color: Colors.blue,
            change: '+8.2%',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? change,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          if (change != null)
            Row(
              children: [
                Icon(Icons.trending_up, size: 12, color: Colors.green.shade600),
                const SizedBox(width: 2),
                Text(
                  change,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ---- Revenue Line Chart (Syncfusion) ----

  Widget _buildRevenueChart() {
    final data = [
      _ChartData('Jan', 4500),
      _ChartData('Feb', 5200),
      _ChartData('Mar', 4800),
      _ChartData('Apr', 6100),
      _ChartData('May', 5800),
      _ChartData('Jun', 7200),
      _ChartData('Jul', 6900),
      _ChartData('Aug', 8400),
      _ChartData('Sep', 7800),
      _ChartData('Oct', 9200),
      _ChartData('Nov', 8800),
      _ChartData('Dec', 10500),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Trend',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up,
                        size: 12, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '+23.5%',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: GoogleFonts.poppins(fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.value,
                  color: Colors.orange.shade700.withValues(alpha: 0.15),
                  borderColor: Colors.orange.shade700,
                  borderWidth: 3,
                  splineType: SplineType.natural,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    color: Colors.orange.shade700,
                    borderColor: Colors.white,
                    borderWidth: 2,
                    height: 6,
                    width: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Orders Bar Chart (Syncfusion) ----

  Widget _buildOrdersChart() {
    final data = [
      _ChartData('J', 32),
      _ChartData('F', 38),
      _ChartData('M', 35),
      _ChartData('A', 42),
      _ChartData('M', 48),
      _ChartData('J', 55),
      _ChartData('J', 52),
      _ChartData('A', 60),
      _ChartData('S', 58),
      _ChartData('O', 65),
      _ChartData('N', 62),
      _ChartData('D', 75),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders Trend',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: GoogleFonts.poppins(fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
                maximum: 100,
              ),
              series: <CartesianSeries>[
                ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.value,
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(4),
                  spacing: 0.2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Order Status Pie Chart (Syncfusion) ----

  Widget _buildOrderStatusDistribution(ManagerProvider provider) {
    final total = provider.pendingOrdersCount +
        provider.preparingOrdersCount +
        provider.outForDeliveryCount +
        provider.completedOrdersCount;

    final statusData = [
      _PieData('Pending', provider.pendingOrdersCount, Colors.orange),
      _PieData('Preparing', provider.preparingOrdersCount, Colors.blue),
      _PieData(
          'Out for Delivery', provider.outForDeliveryCount, Colors.deepOrange),
      _PieData('Delivered', provider.completedOrdersCount, Colors.green),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status Distribution',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: SfCircularChart(
                    margin: EdgeInsets.zero,
                    series: <CircularSeries>[
                      DoughnutSeries<_PieData, String>(
                        dataSource: statusData,
                        xValueMapper: (d, _) => d.label,
                        yValueMapper: (d, _) =>
                            d.count > 0 ? d.count.toDouble() : 0.001,
                        pointColorMapper: (d, _) => d.color,
                        innerRadius: '55%',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.inside,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          builder:
                              (data, point, series, pointIndex, seriesIndex) {
                            final d = data as _PieData;
                            final pct =
                                total > 0 ? (d.count / total * 100) : 0.0;
                            return pct > 10
                                ? Text(
                                    '${pct.toStringAsFixed(0)}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: statusData.map((d) {
                    final pct = total > 0 ? (d.count / total * 100) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: d.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              d.label,
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(ManagerProvider provider) {
    final topProducts = provider.products.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Products',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          if (topProducts.isEmpty)
            Center(
              child: Text(
                'No products available',
                style: GoogleFonts.poppins(color: Colors.grey.shade500),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topProducts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final product = topProducts[index];
                return Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      'ETB ${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // ==================== ORDERS TAB ====================

  Widget _buildOrdersTab(ManagerProvider provider) {
    final orders = provider.orders;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOrderSummaryCard(
                title: 'Total Orders',
                value: orders.length.toString(),
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOrderSummaryCard(
                title: 'Avg. Order Value',
                value: orders.isEmpty
                    ? 'ETB 0'
                    : 'ETB ${(orders.fold(0.0, (sum, o) => sum + o.total) / orders.length).toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildOrdersByStatus(provider),
        const SizedBox(height: 16),
        _buildRecentOrdersList(provider),
      ],
    );
  }

  Widget _buildOrderSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersByStatus(ManagerProvider provider) {
    final statuses = [
      {
        'status': 'Pending',
        'count': provider.pendingOrdersCount,
        'color': Colors.orange
      },
      {
        'status': 'Preparing',
        'count': provider.preparingOrdersCount,
        'color': Colors.blue
      },
      {
        'status': 'Out for Delivery',
        'count': provider.outForDeliveryCount,
        'color': Colors.deepOrange
      },
      {
        'status': 'Delivered',
        'count': provider.completedOrdersCount,
        'color': Colors.green
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders by Status',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...statuses.map((status) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: status['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            status['status'] as String,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                        Text(
                          '${status['count']} orders',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: provider.orders.isEmpty
                          ? 0
                          : (status['count'] as int) / provider.orders.length,
                      backgroundColor: Colors.grey.shade200,
                      color: status['color'] as Color,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersList(ManagerProvider provider) {
    final recentOrders = provider.orders.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Orders',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          if (recentOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No recent orders'),
              ),
            )
          else
            ...recentOrders.map((order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRecentOrderItem(order),
                )),
        ],
      ),
    );
  }

  Widget _buildRecentOrderItem(OrderData order) {
    Color getStatusColor(String status) {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'preparing':
          return Colors.blue;
        case 'out':
          return Colors.deepOrange;
        case 'done':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getStatusColor(order.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt,
              color: getStatusColor(order.status), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.orderNumber}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '${order.items.length} items • ETB ${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: getStatusColor(order.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            order.status,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: getStatusColor(order.status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== PRODUCTS TAB ====================

  Widget _buildProductsTab(ManagerProvider provider) {
    final products = provider.products;
    final totalProducts = products.length;
    final availableProducts = products.where((p) => p.isAvailable).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildProductStatCard(
                title: 'Total Products',
                value: totalProducts.toString(),
                icon: Icons.restaurant_menu,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProductStatCard(
                title: 'Available',
                value: availableProducts.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildProductStatCard(
                title: 'Out of Stock',
                value: (totalProducts - availableProducts).toString(),
                icon: Icons.warning_amber,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProductStatCard(
                title: 'Categories',
                value:
                    products.map((p) => p.category).toSet().length.toString(),
                icon: Icons.category,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Inventory',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              if (products.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No products added yet'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductListItem(product);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 50,
            height: 50,
            color: Colors.orange.shade100,
            child:
                Icon(Icons.fastfood, size: 25, color: Colors.orange.shade400),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                'ETB ${product.price.toStringAsFixed(2)} • ${product.category}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                product.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product.isAvailable ? 'In Stock' : 'Out of Stock',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: product.isAvailable
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== DATA MODELS ====================

class _ChartData {
  _ChartData(this.label, this.value);
  final String label;
  final double value;
}

class _PieData {
  _PieData(this.label, this.count, this.color);
  final String label;
  final int count;
  final Color color;
}
