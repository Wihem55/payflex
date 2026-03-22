import 'package:flutter/material.dart';

class LoadingManager extends StatelessWidget {
  const LoadingManager(
      {super.key, required this.isLoading, required this.child});
  
  final bool isLoading; // Boolean to check if loading is in progress
  final Widget child; // The child widget to display

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child, // Display the child widget
        if (isLoading) ...[
          // If loading is true, display loading overlay
          Container(
            color: Colors.black.withOpacity(0.7), // Semi-transparent overlay
          ),
          const Center(
            child: CircularProgressIndicator(
              color: Colors.red, // Red loading spinner
            ),
          )
        ]
      ],
    );
  }
}
