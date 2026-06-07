import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/manager_provider.dart';
import '../../providers/auth_provider.dart';
import 'manager_orders_screen.dart';
import 'manager_products_screen.dart';
import 'manager_reviews_screen.dart'; // Changed from manager_analytics_screen
import 'manager_profile_screen.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ManagerOrdersScreen(),
    const ManagerProductsScreen(),
    const ManagerReviewsScreen(), // Changed to Reviews Screen
    const ManagerProfileScreen(),
  ];

  final List<String> _titles = [
    'Orders',
    'Products',
    'Reviews', // Changed from 'review' to 'Reviews'
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final managerProvider =
        Provider.of<ManagerProvider>(context, listen: false);
    await Future.wait([
      managerProvider.loadOrders(),
      managerProvider.loadProducts(),
      // Removed loadAnalytics() - not needed for reviews
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hotelName = authProvider.user?.hotelName ?? 'Hotel Manager';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.orange.shade700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Hotel selector (if manager manages multiple hotels)
          PopupMenuButton<int>(
            icon: Icon(Icons.business, color: Colors.orange.shade700),
            onSelected: (value) {
              final managerProvider =
                  Provider.of<ManagerProvider>(context, listen: false);
              managerProvider.setHotelId(value);
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text('Grand Hotel')),
              const PopupMenuItem(value: 2, child: Text('Hilton Addis')),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.store, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  hotelName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons
                .rate_review), // Changed from Icons.analytics to Icons.review
            label: 'Reviews', // Changed from 'Analytics' to 'Reviews'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
