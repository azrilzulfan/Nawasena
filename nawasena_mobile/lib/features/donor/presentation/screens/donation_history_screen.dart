import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/features/donor/data/models/donation_model.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';
import 'package:nawasena_mobile/features/donor/presentation/widgets/donation_status_chip.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<({String? status, String label})> _tabs = [
    (status: null,       label: 'Semua'),
    (status: 'pending',  label: 'Menunggu'),
    (status: 'sent',     label: 'Dikirim'),
    (status: 'received', label: 'Diterima'),
    (status: 'verified', label: 'Terverifikasi'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadDonations(_tabs[_tabController.index].status);
      }
    });
    _loadDonations(null);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDonations(String? status) {
    context.read<DonorBloc>().add(LoadMyDonations(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Donasi'),
        bottom: TabBar(
          controller:    _tabController,
          isScrollable:  true,
          tabAlignment:  TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor:    AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: BlocConsumer<DonorBloc, DonorState>(
        listener: (context, state) {
          if (state is DonorError) {
            AppSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is MyDonationsLoading) {
            return const Center(child: AppLoadingIndicator(size: 40));
          }
          if (state is MyDonationsLoaded) {
            if (state.donations.isEmpty) {
              return _EmptyDonationsView(
                onAction: () => _loadDonations(null),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  _loadDonations(_tabs[_tabController.index].status),
              color: AppColors.primary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.donations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  return _DonationHistoryCard(
                    donation: state.donations[i],
                    onTap: () => context.push(
                      AppRoutes.donationDetailPath(state.donations[i].id),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DonationHistoryCard extends StatelessWidget {
  final DonationModel donation;
  final VoidCallback onTap;

  const _DonationHistoryCard({required this.donation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final dateStr = donation.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
        .format(donation.createdAt!)
        : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ──────────────────────────────────────────────
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color:        donation.status.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: donation.status.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // ── Info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.itemDetail.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${donation.itemDetail.qty} ${donation.itemDetail.unit}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(dateStr, style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            // ── Status ─────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DonationStatusChip(status: donation.status),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: AppColors.textHint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDonationsView extends StatelessWidget {
  final VoidCallback onAction;
  const _EmptyDonationsView({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism_outlined,
                size: 72, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 20),
            Text('Belum Ada Donasi',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Mulai berdonasi dan jejak kebaikan Anda akan tampil di sini.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.exploreNeeds),
              icon:  const Icon(Icons.search_rounded),
              label: const Text('Cari Kebutuhan'),
            ),
          ],
        ),
      ),
    );
  }
}