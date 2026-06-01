import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/models/product_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});
  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _searchController = TextEditingController();
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { ref.read(productProvider.notifier).loadProducts(); }); }

  @override
  Widget build(BuildContext context) {
    final ps = ref.watch(productProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary, automaticallyImplyLeading: false,
        title: const Text('Katalog Digital', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded, color: Colors.white)),
        ],
      ),
      body: Column(children: [
        Container(
          color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => ref.read(productProvider.notifier).search(val),
            decoration: InputDecoration(
              hintText: 'Cari produk...', hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        Container(
          color: Colors.white, padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: SizedBox(
            height: 32,
            child: ListView(scrollDirection: Axis.horizontal, children: ['Semua', 'PVC', 'Plafon', 'Wallpanel'].map((cat) {
              final sel = ps.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => ref.read(productProvider.notifier).filterByCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.primary : AppColors.border)),
                    child: Text(cat, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? Colors.white : AppColors.textSecondary)),
                  ),
                ),
              );
            }).toList()),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ps.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ps.filteredProducts.isEmpty
                  ? const Center(child: Text('Produk tidak ditemukan', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.72),
                      itemCount: ps.filteredProducts.length,
                      itemBuilder: (context, index) => _CatalogCard(product: ps.filteredProducts[index]),
                    ),
        ),
      ]),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  final ProductModel product;
  const _CatalogCard({required this.product});

  Color _catColor(String c) => switch (c) { 'PVC' => AppColors.pvcColor, 'Plafon' => AppColors.plafonColor, 'Wallpanel' => AppColors.wallpanelColor, _ => AppColors.primary };
  IconData _catIcon(String c) => switch (c) { 'PVC' => Icons.view_module_rounded, 'Plafon' => Icons.grid_on_rounded, 'Wallpanel' => Icons.texture_rounded, _ => Icons.inventory_2_rounded };
  Color _stColor(StockStatus s) => switch (s) { StockStatus.aman => AppColors.success, StockStatus.menipis => const Color(0xFFE67E22), StockStatus.habis => AppColors.danger };
  Color _stBg(StockStatus s) => switch (s) { StockStatus.aman => AppColors.successLight, StockStatus.menipis => AppColors.warningLight, StockStatus.habis => AppColors.dangerLight };

  @override
  Widget build(BuildContext context) {
    final cc = _catColor(product.categoryNama);
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: product.foto != null && product.foto!.isNotEmpty
                    ? Image.network(
                        product.foto!.startsWith('http')
                            ? product.foto!
                            : '${ApiConstants.baseUrl}/${product.foto}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: cc.withValues(alpha: 0.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_catIcon(product.categoryNama), color: cc, size: 40),
                              const SizedBox(height: 4),
                              Text(product.categoryNama, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w500, color: cc)),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        color: cc.withValues(alpha: 0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_catIcon(product.categoryNama), color: cc, size: 40),
                            const SizedBox(height: 4),
                            Text(product.categoryNama, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w500, color: cc)),
                          ],
                        ),
                      ),
              ),
            ),
            Positioned(top: 8, left: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
              child: Text(product.kodeMotif, style: const TextStyle(fontFamily: 'Poppins', fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)),
            )),
            Positioned(top: 8, right: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: _stBg(product.stockStatus), borderRadius: BorderRadius.circular(6)),
              child: Text(product.stockStatusLabel, style: TextStyle(fontFamily: 'Poppins', fontSize: 8, fontWeight: FontWeight.w700, color: _stColor(product.stockStatus))),
            )),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.nama, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${product.ukuran} · ${product.stok} ${product.satuanShort}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.textSecondary)),
            Text('${CurrencyFormatter.format(product.hargaJual)}/${product.satuanShort}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
          child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membuka WhatsApp untuk ${product.nama}...'), backgroundColor: AppColors.whatsapp, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
              child: Container(
                height: 28,
                decoration: BoxDecoration(color: AppColors.whatsapp, borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_rounded, color: Colors.white, size: 12), SizedBox(width: 3), Text('Bagikan WA', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white))]),
              ),
            )),
            const SizedBox(width: 6),
            Expanded(child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membuka Instagram untuk ${product.nama}...'), backgroundColor: AppColors.instagram, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
              child: Container(
                height: 28,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE1306C), Color(0xFFF77737)]), borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12), SizedBox(width: 3), Text('Instagram', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white))]),
              ),
            )),
          ]),
        ),
      ]),
    );
  }
}
