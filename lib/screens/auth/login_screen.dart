import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../admin/admin_dashboard.dart';
import '../pelapor/widgets/pelapor_dashboard.dart';
import '../teknisi/teknisi_dashboard.dart';

class _C {
  static const navyDark = AppPalette.navyDark;
  static const navyLight = AppPalette.navyLight;
  static const pageBg = AppPalette.pageBg;
  static const surface = AppPalette.surface;
  static const inputBg = AppPalette.inputBg;
  static const textPri = AppPalette.textPri;
  static const textSec = AppPalette.textSec;
  static const textHint = AppPalette.textHint;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'User (Pelapor)';
  bool _obscurePassword = true;
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _roles = {
    'User (Pelapor)': {
      'code': 'user',
      'icon': Icons.person_outline_rounded,
      'color': const Color(0xFF2751A3),
      'bgColor': const Color(0xFFEFF3FB),
      'checkColor': const Color(0xFF2751A3),
      'description': 'Buat & lacak tiket support Anda',
      'email': 'budi@example.com',
    },
    'Technician (Teknisi)': {
      'code': 'technician',
      'icon': Icons.build_outlined,
      'color': const Color(0xFFF59E0B),
      'bgColor': const Color(0xFFFFF8E7),
      'checkColor': const Color(0xFFF59E0B),
      'description': 'Terima & kerjakan tiket support',
      'email': 'andi@porthelp.com',
    },
    'Admin': {
      'code': 'admin',
      'icon': Icons.admin_panel_settings_outlined,
      'color': const Color(0xFF7C3AED),
      'bgColor': const Color(0xFFF3F0FF),
      'checkColor': const Color(0xFF7C3AED),
      'description': 'Kelola sistem & assign teknisi',
      'email': 'admin@porthelp.com',
    },
  };

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    return email.isNotEmpty && password.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final selectedRoleData = _roles[_selectedRole];
    final expectedEmail = selectedRoleData?['email']?.toString().trim();

    if (email.isEmpty) {
      _showSnackBar('Email tidak boleh kosong');
      return;
    }
    if (password.isEmpty) {
      _showSnackBar('Password tidak boleh kosong');
      return;
    }
    if (password.length < 8) {
      _showSnackBar('Password minimal 8 karakter');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showSnackBar('Email tidak valid');
      return;
    }

    if (expectedEmail == null || expectedEmail.isEmpty) {
      _showSnackBar('Role yang dipilih tidak memiliki email referensi');
      return;
    }

    if (email.toLowerCase() != expectedEmail.toLowerCase()) {
      _showSnackBar(
        'Email tidak sesuai dengan role $_selectedRole. Gunakan email: $expectedEmail',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final user = await AuthService.login(email, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        if (user.role == UserRole.admin) {
          _showSnackBar('✅ Login berhasil sebagai Admin!', isError: false);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            // FIX: tambahkan parameter user yang dibutuhkan
            MaterialPageRoute(builder: (_) => AdminDashboard(user: user)),
          );
        } else if (user.role == UserRole.teknisi) {
          _showSnackBar('✅ Login berhasil sebagai Teknisi!', isError: false);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => TeknisiDashboard(user: user)),
          );
        } else if (user.role == UserRole.pelapor) {
          _showSnackBar('✅ Login berhasil sebagai Pelapor!', isError: false);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PelaporDashboard(user: user)),
          );
        } else {
          _showSnackBar('Role tidak dikenali');
        }
      } else {
        _showSnackBar('Email atau password salah');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _autoFillEmail() {
    final selectedRoleData = _roles[_selectedRole];
    if (selectedRoleData != null && selectedRoleData['email'] != null) {
      _emailController.text = selectedRoleData['email'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A6E).withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLabeledField(
                      label: 'Email',
                      child: _buildInputField(
                        controller: _emailController,
                        hint: 'Alamat Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildLabeledField(
                      label: 'Password',
                      child: _buildInputField(
                        controller: _passwordController,
                        hint: 'Kata Sandi',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: _C.textSec,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'PILIH ROLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: _C.textSec,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._roles.keys.map((role) => _buildRoleCard(role)),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: _C.textSec,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Pilih role dan gunakan email yang sesuai.',
                            style: TextStyle(fontSize: 12, color: _C.textSec),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.textPri,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2347), Color(0xFF1E3F80), Color(0xFF2B5499)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2347).withValues(alpha: 0.45),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -50,
            bottom: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 1,
                        ),
                      ),
                    ),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                          width: 1,
                        ),
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.13),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'IT SUPPORT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'PortHelp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'IT Support & Ticketing System',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.65),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        color: _C.textPri,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _C.textHint,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: _C.inputBg,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(prefixIcon, size: 20, color: _C.textSec),
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.navyLight, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role) {
    final isSelected = _selectedRole == role;
    final roleData = _roles[role]!;
    final roleColor = roleData['color'] as Color;
    final roleBg = roleData['bgColor'] as Color;
    final roleIcon = roleData['icon'] as IconData;
    final roleDesc = roleData['description'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRole = role);
          _autoFillEmail();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? roleColor.withValues(alpha: 0.06) : _C.inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? roleColor : Colors.transparent,
              width: 1.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? roleBg : const Color(0xFFE8ECF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  roleIcon,
                  size: 22,
                  color: isSelected ? roleColor : _C.textSec,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? roleColor : _C.textPri,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleDesc,
                      style: const TextStyle(fontSize: 12, color: _C.textSec),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Container(
                        key: const ValueKey('check'),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: roleColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey('empty'),
                        width: 26,
                        height: 26,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: (_isLoading || !_isFormValid)
              ? null
              : const LinearGradient(
                  colors: [_C.navyDark, _C.navyLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: (_isLoading || !_isFormValid) ? const Color(0xFFCDD4E4) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: (_isLoading || !_isFormValid)
              ? []
              : [
                  BoxShadow(
                    color: _C.navyDark.withValues(alpha: 0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: (_isLoading || !_isFormValid) ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white60,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}