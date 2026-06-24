import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('session_username');

    if (!mounted) return;
    if (username != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono central
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC9933A).withOpacity(0.6),
                      width: 1.5,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC9933A).withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.local_bar,
                    color: Color(0xFFC9933A),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'COCTELERÍA',
                  style: TextStyle(
                    color: Color(0xFFC9933A),
                    fontSize: 28,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'recetas del mundo',
                  style: TextStyle(
                    color: Color(0xFF4A4A5A),
                    fontSize: 12,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 40,
                  child: LinearProgressIndicator(
                    backgroundColor: const Color(0xFF1A1A24),
                    color: const Color(0xFFC9933A),
                    minHeight: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}