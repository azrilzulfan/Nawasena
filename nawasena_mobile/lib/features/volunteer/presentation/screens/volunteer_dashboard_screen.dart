import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/theme/app_text_styles.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/features/auth/data/models/user_model.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:nawasena_mobile/features/volunteer/data/models/workshop_model.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_bloc.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_event.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_state.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/widgets/workshop_card.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;

  static const List<({String? status, String label})> _tabs = [
    (status: 'open',   label: 'Tersedia'),
    (status: null,     label: 'Semua'),
    (status: 'closed', label: 'Ditutup'),
    (status: 'done',   label: 'Selesai'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadWorkshops(_tabs[_tabController.index].status);
      }
    });

    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      _currentUserId = auth.user.id;
    }

    _loadWorkshops('open');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadWorkshops(String? status) {
    context.read<VolunteerBloc>().add(LoadGlobalWorkshops(status: status));
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
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(), style: AppTextStyles.bodySmall),
            Text(
              user?.fullName.split(' ').first ?? 'Relawan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        titleSpacing: 20,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push(AppRoutes.profile),
            tooltip: 'Profil',
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: Column(
        children: [
          // ── Hero Stats Banner ──────────────────────────────────────
          if (user != null) _VolunteerStatsBanner(user: user),

          // ── Workshop List ──────────────────────────────────────────
          Expanded(
            child: BlocConsumer<VolunteerBloc, VolunteerState>(
              listener: (context, state) {
                if (state is VolunteerError) {
                  AppSnackBar.show(
                    context,
                    message: state.message,
                    type: SnackBarType.error,
                  );
                }
              },
              builder: (context, state) {
                if (state is WorkshopsLoading) {
                  return const Center(child: AppLoadingIndicator(size: 40));
                }
                if (state is WorkshopsLoaded) {
                  if (state.workshops.isEmpty) {
                    return _EmptyWorkshopsView(
                      onRefresh: () =>
                          _loadWorkshops(_tabs[_tabController.index].status),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        _loadWorkshops(_tabs[_tabController.index].status),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: state.workshops.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final w = state.workshops[i];
                        final isReg = _currentUserId != null &&
                            w.isUserRegistered(_currentUserId!);
                        return WorkshopCard(
                          workshop: w,
                          isRegistered: isReg,
                          onTap: () => context.push(
                            AppRoutes.workshopDetailPath(w.id),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Volunteer Stats Banner ────────────────────────────────────────────────────
class _VolunteerStatsBanner extends StatelessWidget {
  final UserModel user;
  const _VolunteerStatsBanner({required this.user});

  @override
  Widget build(BuildContext context) {
    final skills = user.volunteerProfile?.skills ?? [];
    final hours  = user.volunteerProfile?.totalHours ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Relawan',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  user.fullName,
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (skills.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skills.take(3).map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$hours',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'jam',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Total Jam',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty View ────────────────────────────────────────────────────────────────
class _EmptyWorkshopsView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyWorkshopsView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Workshop',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Saat ini belum ada kegiatan yang tersedia. Cek kembali nanti.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}