// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/sale_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/products/product_list_screen.dart';
import 'screens/categories/category_list_screen.dart';
import 'screens/sales/sale_list_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'splashScreen.dart'; // Ajoutez cette importation

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(), // SplashScreen comme écran initial
        routes: {
          '/main': (context) => const MainScreen(), // Route pour l'écran principal
        },
      ),
    );
  }
}

// Votre classe MainScreen reste inchangée
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductListScreen(),
    CategoryListScreen(),
    SaleListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _tabController.animateTo(index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Produits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Catégories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Ventes',
            ),
          ],
        ),
      ),
    );
  }
}