import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/product_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  final _categories = ['Semua', 'PVC', 'Plafon', 'Wallpanel'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final authState = ref.watch(authProvider);
    final canManage = authState.user?.canManageStock ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary, automaticallyImplyLeading: false,
        title: const Text('Inventori Produk', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
          if (canManage) IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => ref.read(productProvider.notifier).search(val),
                decoration: InputDecoration(
                  hintText: 'Cari kode motif / nama...', hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
                  filled: true, fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal, itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = productState.selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => ref.read(productProvider.notifier).filterByCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(cat, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Colors.white : AppColors.textSecondary)),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(children: [Text('${productState.filteredProducts.length} produk ditemukan', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary))]),
          ),
          Expanded(
            child: productState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : productState.filteredProducts.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textHint), const SizedBox(height: 12),
                        const Text('Produk tidak ditemukan', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: productState.filteredProducts.length,
                        itemBuilder: (context, index) => _ProductListItem(product: productState.filteredProducts[index]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final ProductModel product;
  const _ProductListItem({required this.product});

  Color _statusColor(StockStatus s) => switch (s) { StockStatus.aman => AppColors.success, StockStatus.menipis => const Color(0xFFE67E22), StockStatus.habis => AppColors.danger };
  Color _statusBg(StockStatus s) => switch (s) { StockStatus.aman => AppColors.successLight, StockStatus.menipis => AppColors.warningLight, StockStatus.habis => AppColors.dangerLight };
  Color _catColor(String c) => switch (c) { 'PVC' => AppColors.pvcColor, 'Plafon' => AppColors.plafonColor, 'Wallpanel' => AppColors.wallpanelColor, _ => AppColors.primary };
  IconData _catIcon(String c) => switch (c) { 'PVC' => Icons.view_module_rounded, 'Plafon' => Icons.grid_on_rounded, 'Wallpanel' => Icons.texture_rounded, _ => Icons.inventory_2_rounded };

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(product.stockStatus);
    final sb = _statusBg(product.stockStatus);
    final cc = _catColor(product.categoryNama);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: cc.withValues(alpha: 0.12)),
                child: product.foto != null && product.foto!.isNotEmpty
                    ? Image.network(
                        product.foto!.startsWith('http')
                            ? product.foto!
                            : '${ApiConstants.baseUrl}/${product.foto}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_catIcon(product.categoryNama), color: cc, size: 22),
                            Text(product.categoryNama.length >= 3 ? product.categoryNama.substring(0, 3) : product.categoryNama, style: TextStyle(fontFamily: 'Poppins', fontSize: 8, fontWeight: FontWeight.w600, color: cc)),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_catIcon(product.categoryNama), color: cc, size: 22),
                          Text(product.categoryNama.length >= 3 ? product.categoryNama.substring(0, 3) : product.categoryNama, style: TextStyle(fontFamily: 'Poppins', fontSize: 8, fontWeight: FontWeight.w600, color: cc)),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.nama, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${product.ukuran} · ${product.satuan}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('${product.stok} ${product.satuanShort}', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: sc)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: sb, borderRadius: BorderRadius.circular(6)),
                    child: Text(product.stockStatusLabel, style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w600, color: sc)),
                  ),
                ]),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(CurrencyFormatter.format(product.hargaJual), style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('/${product.satuanShort}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                child: Text(product.kodeMotif, style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
