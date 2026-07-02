import 'package:flutter/material.dart';

class StylizedWeatherHouse extends StatelessWidget {
  final double width;
  final double height;

  const StylizedWeatherHouse({
    super.key,
    this.width = 280,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Chimney
          Positioned(
            left: width * 0.28,
            bottom: height * 0.45,
            child: Container(
              width: width * 0.12,
              height: height * 0.35,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E4994), Color(0xFF382963)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Chimney cap
                  Positioned(
                    top: 0,
                    left: -2,
                    right: -2,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C1F50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. House Main Body
          Positioned(
            bottom: height * 0.05,
            child: Container(
              width: width * 0.65,
              height: height * 0.55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3C306D), Color(0xFF1E1744)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F0B26).withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Horizontal Siding Panels
                    for (int i = 1; i <= 6; i++)
                      Positioned(
                        top: (height * 0.55 / 7) * i,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1,
                          color: const Color(0xFF5A4B9B).withOpacity(0.3),
                        ),
                      ),

                    // Left Arched Window
                    Positioned(
                      left: width * 0.12,
                      top: height * 0.15,
                      child: _buildArchedWindow(),
                    ),

                    // Right Arched Window
                    Positioned(
                      left: width * 0.28,
                      top: height * 0.15,
                      child: _buildArchedWindow(),
                    ),

                    // Door (Right side window / round portal style in image)
                    Positioned(
                      right: width * 0.08,
                      top: height * 0.15,
                      child: _buildDoorPortal(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Roof
          Positioned(
            bottom: height * 0.55,
            child: CustomPaint(
              size: Size(width * 0.72, height * 0.40),
              painter: RoofPainter(),
            ),
          ),

          // 4. Roof Edge Border & Shadow Overlay
          Positioned(
            bottom: height * 0.53,
            child: IgnorePointer(
              child: CustomPaint(
                size: Size(width * 0.74, 8),
                painter: RoofTrimPainter(),
              ),
            ),
          ),

          // 5. Attic Window (Round Window on Roof)
          Positioned(
            bottom: height * 0.62,
            child: Container(
              width: width * 0.16,
              height: width * 0.16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E2452),
                border: Border.all(color: const Color(0xFFE4A4CD), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFEB3B).withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    // Glow
                    Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFFFF59D), // Light yellow
                            Color(0xFFFFB74D), // Soft amber
                            Color(0xFF312152), // Inner dark frame shadow
                          ],
                          stops: [0.2, 0.7, 1.0],
                        ),
                      ),
                    ),
                    // Window Cross Pane
                    Center(
                      child: Container(
                        width: 2,
                        height: double.infinity,
                        color: const Color(0xFF533F7D),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 2,
                        width: double.infinity,
                        color: const Color(0xFF533F7D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. Floating soft light particles (3D spheres)
          Positioned(
            left: width * 0.08,
            top: height * 0.40,
            child: _buildFloatingParticle(10, const Color(0xFFE4A4CD)),
          ),
          Positioned(
            right: width * 0.06,
            top: height * 0.35,
            child: _buildFloatingParticle(14, const Color(0xFFB39DDB)),
          ),
          Positioned(
            left: width * 0.2,
            bottom: height * 0.1,
            child: _buildFloatingParticle(8, const Color(0xFF80DEEA)),
          ),
          Positioned(
            right: width * 0.15,
            bottom: height * 0.02,
            child: _buildFloatingParticle(12, const Color(0xFFE4A4CD)),
          ),
        ],
      ),
    );
  }

  Widget _buildArchedWindow() {
    return Container(
      width: width * 0.11,
      height: height * 0.28,
      decoration: const BoxDecoration(
        color: Color(0xFF2E2452),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Warm Yellow Light Glow
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 0.8,
                colors: [
                  Color(0xFFFFF59D), // bright yellow
                  Color(0xFFFFB74D), // warm orange
                  Color(0xFF1E1744), // dark edge
                ],
                stops: [0.1, 0.6, 1.0],
              ),
            ),
          ),
          // Window Frames
          Center(
            child: Container(
              width: 1.5,
              height: double.infinity,
              color: const Color(0xFF4C3B75),
            ),
          ),
          Positioned(
            top: height * 0.10,
            left: 0,
            right: 0,
            child: Container(
              height: 1.5,
              color: const Color(0xFF4C3B75),
            ),
          ),
          // Window border frame
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF6E56A3), width: 1.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          // Planter/Box at bottom
          Positioned(
            bottom: 0,
            left: -2,
            right: -2,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF6E52A3),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFFE4A4CD).withOpacity(0.6), width: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoorPortal() {
    // Representing the round window/door on the right side of the illustration
    return Container(
      width: width * 0.12,
      height: width * 0.12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2E2452),
        border: Border.all(color: const Color(0xFF6E56A3), width: 2),
      ),
      child: ClipOval(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFFF59D),
                    Color(0xFFFFB74D),
                    Color(0xFF2C1F50),
                  ],
                  stops: [0.2, 0.7, 1.0],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 1.5,
                height: double.infinity,
                color: const Color(0xFF4C3B75),
              ),
            ),
            Center(
              child: Container(
                height: 1.5,
                width: double.infinity,
                color: const Color(0xFF4C3B75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white,
            color.withOpacity(0.8),
            color.withOpacity(0.0),
          ],
          stops: const [0.1, 0.6, 1.0],
        ),
      ),
    );
  }
}

// Custom Painter to draw a triangular roof with linear/gradient shading
class RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    // Triangular roof path
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE4A4CD), // Soft pinkish lavender top
          Color(0xFF8C64B9), // Soft violet middle
          Color(0xFF4E377E), // Dark purple bottom
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Add roof shading lines (shingles texture)
    final Paint linePaint = Paint()
      ..color = const Color(0xFFE4A4CD).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (double i = 0.2; i < 1.0; i += 0.2) {
      final double y = size.height * i;
      final double xOffset = (size.width / 2) * (1 - i);
      canvas.drawLine(
        Offset(size.width / 2 - xOffset, y),
        Offset(size.width / 2 + xOffset, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter to draw a rounded thick trim/base under the roof
class RoofTrimPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFC78EB3)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
