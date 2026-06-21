import '../models/user_model.dart';

class AuthService {
  // Simulasi user database
  static final List<User> _users = [
    User(
      id: '1',
      name: 'Budi Santoso',
      email: 'budi@example.com',
      phone: '0812-3456-7890',
      role: UserRole.pelapor,
      company: 'PT. Maju Jaya',
    ),
    User(
      id: '2',
      name: 'Andi Wijaya',
      email: 'andi@porthelp.com',
      phone: '0812-3456-7890',
      role: UserRole.teknisi,
      specialization: 'Technical Support',
    ),
    User(
      id: '3',
      name: 'Admin Sistem',
      email: 'admin@porthelp.com',
      phone: '0812-3456-7890',
      role: UserRole.admin,
      company: 'PortHelp',
    ),
  ];

  // Simulasi login
  static Future<User?> login(String email, String password) async {
    // Simulasi delay network
    await Future.delayed(const Duration(seconds: 1));
    
    // Cari user berdasarkan email (password diabaikan untuk simulasi)
    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('Email tidak ditemukan'),
    );
    
    return user;
  }

  // Simulasi register (opsional)
  static Future<User?> register({
    required String name,
    required String email,
    required String phone,
    required UserRole role,
    String? company,
    String? specialization,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final newUser = User(
      id: '${_users.length + 1}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      company: company,
      specialization: specialization,
    );
    
    return newUser;
  }

  // Logout
  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Clear session/data jika perlu
  }
}