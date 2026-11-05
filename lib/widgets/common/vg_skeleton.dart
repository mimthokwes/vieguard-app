import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../vg/vg_ui.dart';

/// Komponen dasar animasi skeleton shimmer/pulse
class VgSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  const VgSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  const VgSkeleton.circle({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        radius = size / 2,
        shape = BoxShape.circle;

  @override
  State<VgSkeleton> createState() => _VgSkeletonState();
}

class _VgSkeletonState extends State<VgSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle ? null : BorderRadius.circular(widget.radius),
            color: Color.lerp(
              const Color(0xFFEFE7DB),
              const Color(0xFFDED5C7),
              _opacity.value,
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton untuk Card Pesanan (Pembelian / Sewa)
class VgOrderCardSkeleton extends StatelessWidget {
  const VgOrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              VgSkeleton(width: 100, height: 14),
              Spacer(),
              VgSkeleton(width: 80, height: 22, radius: 12),
            ],
          ),
          const SizedBox(height: 10),
          const VgSkeleton(width: 160, height: 18),
          const SizedBox(height: 12),
          VgInset(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Expanded(child: VgSkeleton(height: 15)),
                    SizedBox(width: 12),
                    VgSkeleton(width: 55, height: 18, radius: 10),
                  ],
                ),
                SizedBox(height: 8),
                VgSkeleton(width: 140, height: 12),
                SizedBox(height: 10),
                VgSkeleton(height: 6, radius: 3),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VgSkeleton(width: 70, height: 11),
                  SizedBox(height: 6),
                  VgSkeleton(width: 110, height: 20),
                ],
              ),
              Spacer(),
              VgSkeleton(width: 85, height: 38, radius: 10),
              SizedBox(width: 8),
              VgSkeleton(width: 95, height: 38, radius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton untuk Card Penyewaan
class VgRentalCardSkeleton extends StatelessWidget {
  const VgRentalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              VgSkeleton(width: 110, height: 14),
              Spacer(),
              VgSkeleton(width: 85, height: 22, radius: 12),
            ],
          ),
          const SizedBox(height: 10),
          const VgSkeleton(width: 170, height: 18),
          const SizedBox(height: 12),
          Row(
            children: [
              const VgSkeleton(width: 54, height: 54, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    VgSkeleton(width: 140, height: 14),
                    SizedBox(height: 6),
                    VgSkeleton(width: 100, height: 12),
                    SizedBox(height: 6),
                    VgSkeleton(width: 180, height: 11),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              VgSkeleton(width: 80, height: 36, radius: 10),
              SizedBox(width: 8),
              VgSkeleton(width: 110, height: 36, radius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton untuk Card Notifikasi
class VgNotificationCardSkeleton extends StatelessWidget {
  const VgNotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VgSkeleton.circle(size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Expanded(child: VgSkeleton(height: 14)),
                    SizedBox(width: 16),
                    VgSkeleton(width: 45, height: 12),
                  ],
                ),
                SizedBox(height: 8),
                VgSkeleton(height: 12),
                SizedBox(height: 5),
                VgSkeleton(width: 160, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton untuk Card Katalog / Stok
class VgProductCardSkeleton extends StatelessWidget {
  const VgProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: VgSkeleton(width: double.infinity, radius: 0)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                VgSkeleton(width: 60, height: 10),
                SizedBox(height: 6),
                VgSkeleton(width: 110, height: 14),
                SizedBox(height: 8),
                Row(
                  children: [
                    VgSkeleton(width: 70, height: 14),
                    Spacer(),
                    VgSkeleton(width: 40, height: 14, radius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton untuk Tile Percakapan Chat
class VgChatTileSkeleton extends StatelessWidget {
  const VgChatTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VgSkeleton.circle(size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Expanded(child: VgSkeleton(height: 15)),
                    SizedBox(width: 12),
                    VgSkeleton(width: 40, height: 12),
                  ],
                ),
                SizedBox(height: 8),
                VgSkeleton(width: 180, height: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton untuk Ringkasan Statistik (Grid 2x2 Metric Cards)
class VgSummaryMetricsSkeleton extends StatelessWidget {
  const VgSummaryMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: List.generate(
        4,
        (_) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              VgSkeleton(width: 70, height: 11),
              SizedBox(height: 8),
              VgSkeleton(width: 100, height: 22),
              SizedBox(height: 6),
              VgSkeleton(width: 50, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// List wrapper untuk kumpulan skeleton kartu
class VgSkeletonList extends StatelessWidget {
  final int count;
  final Widget item;

  const VgSkeletonList({
    super.key,
    this.count = 3,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => item),
    );
  }
}
