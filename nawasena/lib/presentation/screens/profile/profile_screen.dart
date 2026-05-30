import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../blocs/auth/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  UserModel? _user;
  Map<String, dynamic>? _portfolio;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authRepo.getMe();
      // TODO: fetch portfolio from /api/users/{id}/portfolio
      setState(() => _user = user);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(body: Center(child: Text('Gagal memuat profil')));
    }

    final u = _user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Profil Saya',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Avatar & Name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: u.avatarUrl != null
                          ? CachedNetworkImageProvider(u.avatarUrl!)
                          : null,
                      child: u.avatarUrl == null
                          ? const Icon(Icons.person,
                              size: 40, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(u.fullName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      u.role == 'volunteer' ? 'Mentor & Relawan' : 'Donatur Aktif',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _profileStat('${u.volunteerHours}', 'JAM RELAWAN'),
                  _profileStat('${u.foundationsHelped}', 'PANTI DIBANTU'),
                  _profileStat('15kg', 'BARANG DONASI'),
                ],
              ),
              const SizedBox(height: 24),

              // Skills
              const Text('Keahlian Saya',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...u.skills.map((s) => _skillChip(s)),
                  ActionChip(
                    label: const Text('+ Tambah Skill'),
                    onPressed: () {},
                    backgroundColor: AppColors.primaryLight,
                    labelStyle: const TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upcoming Schedule
              const Text('Jadwal Terdekat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _scheduleCard(),
              const SizedBox(height: 20),

              // Donation History
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('Riwayat Donasi Logistik'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              const SizedBox(height: 16),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.urgentRed,
                    side: const BorderSide(color: AppColors.urgentRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Keluar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileStat(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      );

  Widget _skillChip(String label) => Chip(
        label: Text(label),
        backgroundColor: AppColors.primaryLight,
        labelStyle:
            const TextStyle(color: AppColors.primary, fontSize: 13),
        side: BorderSide.none,
      );

  Widget _scheduleCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MENGAJAR',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Workshop Literasi Digital',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Panti Asuhan Kasih Ibu',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text('APRIL',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11)),
                const Text('22',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      );
}