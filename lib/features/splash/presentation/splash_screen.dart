import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/presentation/pages/home_screen.dart';
import '../../auth/presentation/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const int _dotCount = 5;
  static const Duration _duration = Duration(milliseconds: 1400);
  late final AnimationController _controller;
  int _activeDot = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addListener(_handleTick)
      ..repeat();
    Future.delayed(const Duration(seconds: 3), _goToHome);
  }

  void _handleTick() {
    final progress = _controller.value;
    final nextIndex = (progress * _dotCount).floor() % _dotCount;
    if (nextIndex != _activeDot) {
      setState(() {
        _activeDot = nextIndex;
      });
    }
  }

  void _goToHome() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    final dest = user != null ? const HomeScreen() : const LoginScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dest),
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LogoMark(size: 84),
                  const SizedBox(height: 28),
                  _DotPager(activeIndex: _activeDot, count: _dotCount),
                ],
              ),
            ),
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Column(
                
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'from',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                    
                  ),
                  SizedBox(height: 6),
                  _MetaSignature(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lightGray, width: 1.2),
      ),
      alignment: Alignment.center,
      child: const Text(
        'f',
        style: TextStyle(
          color: AppColors.facebookBlue,
          fontSize: 56,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DotPager extends StatelessWidget {
  const _DotPager({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        final baseColor = Colors.grey.shade400;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 12 : 10,
          height: isActive ? 12 : 10,
          decoration: BoxDecoration(
            color: isActive ? AppColors.facebookBlue : baseColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _MetaSignature extends StatelessWidget {
  const _MetaSignature();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: -math.pi / 16,
          child: const Icon(
            Icons.all_inclusive,
            
            color: AppColors.facebookBlue,
            size: 22,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Meta',
          style: TextStyle(
            color: AppColors.facebookBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
