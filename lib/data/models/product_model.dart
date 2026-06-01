enum StockStatus { aman, menipis, habis }

class ProductModel {
  final int id;
  final String kodeMotif;
  final String nama;
  final int categoryId;
  final String categoryNama;
  final String ukuran;
  final String satuan; // 'lembar', 'meter_lari'
  final double hargaBeli;
  final double hargaJual;
  final int stok;
  final int stokMinimum;
  final String? foto;

  ProductModel({
    required this.id,
    required this.kodeMotif,
    required this.nama,
    required this.categoryId,
    required this.categoryNama,
    required this.ukuran,
    required this.satuan,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    this.stokMinimum = 10,
    this.foto,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      kodeMotif: json['kode_motif'] ?? '',
      nama: json['nama'] ?? '',
      categoryId: json['category_id'] ?? 0,
      categoryNama: json['category']?['nama'] ?? json['category_nama'] ?? '',
      ukuran: json['ukuran'] ?? '',
      satuan: json['satuan'] ?? 'lembar',
      hargaBeli: double.tryParse(json['harga_beli'].toString()) ?? 0,
      hargaJual: double.tryParse(json['harga_jual'].toString()) ?? 0,
      stok: json['stok'] ?? 0,
      stokMinimum: json['stok_minimum'] ?? 10,
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_motif': kodeMotif,
      'nama': nama,
      'category_id': categoryId,
      'ukuran': ukuran,
      'satuan': satuan,
      'harga_beli': hargaBeli,
      'harga_jual': hargaJual,
      'stok': stok,
      'stok_minimum': stokMinimum,
      'foto': foto,
    };
  }

  StockStatus get stockStatus {
    if (stok <= 0) return StockStatus.habis;
    if (stok <= stokMinimum) return StockStatus.menipis;
    return StockStatus.aman;
  }

  String get stockStatusLabel {
    switch (stockStatus) {
      case StockStatus.aman:
        return 'Aman';
      case StockStatus.menipis:
        return 'Menipis';
      case StockStatus.habis:
        return 'Habis';
    }
  }

  String get satuanShort {
    return satuan == 'lembar' ? 'lbr' : 'mtr';
  }

  String get displayStok => 'Stok: $stok $satuanShort';

  // Mock data sesuai foto mockup
  static List<ProductModel> get mockProducts => [
    ProductModel(
      id: 1,
      kodeMotif: 'KAY-01',
      nama: 'PVC Motif Kayu-01',
      categoryId: 1,
      categoryNama: 'PVC',
      ukuran: '20×40 cm',
      satuan: 'lembar',
      hargaBeli: 65000,
      hargaJual: 85000,
      stok: 48,
      stokMinimum: 10,
    ),
    ProductModel(
      id: 2,
      kodeMotif: 'MAR-03',
      nama: 'Wallpanel Marmer-03',
      categoryId: 3,
      categoryNama: 'Wallpanel',
      ukuran: '30×60 cm',
      satuan: 'lembar',
      hargaBeli: 100000,
      hargaJual: 125000,
      stok: 5,
      stokMinimum: 10,
    ),
    ProductModel(
      id: 3,
      kodeMotif: 'BAT-02',
      nama: 'PVC Motif Batu-02',
      categoryId: 1,
      categoryNama: 'PVC',
      ukuran: '20×40 cm',
      satuan: 'lembar',
      hargaBeli: 55000,
      hargaJual: 78000,
      stok: 0,
      stokMinimum: 10,
    ),
    ProductModel(
      id: 4,
      kodeMotif: 'GYP-60',
      nama: 'Plafon Gypsum 60×60',
      categoryId: 2,
      categoryNama: 'Plafon',
      ukuran: '60×60 cm',
      satuan: 'lembar',
      hargaBeli: 30000,
      hargaJual: 45000,
      stok: 120,
      stokMinimum: 20,
    ),
    ProductModel(
      id: 5,
      kodeMotif: 'KAY-02',
      nama: 'PVC Motif Kayu-02',
      categoryId: 1,
      categoryNama: 'PVC',
      ukuran: '20×40 cm',
      satuan: 'lembar',
      hargaBeli: 68000,
      hargaJual: 90000,
      stok: 35,
      stokMinimum: 10,
    ),
    ProductModel(
      id: 6,
      kodeMotif: 'PLF-W01',
      nama: 'Plafon PVC Putih',
      categoryId: 2,
      categoryNama: 'Plafon',
      ukuran: '20×40 cm',
      satuan: 'meter_lari',
      hargaBeli: 45000,
      hargaJual: 65000,
      stok: 8,
      stokMinimum: 15,
    ),
    ProductModel(
      id: 7,
      kodeMotif: 'WP-MRB-01',
      nama: 'Wallpanel Marmer Hitam',
      categoryId: 3,
      categoryNama: 'Wallpanel',
      ukuran: '60×120 cm',
      satuan: 'lembar',
      hargaBeli: 120000,
      hargaJual: 165000,
      stok: 22,
      stokMinimum: 10,
    ),
    ProductModel(
      id: 8,
      kodeMotif: 'KAY-03',
      nama: 'PVC Motif Kayu-03',
      categoryId: 1,
      categoryNama: 'PVC',
      ukuran: '20×40 cm',
      satuan: 'lembar',
      hargaBeli: 70000,
      hargaJual: 95000,
      stok: 15,
      stokMinimum: 10,
    ),
  ];
}
