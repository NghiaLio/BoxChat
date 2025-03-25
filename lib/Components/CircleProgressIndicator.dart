import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final double height_width;
  final Color color;
  const Loading({super.key, required this.height_width, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height_width,
      width: height_width,
      child: CircularProgressIndicator(
        color:color ,
      ),
    );
  }
}
