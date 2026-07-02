import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback onMapPressed;
  final VoidCallback onAddPressed;
  final VoidCallback onListPressed;

  const CustomBottomNavBar({
    super.key,
    required this.onMapPressed,
    required this.onAddPressed,
    required this.onListPressed,
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 88.0;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: barHeight + 20, // Add spacing for the floating center button
      width: screenWidth,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Curved Glassmorphic Background Shape
          CustomPaint(
            size: Size(screenWidth, barHeight),
            painter: BottomNavBarPainter(),
          ),

          // 2. Navigation Items (Left & Right)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: barHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Action: Locator/Map Pin
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.map_pin_ellipse,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: onMapPressed,
                  ),

                  // Right Action: List Menu
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.list_bullet,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: onListPressed,
                  ),
                ],
              ),
            ),
          ),

          // 3. Center Floating Action Button (placed on top of the dome)
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onAddPressed,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF612FAB).withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFE0E0FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: Color(0xFF382A6A),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Dome height factor (vertical offset from top edge)
    const double domeTop = 10.0;
    const double flatTop = 32.0;

    // Draw the curved path
    path.moveTo(0, flatTop);
    path.lineTo(w * 0.32, flatTop);

    // Smooth Bezier Curve UP to form a dome in the center
    path.cubicTo(
      w * 0.40, flatTop,          // First control point
      w * 0.42, domeTop,          // Second control point
      w * 0.50, domeTop,          // Peak of the dome
    );
    path.cubicTo(
      w * 0.58, domeTop,          // Third control point
      w * 0.60, flatTop,          // Fourth control point
      w * 0.68, flatTop,          // End point
    );

    path.lineTo(w, flatTop);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    // Paint for background: semi-transparent dark gradient (glassmorphic)
    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xEE2A2550), // Semi-transparent deep indigo
          Color(0xFA15132A), // More solid dark space color
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    // Draw shadow under the bar
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(path, fillPaint);

    // Paint for the thin glowing border at the top of the curve
    final Paint borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x33FFFFFF), // Transparent white on sides
          Color(0x808C64B9), // Soft glowing purple in the middle
          Color(0x33FFFFFF),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Create a path just for the top border
    final Path borderPath = Path();
    borderPath.moveTo(0, flatTop);
    borderPath.lineTo(w * 0.32, flatTop);
    borderPath.cubicTo(
      w * 0.40, flatTop,
      w * 0.42, domeTop,
      w * 0.50, domeTop,
    );
    borderPath.cubicTo(
      w * 0.58, domeTop,
      w * 0.60, flatTop,
      w * 0.68, flatTop,
    );
    borderPath.lineTo(w, flatTop);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
