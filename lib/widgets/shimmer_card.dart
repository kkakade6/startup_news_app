import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(height: 16, width: double.infinity, color: Colors.white),
                const SizedBox(height: 12),
                Container(height: 16, width: double.infinity, color: Colors.white),
                const SizedBox(height: 12),
                Container(height: 120, width: double.infinity, color: Colors.white),
                const Spacer(),
                Row(
                  children: [
                    Container(height: 14, width: 120, color: Colors.white),
                    const Spacer(),
                    Container(height: 36, width: 100, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
