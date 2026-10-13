import 'package:flutter/material.dart';

import 'section_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.subtitle,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: content,
    );
  }
}
