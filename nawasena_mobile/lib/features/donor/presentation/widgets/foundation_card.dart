import 'package:flutter/material.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';

class FoundationCard extends StatelessWidget {
  final FoundationModel foundation;
  final VoidCallback onTap;
  final bool compact;

  const FoundationCard({
    super.key,
    required this.foundation,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 200 : double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color:       AppColors.shadow,
              blurRadius:  8,
              offset:      const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar ──────────────────────────────────────────────
            Row(
              children: [
                _FoundationAvatar(name: foundation.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foundation.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (foundation.isVerified)
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded,
                                size: 13, color: AppColors.info),
                            const SizedBox(width: 3),
                            Text(
                              'Terverifikasi',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: AppColors.info),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textHint),
              ],
            ),

            if (!compact) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // ── Address ───────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      foundation.address,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // ── Phone ─────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: 15, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(foundation.contactPhone,
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FoundationAvatar extends StatelessWidget {
  final String name;
  const _FoundationAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    return Container(
      width:  44,
      height: 44,
      decoration: BoxDecoration(
        color:        AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize:   20,
          fontWeight: FontWeight.w800,
          color:      AppColors.primaryDark,
        ),
      ),
    );
  }
}