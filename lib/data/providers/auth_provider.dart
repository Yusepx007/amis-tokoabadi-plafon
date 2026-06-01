import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

// Auth State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // Fallback Mock Users (only used if ApiConstants.useMock is enabled)
  static final List<UserModel> _mockUsers = [
    UserModel(id: 1, nama: 'Bapak Hendra', email: 'pemilik@abadiplaon.id', role: 'pemilik', token: 'mock_token_pemilik'),
    UserModel(id: 2, nama: 'Siti Rahayu', email: 'admin@abadiplaon.id', role: 'admin', token: 'mock_token_admin'),
    UserModel(id: 3, nama: 'Andi Wijaya', email: 'sales@abadiplaon.id', role: 'sales', token: 'mock_token_sales'),
  ];

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      // Mock authentication
      final user = _mockUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => UserModel(id: 0, nama: '', email: '', role: ''),
      );

      if (user.id == 0 || password.length < 4) {
        state = state.copyWith(isLoading: false, error: 'Email atau password salah');
        return false;
      }

      await _saveSession(user);
      state = AuthState(user: user, isLoading: false);
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = UserModel.fromJson(data['user']);
        await _saveSession(user);
        state = AuthState(user: user, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: data['message'] ?? 'Email atau password salah',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Tidak dapat terhubung ke server backend: $e',
      );
      return false;
    }
  }

  Future<bool> loginAsSales() async {
    if (ApiConstants.useMock) {
      state = state.copyWith(isLoading: true, error: null);
      await Future.delayed(const Duration(milliseconds: 500));

      final salesUser = _mockUsers.firstWhere((u) => u.role == 'sales');
      await _saveSession(salesUser);
      state = AuthState(user: salesUser, isLoading: false);
      return true;
    }

    // Call real login for seeded sales credentials
    return login('sales@abadiplaon.id', 'sales123');
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token ?? '');
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_nama', user.nama);
    await prefs.setInt('user_id', user.id);
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('user_role');
    final nama = prefs.getString('user_nama');
    final id = prefs.getInt('user_id');

    if (token != null && role != null && nama != null && id != null) {
      state = AuthState(
        user: UserModel(id: id, nama: nama, email: '', role: role, token: token),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
