import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String initial;
  final bool isAssigned;
  final double size;
  final double fontSize;

  const UserAvatar({
    Key? key,
    required this.initial,
    this.isAssigned = false,
    this.size = 28,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isAssigned ? const Color(0xFFE3E6FF) : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial.isNotEmpty ? initial[0].toUpperCase() : '?',
          style: TextStyle(
            color: isAssigned ? const Color(0xFF5B67CA) : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
