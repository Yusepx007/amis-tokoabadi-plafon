import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';
import '../models/product_model.dart';
import 'product_provider.dart';
import '../../core/constants/api_constants.dart';

// Cart item for order creation
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.hargaJual * quantity;
}

class TransactionState {
  final List<TransactionModel> transactions;
  final List<CartItem> cart;
  final bool isLoading;
  final String? error;
  final TransactionModel? lastTransaction;

  const TransactionState({
    this.transactions = const [],
    this.cart = const [],
    this.isLoading = false,
    this.error,
    this.lastTransaction,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    List<CartItem>? cart,
    bool? isLoading,
    String? error,
    TransactionModel? lastTransaction,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastTransaction: lastTransaction ?? this.lastTransaction,
    );
  }

  double get cartTotal =>
      cart.fold(0, (sum, item) => sum + item.subtotal);

  double get todayOmzet => transactions
      .where((t) => t.status == 'lunas' &&
          t.tanggal.day == DateTime.now().day &&
          t.tanggal.month == DateTime.now().month)
      .fold(0, (sum, t) => sum + t.totalHarga);

  int get todayTransactionCount => transactions
      .where((t) => t.tanggal.day == DateTime.now().day &&
          t.tanggal.month == DateTime.now().month)
      .length;

  double get todayLaba => todayOmzet * 0.22; // approx margin
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final ProductNotifier _productNotifier;

  TransactionNotifier(this._productNotifier) : super(const TransactionState());

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(
        transactions: TransactionModel.mockTransactions,
        isLoading: false,
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactions}'),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> transactionsList = data['transactions'] ?? [];
        final transactions = transactionsList.map((e) => TransactionModel.fromJson(e)).toList();
        
        state = state.copyWith(
          transactions: transactions,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] ?? 'Gagal memuat transaksi dari server',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Koneksi gagal: $e',
      );
    }
  }

  void addToCart(ProductModel product) {
    final existing = state.cart.where((c) => c.product.id == product.id);
    if (existing.isNotEmpty) {
      incrementQuantity(product.id);
      return;
    }
    final newCart = [...state.cart, CartItem(product: product)];
    state = state.copyWith(cart: newCart);
  }

  void removeFromCart(int productId) {
    final newCart = state.cart.where((c) => c.product.id != productId).toList();
    state = state.copyWith(cart: newCart);
  }

  void incrementQuantity(int productId) {
    final newCart = state.cart.map((c) {
      if (c.product.id == productId && c.quantity < c.product.stok) {
        return CartItem(product: c.product, quantity: c.quantity + 1);
      }
      return c;
    }).toList();
    state = state.copyWith(cart: newCart);
  }

  void decrementQuantity(int productId) {
    final newCart = state.cart.map((c) {
      if (c.product.id == productId && c.quantity > 1) {
        return CartItem(product: c.product, quantity: c.quantity - 1);
      }
      return c;
    }).toList().where((c) => c.quantity > 0).toList();
    state = state.copyWith(cart: newCart);
  }

  void clearCart() {
    state = state.copyWith(cart: []);
  }

  Future<TransactionModel?> generateInvoice(int userId, String userName) async {
    if (state.cart.isEmpty) return null;

    state = state.copyWith(isLoading: true, error: null);

    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(seconds: 1));

      final kode = 'TRX-${DateTime.now().millisecondsSinceEpoch % 10000}';
      final items = state.cart.map((c) => TransactionItemModel(
        id: 0,
        transactionId: 0,
        productId: c.product.id,
        productNama: c.product.nama,
        jumlah: c.quantity,
        hargaSatuan: c.product.hargaJual,
        subtotal: c.subtotal,
      )).toList();

      final newTransaction = TransactionModel(
        id: state.transactions.length + 1,
        kodeTransaksi: kode,
        userId: userId,
        userName: 'Sales: $userName',
        tipe: 'penjualan',
        status: 'lunas',
        totalHarga: state.cartTotal,
        tanggal: DateTime.now(),
        items: items,
      );

      final updatedTransactions = [newTransaction, ...state.transactions];
      state = state.copyWith(
        transactions: updatedTransactions,
        cart: [],
        isLoading: false,
        lastTransaction: newTransaction,
      );

      return newTransaction;
    }

    try {
      // Map cart items to API transaction items
      final List<Map<String, dynamic>> itemsPayload = state.cart.map((c) => {
        'product_id': c.product.id,
        'jumlah': c.quantity,
        'harga_satuan': c.product.hargaJual,
        'subtotal': c.subtotal,
      }).toList();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createTransaction}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'total_harga': state.cartTotal,
          'tipe': 'penjualan',
          'status': 'lunas',
          'items': itemsPayload,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final newTransaction = TransactionModel.fromJson(data['transaction']);
        final updatedTransactions = [newTransaction, ...state.transactions];
        
        state = state.copyWith(
          transactions: updatedTransactions,
          cart: [],
          isLoading: false,
          lastTransaction: newTransaction,
        );

        // Crucial: refresh product list in UI since product stocks got reduced in database!
        await _productNotifier.loadProducts();

        return newTransaction;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] ?? 'Gagal membuat transaksi di server',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Koneksi gagal: $e',
      );
      return null;
    }
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final productNotifier = ref.read(productProvider.notifier);
  return TransactionNotifier(productNotifier);
});
