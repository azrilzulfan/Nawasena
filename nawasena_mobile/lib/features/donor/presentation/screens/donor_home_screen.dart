import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/theme/app_text_styles.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';
import 'package:nawasena_mobile/features/donor/presentation/widgets/foundation_card.dart';
import 'package:nawasena_mobile/features/donor/presentation/widgets/inventory_card.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  List<FoundationModel>  _nearbyFoundations = [];
  List<InventoryModel>   _urgentInventories = [];
  bool _locationLoading = true;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    await _loadNearby();
    _loadUrgentNeeds();
  }

  Future<void> _loadNearby() async {
    setState(() => _locationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _loadUrgentNeeds();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: 'Izin lokasi diperlukan untuk menampilkan panti terdekat.',
            type: SnackBarType.warning,
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        context.read<DonorBloc>().add(
          LoadNearbyFoundations(lat: pos.latitude, lng: pos.longitude),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Gagal mendapatkan lokasi: ${e.toString()}',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  void _loadUrgentNeeds() {
    context.read<DonorBloc>().add(
      const LoadGlobalInventories(urgentLevel: 'high', page: 1),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName  = authState is AuthAuthenticated
        ? authState.user.fullName.split(' ').first
        : 'Donor';

    return BlocListener<DonorBloc, DonorState>(
      listener: (context, state) {
        if (state is NearbyFoundationsLoaded) {
          setState(() => _nearbyFoundations = state.foundations);
        } else if (state is GlobalInventoriesLoaded) {
          setState(() => _urgentInventories = state.inventories.take(6).toList());
        } else if (state is DonorError) {
          AppSnackBar.show(context, message: state.message, type: SnackBarType.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(), style: AppTextStyles.bodySmall),
              Text(
                userName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          titleSpacing: 20,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () => context.push(AppRoutes.profile),
            ),
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => context.push(AppRoutes.donationHistory),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _initLoad,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner ──────────────────────────────────────
                _HeroBanner(
                  onExploreTap: () => context.push(AppRoutes.exploreNeeds),
                  onHistoryTap: () => context.push(AppRoutes.donationHistory),
                ),

                // ── Panti Terdekat ───────────────────────────────────
                _SectionHeader(
                  title:      'Panti Terdekat',
                  subtitle:   'Berdasarkan lokasi Anda saat ini',
                  onSeeAll:   null,
                ),
                _NearbyFoundationsList(
                  isLoading:   _locationLoading,
                  foundations: _nearbyFoundations,
                ),

                // ── Kebutuhan Mendesak ───────────────────────────────
                _SectionHeader(
                  title:    'Kebutuhan Mendesak',
                  subtitle: 'Item dengan prioritas tinggi',
                  onSeeAll: () => context.push(AppRoutes.exploreNeeds),
                ),
                BlocBuilder<DonorBloc, DonorState>(
                  builder: (context, state) {
                    if (state is GlobalInventoriesLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: AppLoadingIndicator(size: 32)),
                      );
                    }
                    return _UrgentNeedsList(
                      inventories: _urgentInventories,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero Banner ──────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final VoidCallback onExploreTap;
  final VoidCallback onHistoryTap;

  const _HeroBanner({required this.onExploreTap, required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism_outlined,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                'Donasi Barang',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Setiap donasi Anda\nmengubah kehidupan.',
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onExploreTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize:     const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Mulai Donasi'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onHistoryTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize:     const Size(0, 44),
                    side:            const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Riwayat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Lihat Semua'),
            ),
        ],
      ),
    );
  }
}

// ── Nearby Foundations List ───────────────────────────────────────────────────
class _NearbyFoundationsList extends StatelessWidget {
  final bool isLoading;
  final List<FoundationModel> foundations;

  const _NearbyFoundationsList({
    required this.isLoading,
    required this.foundations,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: AppLoadingIndicator(size: 32)),
      );
    }
    if (foundations.isEmpty) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color:        AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_outlined, color: AppColors.textHint, size: 32),
              SizedBox(height: 8),
              Text('Tidak ada panti dalam radius 5 km',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 170,
      child: ListView.separated(
        padding:     const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount:   foundations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final f = foundations[i];
          return FoundationCard(
            foundation: f,
            compact:    true,
            onTap: () =>
                context.push(AppRoutes.foundationDetailPath(f.id)),
          );
        },
      ),
    );
  }
}

// ── Urgent Needs List ─────────────────────────────────────────────────────────
class _UrgentNeedsList extends StatelessWidget {
  final List<InventoryModel> inventories;
  const _UrgentNeedsList({required this.inventories});

  @override
  Widget build(BuildContext context) {
    if (inventories.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:        AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Tidak ada kebutuhan mendesak saat ini.',
            style: TextStyle(color: AppColors.textHint),
          ),
        ),
      );
    }
    return ListView.separated(
      padding:     const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      itemCount:   inventories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final inv = inventories[i];
        return InventoryCard(
          inventory:          inv,
          showFoundationId:   true,
          onTap: () => context.push(AppRoutes.itemDetailPath(inv.id)),
        );
      },
    );
  }
}