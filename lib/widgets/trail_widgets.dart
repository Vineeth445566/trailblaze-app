import 'package:flutter/material.dart';

import '../models/trail.dart';

/// Gradient header placeholder with an icon, used in place of photos.
class TrailHeaderArt extends StatelessWidget {
  final Trail trail;
  final double height;

  const TrailHeaderArt({super.key, required this.trail, this.height = 140});

  @override
  Widget build(BuildContext context) {
    // Deterministic hue per trail for visual variety.
    final hue = (trail.id.hashCode % 60 + 90).toDouble();
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, 0.45, 0.32).toColor(),
            HSLColor.fromAHSL(1, hue + 25, 0.5, 0.18).toColor(),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: Icon(
              Icons.landscape,
              size: 64,
              color: Colors.white24,
            ),
          ),
          Positioned(
            left: 12,
            bottom: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trail.difficulty.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    trail.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Keep the header readable over any app bar content.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Difficulty badge color.
Color difficultyColor(BuildContext context, Difficulty d) {
  final scheme = Theme.of(context).colorScheme;
  switch (d) {
    case Difficulty.easy:
      return Colors.green;
    case Difficulty.moderate:
      return Colors.orange;
    case Difficulty.hard:
      return scheme.error;
  }
}

/// Compact stat tile used on detail screens.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11, color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
