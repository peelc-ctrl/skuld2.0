import 'package:flutter/material.dart';
import 'dart:math';

class MosaicBackground extends StatefulWidget {
  const MosaicBackground({super.key});

  @override
  _MosaicBackgroundState createState() => _MosaicBackgroundState();
}

class _MosaicBackgroundState extends State<MosaicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animationPosition;

  // List of image assets
  final List<String> images = [
    'assets/bg1.jpg',
    'assets/bg2.jpg',
    'assets/bg3.jpg',
    'assets/bg4.jpg',
    'assets/bg5.jpg',
    'assets/bg6.jpg',
    'assets/bg7.jpg',
    'assets/bg8.jpg',
    'assets/bg9.jpg',
    'assets/bg10.jpg',
    'assets/bg11.jpg',
    'assets/bg12.jpg',
    'assets/bg13.jpg',
    'assets/bg14.jpg',
    'assets/bg15.jpg',
    'assets/bg16.jpg',
    'assets/bg17.jpg',
    'assets/bg18.jpg',
    'assets/bg19.jpg',
    'assets/bg20.jpg',
    'assets/bg21.jpg'
    
  ];

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true); // Continuously repeat the animation

    // Animation for position (sliding effect)
    _animationPosition = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.5, 0.56)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shuffle the images list to randomize the order
    images.shuffle(Random());

    // Get screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate number of columns based on screen width
    int columns = (screenWidth / 160).floor(); // Reduce columns for bigger squares

    // Calculate the aspect ratio of the images
    double aspectRatio = 1.0; // Square aspect ratio, you can tweak this for different shapes

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns, // Fewer columns = larger squares
        crossAxisSpacing: 4.0,  // Spacing between columns
        mainAxisSpacing: 4.0,   // Spacing between rows
        childAspectRatio: aspectRatio, // Maintain square aspect ratio
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _animationPosition.value, // Apply sliding effect
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 97, 6, 104), width: 2), // Border to help visualize
                ),
                child: Image.asset(
                  images[index],
                  fit: BoxFit.cover, // Ensure the images cover the available space
                ),
              ),
            );
          },
        );
      },
    );
  }
}

