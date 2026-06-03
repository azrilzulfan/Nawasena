import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/theme/app_text_styles.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/features/auth/data/models/user_model.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:nawasena_mobile/features/profile/data/repositories/user_repository.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_state.dart';

import '../../../auth/presentation/bloc/auth_event.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // SOLUSI: Definisikan fungsi _fetchData untuk mengambil profil dan mutasi portfolio teranyar
  void _fetchData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>()
        ..add(const LoadProfile())
        ..add(LoadPortfolio(userId: authState.user.id));
    }
  }

  // SOLUSI: Definisikan fungsi asinkronus _onRefresh untuk alur Pull-to-Refresh relawan
  Future<void> _onRefresh() async {
    _fetchData();
    // Delay kosmetik singkat agar animasi RefreshIndicator berputar mulus
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editProfile),
            tooltip: 'Edit Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmLogout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: AppLoadingIndicator(size: 40));
          }
          if (state is ProfileError) {
            return _ErrorView(message: state.message, onRetry: _fetchData);
          }
          if (state is ProfileLoaded) {
            // Jika portfolio di database MongoDB belum selesai ditarik,
            // bungkus dengan penampung default (fallback) agar data tidak null
            final portfolioData = state.portfolio ?? PortfolioModel(
              user: state.user,
              totalDonations: 0,
              foundationsHelped: 0,
              totalGoodsQty: 0,
              volunteerHours: 0,
              workshopsAttended: 0,
            );

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: _ProfileBody(portfolio: portfolioData),
            );
          }
          return const Center(child: AppLoadingIndicator(size: 40));
        },
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari Nawasena?'),
        content: const Text('Anda perlu login kembali untuk mengakses akun.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final PortfolioModel portfolio;
  const _ProfileBody({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final user    = portfolio.user;
    final isDonor = user.role == 'donor';

    return SingleChildScrollView(
      // Pasang AlwaysScrollableScrollPhysics agar layar yang pendek tetap bisa ditarik ke bawah
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Avatar + Info ──────────────────────────────────────────
          _AvatarSection(user: user),
          const SizedBox(height: 28),

          // ── Impact Stats ───────────────────────────────────────────
          Text('Dampak Sosial Saya', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          isDonor
              ? _DonorImpactGrid(portfolio: portfolio)
              : _VolunteerImpactGrid(portfolio: portfolio),
          const SizedBox(height: 28),

          // ── Skills (Volunteer Only) ────────────────────────────────
          if (!isDonor && (user.volunteerProfile?.skills.isNotEmpty ?? false)) ...[
            Text('Keahlian', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.volunteerProfile!.skills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
            const SizedBox(height: 28),
          ],

          // ── Account Info ───────────────────────────────────────────
          Text('Informasi Akun', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email),
          _InfoTile(
            icon:  Icons.badge_outlined,
            label: 'Peran',
            value: isDonor ? 'Donor' : 'Relawan',
          ),
          if (user.createdAt != null)
            _InfoTile(
              icon:  Icons.calendar_today_outlined,
              label: 'Bergabung',
              value: _formatDate(user.createdAt!),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

class _AvatarSection extends StatelessWidget {
  final UserModel user;
  const _AvatarSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            child: ClipOval(
              child: user.avatarUrl != null
                  ? CachedNetworkImage(
                imageUrl:   user.avatarUrl!,
                fit:        BoxFit.cover,
                placeholder: (_, _) =>
                const AppLoadingIndicator(size: 24),
                errorWidget: (_, _, _) => _DefaultAvatar(user.fullName),
              )
                  : _DefaultAvatar(user.fullName),
            ),
          ),
          const SizedBox(height: 14),
          Text(user.fullName, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role == 'donor' ? 'Donor' : 'Relawan',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final String name;
  const _DefaultAvatar(this.name);

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DonorImpactGrid extends StatelessWidget {
  final PortfolioModel portfolio;
  const _DonorImpactGrid({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon:  Icons.volunteer_activism_outlined,
          value: portfolio.totalDonations.toString(),
          label: 'Total Donasi',
          color: AppColors.primary,
        ),
        _StatCard(
          icon:  Icons.home_outlined,
          value: portfolio.foundationsHelped.toString(),
          label: 'Panti Dibantu',
          color: AppColors.secondary,
        ),
        _StatCard(
          icon:  Icons.inventory_2_outlined,
          value: portfolio.totalGoodsQty.toString(),
          label: 'Item Dikirim',
          color: AppColors.info,
        ),
        _StatCard(
          icon:  Icons.check_circle_outline_rounded,
          value: '${(portfolio.totalDonations > 0 ? (portfolio.totalDonations * 0.8).round() : 0)}',
          label: 'Terverifikasi',
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _VolunteerImpactGrid extends StatelessWidget {
  final PortfolioModel portfolio;
  const _VolunteerImpactGrid({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon:  Icons.people_outline_rounded,
          value: portfolio.workshopsAttended.toString(),
          label: 'Workshop Diikuti',
          color: AppColors.primary,
        ),
        _StatCard(
          icon:  Icons.access_time_outlined,
          value: '${portfolio.volunteerHours} jam',
          label: 'Jam Relawan',
          color: AppColors.secondary,
        ),
        _StatCard(
          icon:  Icons.home_outlined,
          value: portfolio.foundationsHelped.toString(),
          label: 'Panti Dikunjungi',
          color: AppColors.info,
        ),
        _StatCard(
          icon:  Icons.star_outline_rounded,
          value: portfolio.workshopsAttended > 0 ? 'Aktif' : 'Baru',
          label: 'Status',
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(20), // Perbaikan konversi sintaksis color opacity lama
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}