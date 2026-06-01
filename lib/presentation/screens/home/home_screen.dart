import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../inventory/inventory_screen.dart';
import '../transaction/transaction_screen.dart';
import '../catalog/catalog_screen.dart';
import '../report/report_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = _getScreensForRole(user.role);
    final navItems = _getNavItemsForRole(user.role);
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, -3))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = safeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isSelected ? item.activeIcon : item.icon, color: isSelected ? AppColors.primary : AppColors.textHint, size: 24),
                        const SizedBox(height: 3),
                        Text(item.label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.primary : AppColors.textHint)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getScreensForRole(String role) {
    switch (role) {
      case 'pemilik':
        return const [DashboardScreen(), InventoryScreen(), TransactionScreen(), CatalogScreen(), ReportScreen()];
      case 'admin':
        return const [InventoryScreen(), TransactionScreen(), CatalogScreen(), ReportScreen()];
      case 'sales':
      default:
        return const [CatalogScreen(), TransactionScreen()];
    }
  }

  List<_NavItem> _getNavItemsForRole(String role) {
    switch (role) {
      case 'pemilik':
        return [
          _NavItem('Beranda', Icons.home_outlined, Icons.home_rounded),
          _NavItem('Stok', Icons.inventory_2_outlined, Icons.inventory_2_rounded),
          _NavItem('Transaksi', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
          _NavItem('Katalog', Icons.grid_view_outlined, Icons.grid_view_rounded),
          _NavItem('Laporan', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
        ];
      case 'admin':
        return [
          _NavItem('Stok', Icons.inventory_2_outlined, Icons.inventory_2_rounded),
          _NavItem('Transaksi', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
          _NavItem('Katalog', Icons.grid_view_outlined, Icons.grid_view_rounded),
          _NavItem('Laporan', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
        ];
      case 'sales':
      default:
        return [
          _NavItem('Katalog', Icons.grid_view_outlined, Icons.grid_view_rounded),
          _NavItem('Pesanan', Icons.add_shopping_cart_outlined, Icons.add_shopping_cart_rounded),
        ];
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  _NavItem(this.label, this.icon, this.activeIcon);
}
