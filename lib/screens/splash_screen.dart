import 'package:flutter/material.dart';
import 'dart:async';
import 'auth/login_screen.dart'; // ← import login screen yang sudah ada

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoScaleAnim;
  late Animation<double> _logoFadeAnim;
  late Animation<double> _textFadeAnim;
  late Animation<double> _textSlideAnim;
  late Animation<double> _loadingFadeAnim;

  String _loadingText = 'Initializing Secure Session';
  int _dotCount = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
    _startDotAnimation();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlideAnim = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadingFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeIn),
    );
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _loadingController.forward();

    // Setelah splash selesai → navigasi ke LoginScreen
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const LoginScreen(), // ← ke login
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
          _loadingText = 'Initializing Secure Session${'.' * _dotCount}';
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4FF), Color(0xFFE8EEFF), Color(0xFFF5F0FF)],
          ),
        ),
        child: Stack(
          children: [
            _buildBorderGlow(),
            Column(
              children: [
                const Spacer(flex: 3),
                _buildLogoSection(),
                const SizedBox(height: 48),
                _buildLoadingSection(),
                const Spacer(flex: 3),
                _buildFooter(),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorderGlow() {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF5C6BC0).withOpacity(0.3),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return FadeTransition(
      opacity: _logoFadeAnim,
      child: ScaleTransition(
        scale: _logoScaleAnim,
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A237E).withOpacity(0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.headset_mic_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _textSlideAnim.value),
                child: FadeTransition(opacity: _textFadeAnim, child: child),
              ),
              child: Column(
                children: [
                  const Text(
                    'IT Helpdesk Center',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'RELIABILITY & TRUST',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                      letterSpacing: 3.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return FadeTransition(
      opacity: _loadingFadeAnim,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => _AnimatedDot(index: index)),
          ),
          const SizedBox(height: 10),
          Text(
            _loadingText,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _loadingFadeAnim,
      child: Column(
        children: [
          Text(
            'Corporate Infrastructure Services',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            'v4.2.0 stable',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ==================== ANIMATED DOT ====================
class _AnimatedDot extends StatefulWidget {
  final int index;
  const _AnimatedDot({required this.index});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            Colors.grey.shade300,
            const Color(0xFF1A237E),
            _anim.value,
          ),
        ),
      ),
    );
  }
}
