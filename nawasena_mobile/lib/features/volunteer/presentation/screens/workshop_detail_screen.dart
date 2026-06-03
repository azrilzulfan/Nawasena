import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/theme/app_text_styles.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/core/widgets/primary_button.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:nawasena_mobile/features/volunteer/data/models/workshop_model.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_bloc.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_event.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_state.dart';

class WorkshopDetailScreen extends StatefulWidget {
  final String workshopId;
  const WorkshopDetailScreen({super.key, required this.workshopId});

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) _currentUserId = auth.user.id;
    _loadDetail();
  }

  void _loadDetail() {
    context.read<VolunteerBloc>().add(
      LoadWorkshopDetail(workshopId: widget.workshopId),
    );
  }

  void _handleState(BuildContext context, VolunteerState state) {
    if (state is WorkshopRegistered) {
      AppSnackBar.show(
        context,
        message: 'Berhasil mendaftar sebagai relawan!',
        type: SnackBarType.success,
      );
      _loadDetail();
    } else if (state is WorkshopUnregistered) {
      AppSnackBar.show(
        context,
        message: 'Pendaftaran berhasil dibatalkan.',
        type: SnackBarType.info,
      );
      _loadDetail();
    } else if (state is VolunteerError) {
      AppSnackBar.show(
        context,
        message: state.message,
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VolunteerBloc, VolunteerState>(
      listener: _handleState,
      child: BlocBuilder<VolunteerBloc, VolunteerState>(
        builder: (context, state) {
          if (state is WorkshopDetailLoading || state is WorkshopActionLoading) {
            return const Scaffold(
              body: Center(child: AppLoadingIndicator(size: 40)),
            );
          }
          if (state is WorkshopDetailLoaded) {
            final isRegistered = _currentUserId != null &&
                state.workshop.isUserRegistered(_currentUserId!);
            return _WorkshopDetailView(
              workshop: state.workshop,
              isRegistered: isRegistered,
              currentUserId: _currentUserId,
              onRegister: () => _confirmRegister(state.workshop),
              onUnregister: () => _confirmUnregister(state.workshop),
              onCheckin: () => context.push(
                AppRoutes.geofenceCheckinPath(widget.workshopId),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Workshop')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 56, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text('Gagal memuat detail workshop.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDetail,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmRegister(WorkshopModel workshop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _RegisterConfirmSheet(
        workshop: workshop,
        onConfirm: () {
          Navigator.pop(ctx);
          context.read<VolunteerBloc>().add(
            RegisterForWorkshop(workshopId: workshop.id),
          );
        },
      ),
    );
  }

  void _confirmUnregister(WorkshopModel workshop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Pendaftaran?'),
        content: Text(
          'Anda yakin ingin membatalkan pendaftaran dari "${workshop.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VolunteerBloc>().add(
                UnregisterFromWorkshop(workshopId: workshop.id),
              );
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

// ── Main Detail View ──────────────────────────────────────────────────────────
class _WorkshopDetailView extends StatelessWidget {
  final WorkshopModel workshop;
  final bool isRegistered;
  final String? currentUserId;
  final VoidCallback onRegister;
  final VoidCallback onUnregister;
  final VoidCallback onCheckin;

  const _WorkshopDetailView({
    required this.workshop,
    required this.isRegistered,
    required this.currentUserId,
    required this.onRegister,
    required this.onUnregister,
    required this.onCheckin,
  });

  bool get _isOpen       => workshop.status == WorkshopStatus.open;
  bool get _isFull       => workshop.isFull;
  bool get _eventStarted => DateTime.now().isAfter(workshop.eventDate);

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(workshop.eventDate);
    final timeStr = DateFormat('HH:mm').format(workshop.eventDate);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                workshop.title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, Color(0xFF1A3A2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 13, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Anda Terdaftar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
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
                  // ── Meta Info Cards ──────────────────────────────
                  _MetaInfoGrid(
                    dateStr: dateStr,
                    timeStr: timeStr,
                    workshop: workshop,
                  ),
                  const SizedBox(height: 24),

                  // ── Quota Bar ─────────────────────────────────────
                  _QuotaProgressCard(workshop: workshop),
                  const SizedBox(height: 24),

                  // ── Description ───────────────────────────────────
                  Text('Deskripsi Kegiatan', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(workshop.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),

                  // ── Location Info ─────────────────────────────────
                  if (workshop.location != null) ...[
                    Text('Lokasi & Geofence', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 10),
                    _LocationInfoCard(workshop: workshop),
                    const SizedBox(height: 24),
                  ],

                  // ── Registered Volunteers ─────────────────────────
                  if (isRegistered &&
                      workshop.registeredVolunteers.isNotEmpty) ...[
                    Text(
                      'Relawan Terdaftar (${workshop.mentorRegisteredCount})',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _VolunteerList(
                      volunteers: workshop.registeredVolunteers,
                      currentUserId: currentUserId,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Action Button Area ────────────────────────────
                  _ActionSection(
                    workshop: workshop,
                    isRegistered: isRegistered,
                    isOpen: _isOpen,
                    isFull: _isFull,
                    eventStarted: _eventStarted,
                    onRegister: onRegister,
                    onUnregister: onUnregister,
                    onCheckin: onCheckin,
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
}

// ── Meta Info Grid ─────────────────────────────────────────────────────────────
class _MetaInfoGrid extends StatelessWidget {
  final String dateStr;
  final String timeStr;
  final WorkshopModel workshop;
  const _MetaInfoGrid({
    required this.dateStr,
    required this.timeStr,
    required this.workshop,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        _MetaTile(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal',
          value: dateStr,
          color: AppColors.primary,
        ),
        _MetaTile(
          icon: Icons.access_time_outlined,
          label: 'Waktu',
          value: '$timeStr WIB',
          color: AppColors.secondary,
        ),
        _MetaTile(
          icon: Icons.people_outline_rounded,
          label: 'Kuota',
          value:
          '${workshop.mentorRegisteredCount} / ${workshop.mentorNeeded} orang',
          color: AppColors.info,
        ),
        _MetaTile(
          icon: Icons.radar_outlined,
          label: 'Geofence',
          value: '${workshop.geofenceRadiusMeters} meter',
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MetaTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 10)),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quota Progress Card ────────────────────────────────────────────────────────
class _QuotaProgressCard extends StatelessWidget {
  final WorkshopModel workshop;
  const _QuotaProgressCard({required this.workshop});

  @override
  Widget build(BuildContext context) {
    final ratio = workshop.mentorNeeded > 0
        ? (workshop.mentorRegisteredCount / workshop.mentorNeeded).clamp(0.0, 1.0)
        : 0.0;
    final color = workshop.isFull ? AppColors.error : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kuota Relawan',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terdaftar: ${workshop.mentorRegisteredCount} orang',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                workshop.isFull
                    ? 'Kuota penuh'
                    : 'Sisa: ${workshop.remainingSlots} slot',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Location Info Card ─────────────────────────────────────────────────────────
class _LocationInfoCard extends StatelessWidget {
  final WorkshopModel workshop;
  const _LocationInfoCard({required this.workshop});

  @override
  Widget build(BuildContext context) {
    final loc = workshop.location!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _LocRow(
            label: 'Latitude',
            value: loc.latitude.toStringAsFixed(6),
            icon: Icons.my_location_outlined,
          ),
          const Divider(height: 16),
          _LocRow(
            label: 'Longitude',
            value: loc.longitude.toStringAsFixed(6),
            icon: Icons.explore_outlined,
          ),
          const Divider(height: 16),
          _LocRow(
            label: 'Radius Check-in',
            value: '${workshop.geofenceRadiusMeters} meter dari titik panti',
            icon: Icons.radar_outlined,
          ),
        ],
      ),
    );
  }
}

class _LocRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _LocRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

// ── Volunteer List ─────────────────────────────────────────────────────────────
class _VolunteerList extends StatelessWidget {
  final List<RegisteredVolunteer> volunteers;
  final String? currentUserId;
  const _VolunteerList({required this.volunteers, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: volunteers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final v       = volunteers[i];
        final isMe    = v.userId == currentUserId;
        final initial = v.userName.isNotEmpty
            ? v.userName[0].toUpperCase()
            : '?';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primaryContainer : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: isMe
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                isMe ? AppColors.primary : AppColors.primaryLight,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isMe ? '${v.userName} (Anda)' : v.userName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Text(
                      v.status.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: v.status == VolunteerAttendanceStatus.attended
                      ? AppColors.successLight
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  v.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: v.status == VolunteerAttendanceStatus.attended
                        ? AppColors.success
                        : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Action Section ─────────────────────────────────────────────────────────────
class _ActionSection extends StatelessWidget {
  final WorkshopModel workshop;
  final bool isRegistered;
  final bool isOpen;
  final bool isFull;
  final bool eventStarted;
  final VoidCallback onRegister;
  final VoidCallback onUnregister;
  final VoidCallback onCheckin;

  const _ActionSection({
    required this.workshop,
    required this.isRegistered,
    required this.isOpen,
    required this.isFull,
    required this.eventStarted,
    required this.onRegister,
    required this.onUnregister,
    required this.onCheckin,
  });

  @override
  Widget build(BuildContext context) {
    // ── Sudah check-in / selesai ──────────────────────────────────
    if (workshop.status == WorkshopStatus.done) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_all_rounded, color: AppColors.textHint),
            SizedBox(width: 8),
            Text('Workshop ini telah selesai dilaksanakan.'),
          ],
        ),
      );
    }

    // ── Terdaftar: tampilkan checkin + unregister ─────────────────
    if (isRegistered) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (eventStarted)
            PrimaryButton(
              label: 'Check-in Sekarang',
              icon: Icons.location_on_rounded,
              onPressed: onCheckin,
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Check-in akan tersedia saat hari kegiatan tiba.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onUnregister,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.remove_circle_outline_rounded),
            label: const Text('Batalkan Pendaftaran'),
          ),
        ],
      );
    }

    // ── Belum daftar: tampilkan join ──────────────────────────────
    if (!isOpen) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pendaftaran untuk workshop ini sudah ditutup.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.warning),
              ),
            ),
          ],
        ),
      );
    }

    if (isFull) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.people_alt_outlined, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Kuota relawan untuk workshop ini sudah penuh.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    }

    return PrimaryButton(
      label: 'Daftar Sebagai Relawan',
      icon: Icons.group_add_outlined,
      onPressed: onRegister,
    );
  }
}

// ── Register Confirm Bottom Sheet ─────────────────────────────────────────────
class _RegisterConfirmSheet extends StatelessWidget {
  final WorkshopModel workshop;
  final VoidCallback onConfirm;
  const _RegisterConfirmSheet({required this.workshop, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
        .format(workshop.eventDate);
    final timeStr = DateFormat('HH:mm').format(workshop.eventDate);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Konfirmasi Pendaftaran',
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Anda akan mendaftar sebagai relawan untuk:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Workshop Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workshop.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                _SheetRow(
                  icon: Icons.calendar_today_outlined,
                  text: dateStr,
                ),
                const SizedBox(height: 4),
                _SheetRow(
                  icon: Icons.access_time_outlined,
                  text: '$timeStr WIB',
                ),
                const SizedBox(height: 4),
                _SheetRow(
                  icon: Icons.people_outline_rounded,
                  text:
                  '${workshop.remainingSlots} slot tersisa dari ${workshop.mentorNeeded} kuota',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Dengan mendaftar, Anda berkomitmen untuk hadir pada hari kegiatan. Check-in via GPS diperlukan untuk konfirmasi kehadiran.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.info),
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            label: 'Ya, Daftar Sekarang',
            icon: Icons.check_circle_outline_rounded,
            onPressed: onConfirm,
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SheetRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryDark),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}