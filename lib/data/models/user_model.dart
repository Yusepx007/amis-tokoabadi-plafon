class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role; // 'pemilik', 'admin', 'sales'
  final String? token;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.token,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'sales',
      token: json['token'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'token': token,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get displayRole {
    switch (role) {
      case 'pemilik':
        return 'Pemilik Toko';
      case 'admin':
        return 'Admin Gudang';
      case 'sales':
        return 'Sales Lapangan';
      default:
        return role;
    }
  }

  bool get isPemilik => role == 'pemilik';
  bool get isAdmin => role == 'admin';
  bool get isSales => role == 'sales';
  bool get canManageStock => role == 'pemilik' || role == 'admin';
}
