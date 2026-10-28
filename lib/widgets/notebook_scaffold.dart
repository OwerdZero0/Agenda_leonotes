// lib/widgets/notebook_scaffold.dart
import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

class NotebookScaffold extends StatelessWidget {
  final Widget contenido;
  final Widget? barraNavegacionInferior;

  const NotebookScaffold({
    super.key,
    required this.contenido,
    this.barraNavegacionInferior,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.portadaLibreta,
      body: SafeArea(
        child: Stack(
          children: [
            // Hoja blanca con esquinas redondeadas
            Positioned(
              top: 10,
              bottom: 12,
              left: 48,
              right: 18,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.hojaLibreta,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Línea vertical que simula el margen
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 20,
                        child: Container(
                          width: 2,
                          color: AppColors.lineaMargenHoja,
                        ),
                      ),
                      // Contenido interior
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 26,
                          right: 14,
                          top: 12,
                          bottom: 12,
                        ),
                        child: contenido,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Argollas en el margen izquierdo
            Positioned(
              top: 20,
              bottom: 20,
              left: 10,
              width: 55,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _NotebookRingsPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: barraNavegacionInferior,
    );
  }
}

class _NotebookRingsPainter extends CustomPainter {
  @override
  void paint(Canvas lienzo, Size tamano) {
    final pincelArgolla = Paint()
      ..color = AppColors.argollasLibreta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;

    const int totalArgollas = 10;
    final double separacion = tamano.height / (totalArgollas + 1);

    for (int indice = 1; indice <= totalArgollas; indice++) {
      final double posicionY = separacion * indice;
      final trazoCurva = Path();

      trazoCurva.moveTo(0, posicionY - 10);
      trazoCurva.cubicTo(
        tamano.width * 0.9, posicionY - 14,
        tamano.width * 0.9, posicionY + 14,
        tamano.width * 0.35, posicionY + 10,
      );

      lienzo.drawPath(trazoCurva, pincelArgolla);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter pintorAnterior) => false;
}