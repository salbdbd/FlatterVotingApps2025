import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingPage extends StatelessWidget {

  final bool? isResponseTrue;
  final bool? isLoading;
  ShimmerLoadingPage({super.key, this.isLoading,this.isResponseTrue});

  @override
  Widget build(BuildContext context) {

    if(!isResponseTrue!){
      Navigator.pop(context);
    }


    return
      Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildShimmerItem(),
            SizedBox(height: 16),
            _buildShimmerItem(),
            SizedBox(height: 16),
            _buildShimmerItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Placeholder
                Container(
                  width: double.infinity,
                  height: 15,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                // Subtitle Placeholder
                Container(
                  width: double.infinity,
                  height: 10,
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
