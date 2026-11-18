import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../common/tap_scale.dart';

/// Item data model untuk [FloatingNotchNavBar].
class FloatingNotchItem {
  final IconData icon;
  final String label;
  final int badgeCount;

  const FloatingNotchItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });
}

/// Floating Notch Navigation Bar dengan efek bola melayang (Ball Hops on a Notch Path).
/// Lekukan berbentuk setengah lingkaran murni (true semi-circle) presisi dengan
/// bahu fillet transisi yang mulus tanpa sudut lancip, serta sinkronisasi pergerakan 100%.
class FloatingNotchNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNotchItem> items;
  final double barHeight;

  const FloatingNotchNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.barHeight = 68.0,
  });

  @override
  State<FloatingNotchNavBar> createState() => _FloatingNotchNavBarState();
}

class _FloatingNotchNavBarState extends State<FloatingNotchNavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  int _fromIndex = 0;
  int _toIndex = 0;
  double _lastKnownWidth = 0.0;

  static const double _ballSize = 40.0;
  static const double _elevationGap = 15.0; // Tinggi bola melayang proporsional (tidak terlalu tinggi)
  static const double _topBuffer = 18.0;    // Ruang atas pas untuk bola melayang

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex;
    _toIndex = widget.currentIndex;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant FloatingNotchNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _fromIndex = oldWidget.currentIndex;
      _toIndex = widget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getTabCenterX(int index, double totalWidth) {
    if (widget.items.isEmpty) return totalWidth / 2;
    const sidePadding = 20.0;
    final contentWidth = totalWidth - (sidePadding * 2);
    final tabWidth = contentWidth / widget.items.length;
    return sidePadding + (index * tabWidth) + (tabWidth / 2);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        _lastKnownWidth = totalWidth;

        final startX = _getTabCenterX(_fromIndex, totalWidth);
        final endX = _getTabCenterX(_toIndex, totalWidth);

        return RepaintBoundary(
          child: SizedBox(
            height: widget.barHeight + _topBuffer,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Background Notch Canvas (Hanya repaint canvas yang dianimasikan)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: widget.barHeight,
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, _) {
                        final progress = _animation.value;
                        final currentX = ui.lerpDouble(startX, endX, progress) ?? endX;
                        return CustomPaint(
                          painter: _SmoothNotchPainter(notchX: currentX),
                        );
                      },
                    ),
                  ),
                ),

                // 2. Tab Items Buttons Row (Static / Rebuild hanya saat state tab berubah, hemat CPU)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: widget.barHeight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: List.generate(widget.items.length, (i) {
                        final isCurrent = i == widget.currentIndex;
                        final item = widget.items[i];

                        return Expanded(
                          child: TapScale(
                            onTap: () => widget.onTap(i),
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.center,
                              child: isCurrent
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 22.0),
                                      child: Text(
                                        item.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    )
                                  : Badge(
                                      isLabelVisible: item.badgeCount > 0,
                                      label: Text(
                                        item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: AppColors.danger,
                                      child: Icon(
                                        item.icon,
                                        size: 23,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // 3. Bola Melayang (Ball Hops) - Terisolasi di layer animasi sendiri
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    final progress = _animation.value;
                    final currentX = ui.lerpDouble(startX, endX, progress) ?? endX;
                    final displayIndex = progress >= 0.48 ? _toIndex : _fromIndex;
                    final activeItem = widget.items[displayIndex];

                    return Positioned(
                      left: currentX - (_ballSize / 2),
                      top: _topBuffer - _elevationGap,
                      width: _ballSize,
                      height: _ballSize,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            border: Border.all(
                              color: AppColors.goldLight,
                              width: 1.6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7A4A20).withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Badge(
                              isLabelVisible: activeItem.badgeCount > 0,
                              label: Text(
                                activeItem.badgeCount > 99 ? '99+' : '${activeItem.badgeCount}',
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppColors.danger,
                              offset: const Offset(7, -7),
                              child: Icon(
                                activeItem.icon,
                                size: 20,
                                color: AppColors.goldLight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter untuk menggambar lekukan setengah lingkaran murni presisi
/// dengan transisi bahu fillet melengkung lembut (tanpa sudut lancip).
class _SmoothNotchPainter extends CustomPainter {
  final double notchX;

  const _SmoothNotchPainter({required this.notchX});

  @override
  void paint(Canvas canvas, Size size) {
    const cornerR = 16.0;       // Radius sudut luar rounded navbar
    const R = 25.0;             // Radius setengah lingkaran cekungan (diameter 50px)
    const r = 7.0;              // Radius fillet bahu atas (sangat mulus, tidak lancip)
    const kappa = 0.55228475;   // Konstanta kurva lingkaran presisi

    const kr = kappa * r;
    const kR = kappa * R;
    const depth = r + R;        // Kedalaman dasar cekungan = 32px

    final leftStart = notchX - R - r;
    final rightEnd = notchX + R + r;

    final path = Path();
    path.moveTo(cornerR, 0);
    path.lineTo(leftStart, 0);

    // 1. Fillet bahu kiri (horizontal ke vertikal)
    path.cubicTo(
      leftStart + kr, 0,
      notchX - R, r - kr,
      notchX - R, r,
    );

    // 2. Kuadran kiri setengah lingkaran (turun ke dasar)
    path.cubicTo(
      notchX - R, r + kR,
      notchX - kR, depth,
      notchX, depth,
    );

    // 3. Kuadran kanan setengah lingkaran (naik dari dasar)
    path.cubicTo(
      notchX + kR, depth,
      notchX + R, r + kR,
      notchX + R, r,
    );

    // 4. Fillet bahu kanan (vertikal kembali ke horizontal)
    path.cubicTo(
      notchX + R, r - kr,
      rightEnd - kr, 0,
      rightEnd, 0,
    );

    // Garis atas kanan & sudut luar kanan atas
    path.lineTo(size.width - cornerR, 0);
    path.arcToPoint(
      Offset(size.width, cornerR),
      radius: const Radius.circular(cornerR),
    );

    // Sisi kanan & sudut luar kanan bawah
    path.lineTo(size.width, size.height - cornerR);
    path.arcToPoint(
      Offset(size.width - cornerR, size.height),
      radius: const Radius.circular(cornerR),
    );

    // Sisi bawah & sudut luar kiri bawah
    path.lineTo(cornerR, size.height);
    path.arcToPoint(
      Offset(0, size.height - cornerR),
      radius: const Radius.circular(cornerR),
    );

    // Sisi kiri & sudut luar kiri atas
    path.lineTo(0, cornerR);
    path.arcToPoint(
      const Offset(cornerR, 0),
      radius: const Radius.circular(cornerR),
    );

    path.close();

    // Gambar Drop Shadow asli (dioptimasi ringan agar tidak membebani GPU saat first-frame)
    canvas.drawShadow(
      path,
      const Color(0xFF7A4A20).withValues(alpha: 0.16),
      8.0,
      false,
    );

    // Gambar Background Surface Putih Asli (AppColors.surface)
    final paintFill = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFill);

    // Gambar Garis Tepi Emas Asli (AppColors.goldLight)
    final paintStroke = Paint()
      ..color = AppColors.goldLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(covariant _SmoothNotchPainter oldDelegate) {
    return oldDelegate.notchX != notchX;
  }
}
