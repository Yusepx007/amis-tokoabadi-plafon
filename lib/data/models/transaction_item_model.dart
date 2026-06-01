class TransactionItemModel {
  final int id;
  final int transactionId;
  final int productId;
  final String productNama;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;

  TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productNama,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] ?? 0,
      transactionId: json['transaction_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productNama: json['product']?['nama'] ?? json['product_nama'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      hargaSatuan: double.tryParse(json['harga_satuan'].toString()) ?? 0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'jumlah': jumlah,
    'harga_satuan': hargaSatuan,
    'subtotal': subtotal,
  };
}
