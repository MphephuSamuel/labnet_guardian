import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String initial;
  final double radius;
  final Color backgroundColor;

  const ProfileAvatar({
    super.key,
    required this.initial,
    this.radius = 40,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor.withValues(alpha: 0.2),
      radius: radius,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
