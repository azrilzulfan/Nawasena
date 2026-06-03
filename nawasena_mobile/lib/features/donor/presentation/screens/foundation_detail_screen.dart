import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/core/widgets/primary_button.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';
import 'package:nawasena_mobile/features/donor/presentation/widgets/inventory_card.dart';

class FoundationDetailScreen extends StatefulWidget {
  final String foundationId;
  const FoundationDetailScreen({super.key, required this.foundationId});

  @override
  State<FoundationDetailScreen> createState() => _FoundationDetailScreenState();
}

class _FoundationDetailScreenState extends State<FoundationDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DonorBloc>().add(
      LoadFoundationDetail(foundationId: widget.foundationId),
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
        if (state is FoundationDetailLoading) {
          return const Scaffold(body: Center(child: AppLoadingIndicator(size: 40)));
        }
        if (state is FoundationDetailLoaded) {
          return _FoundationDetailView(
            foundation:  state.foundation,
            inventories: state.inventories,
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Detail Panti')),
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.read<DonorBloc>().add(
                LoadFoundationDetail(foundationId: widget.foundationId),
              ),
              child: const Text('Coba Lagi'),
            ),
          ),
        );
      },
    );
  }
}

class _FoundationDetailView extends StatelessWidget {
  final FoundationModel     foundation;
  final List<InventoryModel> inventories;

  const _FoundationDetailView({
    required this.foundation,
    required this.inventories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned:         true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                foundation.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color:        Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          foundation.name.isNotEmpty
                              ? foundation.name[0].toUpperCase()
                              : 'P',
                          style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (foundation.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color:        Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Terverifikasi', style: TextStyle(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                              )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Description ────────────────────────────────────
                  Text('Tentang Panti', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(foundation.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 20),

                  // ── Contact Info ───────────────────────────────────
                  Text('Informasi Kontak', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _ContactTile(
                    icon:    Icons.location_on_outlined,
                    label:   'Alamat',
                    value:   foundation.address,
                    onTap:   null,
                  ),
                  _ContactTile(
                    icon:    Icons.phone_outlined,
                    label:   'Telepon',
                    value:   foundation.contactPhone,
                    onTap:   () => _copyToClipboard(context, foundation.contactPhone),
                  ),

                  // ── Bank Account ───────────────────────────────────
                  if (foundation.bankAccount != null) ...[
                    const SizedBox(height: 20),
                    Text('Rekening Donasi Uang', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _BankAccountCard(bank: foundation.bankAccount!),
                  ],
                  const SizedBox(height: 24),

                  // ── Inventory List ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kebutuhan Panti', style: theme.textTheme.titleLarge),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${inventories.length} item',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (inventories.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:        AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('Panti ini belum memiliki daftar kebutuhan.'),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics:    const NeverScrollableScrollPhysics(),
                      itemCount:  inventories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final inv = inventories[i];
                        return InventoryCard(
                          inventory: inv,
                          onTap: () =>
                              context.push(AppRoutes.itemDetailPath(inv.id)),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.show(
      context,
      message: 'Disalin ke clipboard!',
      type: SnackBarType.success,
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:  const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  Text(value, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.copy_outlined, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  final BankAccount bank;
  const _BankAccountCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryDark],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bank.bankName,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16,
                ),
              ),
              const Icon(Icons.account_balance_outlined,
                  color: Colors.white70, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Text(bank.accountNumber,
              style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
                letterSpacing: 2,
              )),
          const SizedBox(height: 4),
          Text(bank.accountName,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: bank.accountNumber));
              AppSnackBar.show(
                context,
                message: 'Nomor rekening disalin!',
                type: SnackBarType.success,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:        Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('Salin Nomor', style: TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}