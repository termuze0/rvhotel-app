import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/product_provider.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/floating_cart_button.dart';
import '../tabs/menu_tab.dart';
import '../tabs/orders_tab.dart';
import '../tabs/profile_tab.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await Future.wait([
      productProvider.loadProducts(refresh: true),
      productProvider.loadCategories(),
    ]);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const HomeAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MenuTab(
            scrollController: _scrollController,
            searchController: _searchController,
            isSearching: _isSearching,
            onSearchingChanged: (value) => setState(() => _isSearching = value),
          ),
          OrdersTab(
              onTabChanged: (index) => setState(() => _selectedIndex = index)),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton:
          _selectedIndex == 0 ? const FloatingCartButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
