import 'dart:async';
import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controladorAnimacion;
  late Animation<double> _animacionOpacidad;

  @override
  void initState() {
    super.initState();
    _controladorAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animacionOpacidad = CurvedAnimation(
      parent: _controladorAnimacion,
      curve: Curves.easeIn,
    );

    _controladorAnimacion.forward();

    // Tiempo de bienvenida de 2 segundos antes de ingresar a la app
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controladorAnimacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.portadaLibreta,
      body: Center(
        child: FadeTransition(
          opacity: _animacionOpacidad,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logotipo estilizado de libreta
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.hojaLibreta,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 15,
                      offset: const Offset(4, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 14,
                      top: 10,
                      bottom: 10,
                      child: Container(
                        width: 2,
                        color: AppColors.lineaMargenHoja,
                      ),
                    ),
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 50,
                      color: AppColors.botonOscuro,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mi Agenda',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textoOscuro,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Organiza tu día con energía',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.botonOscuro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}