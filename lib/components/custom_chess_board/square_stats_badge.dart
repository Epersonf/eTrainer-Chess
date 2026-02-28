import 'package:flutter/material.dart';

class SquareStatsBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color iconColor;

  const SquareStatsBadge({
    super.key,
    required this.icon,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 10),
          const SizedBox(width: 2),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
