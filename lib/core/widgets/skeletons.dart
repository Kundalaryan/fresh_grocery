import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonProductItem extends StatelessWidget {
  const SkeletonProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Image Placeholder
          const SkeletonBox(width: 80, height: 80, radius: 16),
          const SizedBox(width: 16),

          // Text Details Placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Line
                const SkeletonBox(width: 150, height: 16, radius: 4),
                const SizedBox(height: 8),
                // Category Line
                const SkeletonBox(width: 100, height: 14, radius: 4),
                const SizedBox(height: 8),
                // Price Line
                const SkeletonBox(width: 60, height: 16, radius: 4),
              ],
            ),
          ),

          // Add Button Placeholder
          const SkeletonBox(width: 40, height: 40, radius: 12),
        ],
      ),
    );
  }
}

class SkeletonOrderItem extends StatelessWidget {
  const SkeletonOrderItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Icon Placeholder
          const SkeletonBox(width: 60, height: 60, radius: 12),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 100, height: 16, radius: 4),
                const SizedBox(height: 8),
                const SkeletonBox(width: 140, height: 14, radius: 4),
              ],
            ),
          ),

          // Price & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SkeletonBox(width: 60, height: 16, radius: 4),
              const SizedBox(height: 12),
              const SkeletonBox(width: 50, height: 14, radius: 4),
            ],
          )
        ],
      ),
    );
  }
}

// --- HELPER: The Grey Box with Shimmer Effect ---
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, // Darker Grey
      highlightColor: Colors.grey[100]!, // Lighter Grey (Moving part)
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      ),
    );
  }
}