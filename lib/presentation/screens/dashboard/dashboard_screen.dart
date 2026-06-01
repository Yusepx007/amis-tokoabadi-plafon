import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../routes/app_routes.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
      ref.read(transactionProvider.notifier).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final productState = ref.watch(productProvider);
    final transactionState = ref.watch(transactionProvider);
    final user = authState.user;
    final criticalProducts = productState.criticalStockProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130, floating: false, pinned: true,
            backgroundColor: AppColors.primary, elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Stack(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26)),
                  if (criticalProducts.isNotEmpty)
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                        child: Center(child: Text('${criticalProducts.length}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 22),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.navyGradient),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.store_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dashboard Pemilik', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                            Text('Halo, ${user?.nama ?? 'Pemilik'} 👋', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMetricCards(transactionState, criticalProducts),
                const SizedBox(height: 20),
                if (criticalProducts.isNotEmpty) ...[
                  const Text('🔔 Notifikasi Stok Otomatis', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  _buildStockNotifications(criticalProducts),
                  const SizedBox(height: 20),
                ],
                const Text('📋 Transaksi terkini hari ini', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                _buildRecentTransactions(transactionState.transactions),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCards(TransactionState trxState, List<ProductModel> critical) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
      children: [
        _MetricCard(label: 'Omzet Hari Ini', value: CurrencyFormatter.format(trxState.todayOmzet), icon: Icons.trending_up_rounded, iconColor: AppColors.primaryLight, bgColor: AppColors.primary.withValues(alpha: 0.05)),
        _MetricCard(label: 'Nota Terjual', value: '${trxState.todayTransactionCount} Transaksi', icon: Icons.receipt_rounded, iconColor: const Color(0xFF9B59B6), bgColor: const Color(0xFF9B59B6).withValues(alpha: 0.08)),
        _MetricCard(label: 'Laba Bersih', value: CurrencyFormatter.format(trxState.todayLaba), icon: Icons.account_balance_wallet_rounded, iconColor: AppColors.success, bgColor: AppColors.successLight),
        _MetricCard(label: 'Stok Kritis', value: '${critical.length} Produk', icon: Icons.warning_amber_rounded, iconColor: AppColors.danger, bgColor: AppColors.dangerLight),
      ],
    );
  }

  Widget _buildStockNotifications(List<ProductModel> products) {
    return Column(
      children: products.take(4).map((product) {
        final isMenipis = product.stockStatus == StockStatus.menipis;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMenipis ? AppColors.warningLight : AppColors.dangerLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isMenipis ? const Color(0xFFE67E22).withValues(alpha: 0.3) : AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(isMenipis ? Icons.warning_amber_rounded : Icons.error_outline_rounded, color: isMenipis ? const Color(0xFFE67E22) : AppColors.danger, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${product.nama} — Sisa ${product.stok} ${product.satuanShort}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: isMenipis ? const Color(0xFF633806) : AppColors.danger)),
                    Text(isMenipis ? 'Di bawah stok minimum' : 'Segera restock', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: (isMenipis ? const Color(0xFF633806) : AppColors.danger).withValues(alpha: 0.7))),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactions(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('Belum ada transaksi hari ini', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary))),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: transactions.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final trx = entry.value;
          final isLast = index == (transactions.length > 5 ? 4 : transactions.length - 1);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: trx.status == 'lunas' ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(10)),
                      child: Icon(trx.status == 'lunas' ? Icons.check_circle_outline_rounded : Icons.pending_outlined, color: trx.status == 'lunas' ? AppColors.success : const Color(0xFFE67E22), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(trx.userName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Text(trx.kodeTransaksi, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
                      ]),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(CurrencyFormatter.format(trx.totalHarga), style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: trx.status == 'lunas' ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(trx.statusLabel, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w500, color: trx.status == 'lunas' ? AppColors.success : const Color(0xFFE67E22))),
                      ),
                    ]),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 64, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor, bgColor;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.iconColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)),
          ]),
        ],
      ),
    );
  }
}
