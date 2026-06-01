import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../core/constants/api_constants.dart';

class ProductState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String selectedCategory;

  const ProductState({
    this.products = const [],
    this.filteredProducts = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory = 'Semua',
  });

  ProductState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ProductState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  List<ProductModel> get criticalStockProducts =>
      products.where((p) => p.stockStatus != StockStatus.aman).toList();
}

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(const ProductState());

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API
      final products = ProductModel.mockProducts;
      state = state.copyWith(
        products: products,
        filteredProducts: products,
        isLoading: false,
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.products}'),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> productsList = data['products'] ?? [];
        final products = productsList.map((e) => ProductModel.fromJson(e)).toList();
        
        state = state.copyWith(
          products: products,
          filteredProducts: products,
          isLoading: false,
        );
        // Re-apply search or category filters if they are currently set
        _applyFilters(state.searchQuery.toLowerCase(), state.selectedCategory);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] ?? 'Gagal memuat produk dari server',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Koneksi gagal: $e',
      );
    }
  }

  void search(String query) {
    final q = query.toLowerCase();
    state = state.copyWith(searchQuery: query);
    _applyFilters(q, state.selectedCategory);
  }

  void filterByCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters(state.searchQuery.toLowerCase(), category);
  }

  void _applyFilters(String query, String category) {
    var filtered = state.products;

    if (category != 'Semua') {
      filtered = filtered.where((p) => p.categoryNama == category).toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((p) =>
          p.nama.toLowerCase().contains(query) ||
          p.kodeMotif.toLowerCase().contains(query)).toList();
    }

    state = state.copyWith(filteredProducts: filtered);
  }

  Future<bool> addProduct(ProductModel product) async {
    state = state.copyWith(isLoading: true, error: null);

    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final updated = [...state.products, product];
      state = state.copyWith(products: updated, filteredProducts: updated, isLoading: false);
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addProduct}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product.toJson()),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final newProduct = ProductModel.fromJson(data['product']);
        final updated = [...state.products, newProduct];
        state = state.copyWith(products: updated, filteredProducts: updated, isLoading: false);
        _applyFilters(state.searchQuery.toLowerCase(), state.selectedCategory);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] ?? 'Gagal menambahkan produk',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Koneksi gagal: $e',
      );
      return false;
    }
  }

  Future<bool> updateStock(int productId, int newStock) async {
    // If mocking, update local state
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      _updateLocalStockState(productId, newStock);
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateStock}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': productId,
          'stok': newStock,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _updateLocalStockState(productId, newStock);
        return true;
      } else {
        state = state.copyWith(
          error: data['message'] ?? 'Gagal memperbarui stok di server',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Koneksi gagal: $e',
      );
      return false;
    }
  }

  void _updateLocalStockState(int productId, int newStock) {
    final updated = state.products.map((p) {
      if (p.id == productId) {
        return ProductModel(
          id: p.id,
          kodeMotif: p.kodeMotif,
          nama: p.nama,
          categoryId: p.categoryId,
          categoryNama: p.categoryNama,
          ukuran: p.ukuran,
          satuan: p.satuan,
          hargaBeli: p.hargaBeli,
          hargaJual: p.hargaJual,
          stok: newStock,
          stokMinimum: p.stokMinimum,
          foto: p.foto,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(products: updated, filteredProducts: updated);
    _applyFilters(state.searchQuery.toLowerCase(), state.selectedCategory);
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier();
});
