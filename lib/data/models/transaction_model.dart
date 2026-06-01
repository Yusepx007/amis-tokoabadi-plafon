import 'transaction_item_model.dart';

class TransactionModel {
  final int id;
  final String kodeTransaksi;
  final int userId;
  final String userName;
  final String tipe; // 'penjualan', 'pembelian'
  final String status; // 'lunas', 'pending', 'batal'
  final double totalHarga;
  final DateTime tanggal;
  final List<TransactionItemModel> items;

  TransactionModel({
    required this.id,
    required this.kodeTransaksi,
    required this.userId,
    required this.userName,
    required this.tipe,
    required this.status,
    required this.totalHarga,
    required this.tanggal,
    this.items = const [],
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      kodeTransaksi: json['kode_transaksi'] ?? '',
      userId: json['user_id'] ?? 0,
      userName: json['user']?['nama'] ?? json['user_name'] ?? '',
      tipe: json['tipe'] ?? 'penjualan',
      status: json['status'] ?? 'pending',
      totalHarga: double.tryParse(json['total_harga'].toString()) ?? 0,
      tanggal: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal']) ?? DateTime.now()
          : DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => TransactionItemModel.fromJson(e))
          .toList(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'lunas':
        return 'Lunas';
      case 'pending':
        return 'Pending';
      case 'batal':
        return 'Batal';
      default:
        return status;
    }
  }

  // Mock data sesuai mockup
  static List<TransactionModel> get mockTransactions => [
    TransactionModel(
      id: 1,
      kodeTransaksi: 'TRX-240',
      userId: 3,
      userName: 'Sales: Andi Wijaya',
      tipe: 'penjualan',
      status: 'lunas',
      totalHarga: 1190000,
      tanggal: DateTime.now().subtract(const Duration(hours: 2)),
      items: [
        TransactionItemModel(id: 1, transactionId: 1, productId: 1,
          productNama: 'PVC Kayu-01', jumlah: 8, hargaSatuan: 85000, subtotal: 680000),
        TransactionItemModel(id: 2, transactionId: 1, productId: 4,
          productNama: 'Plafon Gypsum 60×60', jumlah: 15, hargaSatuan: 45000, subtotal: 510000),
      ],
    ),
    TransactionModel(
      id: 2,
      kodeTransaksi: 'TRX-239',
      userId: 2,
      userName: 'Admin: Siti',
      tipe: 'penjualan',
      status: 'lunas',
      totalHarga: 510000,
      tanggal: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TransactionModel(
      id: 3,
      kodeTransaksi: 'TRX-238',
      userId: 3,
      userName: 'Sales: Budi',
      tipe: 'penjualan',
      status: 'lunas',
      totalHarga: 990000,
      tanggal: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    TransactionModel(
      id: 4,
      kodeTransaksi: 'TRX-237',
      userId: 2,
      userName: 'Admin: Siti',
      tipe: 'penjualan',
      status: 'pending',
      totalHarga: 340000,
      tanggal: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    TransactionModel(
      id: 5,
      kodeTransaksi: 'TRX-236',
      userId: 3,
      userName: 'Sales: Dede',
      tipe: 'penjualan',
      status: 'lunas',
      totalHarga: 2750000,
      tanggal: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
}
