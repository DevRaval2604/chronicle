import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final sw = size.width;
    final sh = size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      child: ListView.builder(
        itemCount: 6,
        padding: EdgeInsets.symmetric(
          vertical: sh * 0.01,
          horizontal: sw * 0.03,
        ),
        itemBuilder: (_, _) => _ShimmerCard(sw: sw, sh: sh),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double sw, sh;

  const _ShimmerCard({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      padding: EdgeInsets.all(sw * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.02),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: sw * 0.002,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: sw * 0.3,
            height: sh * 0.13,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sw * 0.015),
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: sw * 0.15,
                  height: sh * 0.014,
                  color: Colors.white,
                ),
                SizedBox(height: sh * 0.008),
                Container(
                  width: double.infinity,
                  height: sh * 0.018,
                  color: Colors.white,
                ),
                SizedBox(height: sh * 0.006),
                Container(
                  width: sw * 0.35,
                  height: sh * 0.018,
                  color: Colors.white,
                ),
                SizedBox(height: sh * 0.012),
                Container(
                  width: sw * 0.25,
                  height: sh * 0.014,
                  color: Colors.white,
                ),
                SizedBox(height: sh * 0.006),
                Container(
                  width: sw * 0.2,
                  height: sh * 0.012,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}