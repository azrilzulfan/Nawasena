import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/features/volunteer/data/models/workshop_model.dart';

class WorkshopCard extends StatelessWidget {
  final WorkshopModel workshop;
  final VoidCallback onTap;
  final bool isRegistered;
  final bool compact;

  const WorkshopCard({
    super.key,
    required this.workshop,
    required this.onTap,
    this.isRegistered = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final isFull    = workshop.isFull;
    final isClosed  = workshop.status != WorkshopStatus.open;
    final dateStr   = DateFormat('EEE, dd MMM yyyy', 'id_ID').format(workshop.eventDate);
    final timeStr   = DateFormat('HH:mm').format(workshop.eventDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRegistered ? AppColors.primary : AppColors.border,
            width: isRegistered ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ─────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isRegistered
                        ? AppColors.primaryContainer
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.groups_outlined,
                    color: isRegistered ? AppColors.primary : AppColors.textHint,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _WorkshopStatusBadge(
                        status: workshop.status,
                        isRegistered: isRegistered,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textHint,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Date Row ───────────────────────────────────────────
            _MetaRow(
              icon: Icons.calendar_today_outlined,
              text: '$dateStr  ·  $timeStr WIB',
            ),
            const SizedBox(height: 8),

            // ── Quota Row ──────────────────────────────────────────
            _MetaRow(
              icon: Icons.people_outline_rounded,
              text:
              '${workshop.mentorRegisteredCount} / ${workshop.mentorNeeded} relawan terdaftar',
              trailing: isFull
                  ? _Tag(label: 'Penuh', color: AppColors.error)
                  : _Tag(
                label: '${workshop.remainingSlots} slot tersisa',
                color: AppColors.success,
              ),
            ),

            if (!compact && workshop.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                workshop.description,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkshopStatusBadge extends StatelessWidget {
  final WorkshopStatus status;
  final bool isRegistered;
  const _WorkshopStatusBadge({required this.status, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    if (isRegistered) {
      bgColor   = AppColors.primaryContainer;
      textColor = AppColors.primaryDark;
      label     = 'Terdaftar';
      icon      = Icons.check_circle_outline_rounded;
    } else {
      switch (status) {
        case WorkshopStatus.open:
          bgColor   = AppColors.successLight;
          textColor = AppColors.success;
          label     = 'Buka';
          icon      = Icons.lock_open_rounded;
        case WorkshopStatus.closed:
          bgColor   = AppColors.warningLight;
          textColor = AppColors.warning;
          label     = 'Ditutup';
          icon      = Icons.lock_outline_rounded;
        case WorkshopStatus.done:
          bgColor   = AppColors.surfaceVariant;
          textColor = AppColors.textHint;
          label     = 'Selesai';
          icon      = Icons.done_all_rounded;
        case WorkshopStatus.unknown:
          bgColor   = AppColors.surfaceVariant;
          textColor = AppColors.textHint;
          label     = '-';
          icon      = Icons.help_outline_rounded;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;
  const _MetaRow({required this.icon, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textHint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
        ?trailing,
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}