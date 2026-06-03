import 'package:flutter/material.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';

class InventoryCard extends StatelessWidget {
  final InventoryModel inventory;
  final VoidCallback onTap;
  final bool showFoundationId;

  const InventoryCard({
    super.key,
    required this.inventory,
    required this.onTap,
    this.showFoundationId = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio   = inventory.fulfillmentRatio;
    final urgent  = inventory.urgentLevel;
    final theme   = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    inventory.itemName,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _UrgentBadge(level: urgent),
              ],
            ),
            const SizedBox(height: 6),

            // ── Category ────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.label_outline, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(inventory.category.label, style: theme.textTheme.bodySmall),
                if (showFoundationId) ...[
                  const SizedBox(width: 8),
                  const Text('·', style: TextStyle(color: AppColors.textHint)),
                  const SizedBox(width: 8),
                  Icon(Icons.home_outlined, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      inventory.foundationId,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // ── Progress Bar ────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value:            ratio,
                minHeight:        8,
                backgroundColor:  AppColors.border,
                valueColor:       AlwaysStoppedAnimation<Color>(urgent.color),
              ),
            ),
            const SizedBox(height: 8),

            // ── Qty Info ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terpenuhi: ${inventory.currentQty} / ${inventory.targetQty} ${inventory.unit}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelLarge?.copyWith(color: urgent.color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgentBadge extends StatelessWidget {
  final UrgentLevel level;
  const _UrgentBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        level.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: level.color),
          const SizedBox(width: 4),
          Text(
            level.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: level.color,
            ),
          ),
        ],
      ),
    );
  }
}