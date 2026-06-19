import 'package:flutter/material.dart';

// Widget per i box informativi (Peso e Attività) centralizzato
class InfoCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onTap;

  const InfoCard({super.key, required this.child, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}