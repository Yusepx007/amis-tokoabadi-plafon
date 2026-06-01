import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});
  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).loadTransactions();
      ref.read(productProvider.notifier).loadProducts();
    });
  }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isSales = ref.watch(authProvider).user?.isSales ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary, automaticallyImplyLeading: false,
        title: Text(isSales ? 'Buat Pesanan' : 'Transaksi', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        bottom: isSales ? null : TabBar(
          controller: _tabController, indicatorColor: Colors.white, indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          labelColor: Colors.white, unselectedLabelColor: Colors.white60,
          tabs: const [Tab(text: 'Riwayat'), Tab(text: 'Buat Pesanan')],
        ),
      ),
      body: isSales ? const _CreateOrderTab() : TabBarView(controller: _tabController, children: const [_HistoryTab(), _CreateOrderTab()]),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trxState = ref.watch(transactionProvider);
    if (trxState.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (trxState.transactions.isEmpty) return const Center(child: Text('Belum ada transaksi', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: trxState.transactions.length,
      itemBuilder: (context, index) {
        final trx = trxState.transactions[index];
        final isLunas = trx.status == 'lunas';
        return Container(
          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: isLunas ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
              child: Icon(isLunas ? Icons.check_circle_rounded : Icons.pending_rounded, color: isLunas ? AppColors.success : const Color(0xFFE67E22), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(trx.kodeTransaksi, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text(trx.userName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(CurrencyFormatter.format(trx.totalHarga), style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: isLunas ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(8)),
                child: Text(trx.statusLabel, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: isLunas ? AppColors.success : const Color(0xFFE67E22))),
              ),
            ]),
          ]),
        );
      },
    );
  }
}

class _CreateOrderTab extends ConsumerStatefulWidget {
  const _CreateOrderTab();
  @override
  ConsumerState<_CreateOrderTab> createState() => _CreateOrderTabState();
}

class _CreateOrderTabState extends ConsumerState<_CreateOrderTab> {
  @override
  Widget build(BuildContext context) {
    final trxState = ref.watch(transactionProvider);
    final productState = ref.watch(productProvider);
    final user = ref.watch(authProvider).user;
    final availableProducts = productState.products.where((p) => p.stok > 0).toList();

    return Column(children: [
      Container(
        color: Colors.white, padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sales: ${user?.nama ?? 'Unknown'}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('Kode pesanan: TRX-${DateTime.now().millisecondsSinceEpoch % 10000}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
          ])),
        ]),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Pilih Produk dari Katalog', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          ...availableProducts.map((product) {
            final cartItem = trxState.cart.where((c) => c.product.id == product.id).firstOrNull;
            final qty = cartItem?.quantity ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: qty > 0 ? Border.all(color: AppColors.primary, width: 1.5) : Border.all(color: AppColors.divider),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.nama, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('Stok: ${product.stok} ${product.satuanShort} · ${CurrencyFormatter.format(product.hargaJual)}/${product.satuanShort}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
                ])),
                Row(children: [
                  if (qty > 0) ...[
                    GestureDetector(
                      onTap: () => ref.read(transactionProvider.notifier).decrementQuantity(product.id),
                      child: Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.remove, color: AppColors.primary, size: 16)),
                    ),
                    const SizedBox(width: 8),
                    Text('$qty', style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: () => ref.read(transactionProvider.notifier).addToCart(product),
                    child: Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: Colors.white, size: 16)),
                  ),
                ]),
              ]),
            );
          }),
          if (trxState.cart.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
              child: Column(children: [
                ...trxState.cart.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Expanded(child: Text('${item.product.nama} (${item.quantity} ${item.product.satuanShort})', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textPrimary))),
                    Text(CurrencyFormatter.format(item.subtotal), style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ]),
                )),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(CurrencyFormatter.format(trxState.cartTotal), style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: trxState.isLoading ? null : () async {
                  final trx = await ref.read(transactionProvider.notifier).generateInvoice(user?.id ?? 1, user?.nama ?? 'Sales');
                  if (!mounted || trx == null) return;
                  showDialog(context: context, builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 60, height: 60, decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: AppColors.success, size: 32)),
                      const SizedBox(height: 16),
                      const Text('Invoice Berhasil!', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(trx.kodeTransaksi, style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      Text(CurrencyFormatter.format(trx.totalHarga), style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      const Text('Stok telah dipotong otomatis', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary)),
                    ]),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: trxState.isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.receipt_long_rounded, size: 20), SizedBox(width: 8), Text('Generate Invoice & Potong Stok', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600))]),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    ]);
  }
}
