import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/core/widgets/primary_button.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';

class ItemDetailScreen extends StatefulWidget {
  final String inventoryId;
  const ItemDetailScreen({super.key, required this.inventoryId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DonorBloc>().add(
      LoadInventoryDetail(inventoryId: widget.inventoryId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DonorBloc, DonorState>(
      listener: (context, state) {
        if (state is DonorError) {
          AppSnackBar.show(context, message: state.message, type: SnackBarType.error);
        }
      },
      builder: (context, state) {
        if (state is InventoryDetailLoading) {
          return const Scaffold(body: Center(child: AppLoadingIndicator(size: 40)));
        }
        if (state is InventoryDetailLoaded) {
          return _ItemDetailView(inventory: state.inventory);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Detail Kebutuhan')),
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.read<DonorBloc>().add(
                LoadInventoryDetail(inventoryId: widget.inventoryId),
              ),
              child: const Text('Coba Lagi'),
            ),
          ),
        );
      },
    );
  }
}

class _ItemDetailView extends StatelessWidget {
  final InventoryModel inventory;
  const _ItemDetailView({required this.inventory});

  @override
  Widget build(BuildContext context) {
    final ratio  = inventory.fulfillmentRatio;
    final urgent = inventory.urgentLevel;
    final theme  = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kebutuhan')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: PrimaryButton(
            label:    'Donasikan Sekarang',
            icon:     Icons.volunteer_activism_outlined,
            onPressed: inventory.isFulfilled
                ? null
                : () => context.push(
              '${AppRoutes.donationPledgePath(inventory.id)}?foundationId=${inventory.foundationId}',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inventory.itemName, style: theme.textTheme.displayMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _Tag(label: inventory.category.label, color: AppColors.info),
                          _Tag(label: urgent.label, color: urgent.color),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Progress Section ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:        AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress Pemenuhan', style: theme.textTheme.titleMedium),
                      Text(
                        '${(ratio * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.titleLarge?.copyWith(color: urgent.color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value:           ratio,
                      minHeight:       14,
                      backgroundColor: AppColors.border,
                      valueColor:      AlwaysStoppedAnimation<Color>(urgent.color),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ProgressStat(
                          label: 'Terkumpul',
                          value: '${inventory.currentQty} ${inventory.unit}',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ProgressStat(
                          label: 'Dibutuhkan',
                          value: '${inventory.targetQty} ${inventory.unit}',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ProgressStat(
                          label: 'Kurang',
                          value: '${inventory.remainingQty} ${inventory.unit}',
                          color: urgent.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Description ──────────────────────────────────────────
            if (inventory.description != null) ...[
              Text('Deskripsi', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(inventory.description!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
            ],

            // ── Status Banner ────────────────────────────────────────
            if (inventory.isFulfilled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        AppColors.successLight,
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Kebutuhan ini sudah terpenuhi. Terima kasih kepada para donor!',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        urgent.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(color: urgent.color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: urgent.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Masih dibutuhkan ${inventory.remainingQty} ${inventory.unit} lagi. Anda bisa membantu!',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: urgent.color),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w700,
          color:      color,
        ),
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ProgressStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
      ],
    );
  }
}