class CategoryModel {
  final int id;
  final String nama;

  CategoryModel({required this.id, required this.nama});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nama': nama};

  // Mock data
  static List<CategoryModel> get mockCategories => [
    CategoryModel(id: 1, nama: 'PVC'),
    CategoryModel(id: 2, nama: 'Plafon'),
    CategoryModel(id: 3, nama: 'Wallpanel'),
  ];
}
