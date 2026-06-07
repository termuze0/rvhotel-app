import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'manager/providers/manager_provider.dart'; // add this
import 'screens/auth/login_screen.dart';
import 'screens/home/customer_home_screen.dart';
import 'screens/home/cart_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HotelDeliveryApp());
}

class HotelDeliveryApp extends StatelessWidget {
  const HotelDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ManagerProvider()), // add this
      ],
      child: MaterialApp(
        title: 'Hotel Delivery',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: GoogleFonts.poppins().fontFamily,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const CustomerHomeScreen(),
          '/cart': (context) => const CartScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
