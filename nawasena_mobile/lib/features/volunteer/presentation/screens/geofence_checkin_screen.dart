import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/theme/app_text_styles.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/core/widgets/primary_button.dart';
import 'package:nawasena_mobile/features/volunteer/data/models/workshop_model.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_bloc.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_event.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_state.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/widgets/geofence_radar_painter.dart';

class GeofenceCheckinScreen extends StatefulWidget {
  final String workshopId;
  const GeofenceCheckinScreen({super.key, required this.workshopId});

  @override
  State<GeofenceCheckinScreen> createState() => _GeofenceCheckinScreenState();
}

class _GeofenceCheckinScreenState extends State<GeofenceCheckinScreen>
    with TickerProviderStateMixin {
  // ── Animation ─────────────────────────────────────────────────────────────
  late AnimationController _radarController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── GPS State ──────────────────────────────────────────────────────────────
  Position?      _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool           _locationLoading = true;
  String         _locationError   = '';

  // ── Workshop State ─────────────────────────────────────────────────────────
  WorkshopModel? _workshop;
  double         _distanceToTarget = double.infinity;
  bool           _isInsideGeofence = false;
  bool           _checkinDone      = false;

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadWorkshopThenStartGps();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _pulseController.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  // ── Load workshop detail first, then start GPS tracking ───────────────────
  Future<void> _loadWorkshopThenStartGps() async {
    context.read<VolunteerBloc>().add(
      LoadWorkshopDetail(workshopId: widget.workshopId),
    );
  }

  // ── Request permission and start GPS stream ────────────────────────────────
  Future<void> _startGpsTracking() async {
    setState(() {
      _locationLoading = true;
      _locationError   = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError   = 'Layanan GPS tidak aktif. Aktifkan GPS di pengaturan perangkat.';
          _locationLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _locationError   = 'Izin lokasi ditolak. Berikan izin lokasi di pengaturan aplikasi.';
          _locationLoading = false;
        });
        return;
      }

      // Get initial position
      final initial = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updatePosition(initial);

      // Subscribe to live updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy:         LocationAccuracy.high,
          distanceFilter:   2, // update every 2 meters moved
        ),
      ).listen(
        _updatePosition,
        onError: (e) => setState(() => _locationError = e.toString()),
      );
    } catch (e) {
      setState(() {
        _locationError   = 'Gagal mendapatkan lokasi: ${e.toString()}';
        _locationLoading = false;
      });
    }
  }

  // ── Recalculate distance whenever position updates ────────────────────────
  void _updatePosition(Position pos) {
    if (!mounted) return;
    setState(() {
      _currentPosition = pos;
      _locationLoading = false;
    });

    if (_workshop?.location == null) return;

    final targetLat = _workshop!.location!.latitude;
    final targetLng = _workshop!.location!.longitude;
    final dist      = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      targetLat,
      targetLng,
    );

    setState(() {
      _distanceToTarget = dist;
      _isInsideGeofence = dist <= _workshop!.geofenceRadiusMeters;
    });
  }

  // ── Execute check-in API call ──────────────────────────────────────────────
  void _executeCheckin() {
    if (_currentPosition == null) return;
    context.read<VolunteerBloc>().add(
      CheckinWorkshop(
        workshopId: widget.workshopId,
        lat:        _currentPosition!.latitude,
        lng:        _currentPosition!.longitude,
      ),
    );
  }

  void _handleState(BuildContext context, VolunteerState state) {
    if (state is WorkshopDetailLoaded) {
      setState(() => _workshop = state.workshop);
      _startGpsTracking();
    } else if (state is CheckinSuccess) {
      setState(() => _checkinDone = true);
      _positionStream?.cancel();
      AppSnackBar.show(
        context,
        message: state.message,
        type: SnackBarType.success,
        duration: const Duration(seconds: 4),
      );
    } else if (state is VolunteerError) {
      AppSnackBar.show(
        context,
        message: state.message,
        type: SnackBarType.error,
      );
    }
  }

  // ── Compute bearing angle for directional indicator ───────────────────────
  double _getBearing() {
    if (_workshop?.location == null || _currentPosition == null) return 0.0;
    final lat1 = _currentPosition!.latitude * math.pi / 180;
    final lat2 = _workshop!.location!.latitude * math.pi / 180;
    final dLng = (_workshop!.location!.longitude - _currentPosition!.longitude) *
        math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return math.atan2(y, x);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VolunteerBloc, VolunteerState>(
      listener: _handleState,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Check-in Kehadiran'),
          centerTitle: true,
        ),
        body: BlocBuilder<VolunteerBloc, VolunteerState>(
          builder: (context, state) {
            // Loading workshop detail
            if (state is WorkshopDetailLoading) {
              return const Center(child: AppLoadingIndicator(size: 48));
            }

            // Check-in success view
            if (_checkinDone) {
              return _CheckinSuccessView(
                workshopTitle: _workshop?.title ?? 'Workshop',
                onBack: () => Navigator.pop(context),
              );
            }

            return Column(
              children: [
                // ── Workshop Info Header ─────────────────────────────
                if (_workshop != null)
                  _WorkshopInfoHeader(workshop: _workshop!),

                // ── Radar Visualization ──────────────────────────────
                Expanded(
                  child: _locationLoading
                      ? const _GpsLoadingView()
                      : _locationError.isNotEmpty
                      ? _GpsErrorView(
                    message: _locationError,
                    onRetry: _startGpsTracking,
                  )
                      : _RadarView(
                    radarController: _radarController,
                    pulseAnim: _pulseAnim,
                    isInsideGeofence: _isInsideGeofence,
                    distanceToTarget: _distanceToTarget,
                    currentPosition: _currentPosition,
                    workshop: _workshop,
                    bearing: _getBearing(),
                  ),
                ),

                // ── Bottom Action Panel ──────────────────────────────
                _BottomActionPanel(
                  isInsideGeofence: _isInsideGeofence,
                  distanceToTarget: _distanceToTarget,
                  locationLoading: _locationLoading,
                  locationError: _locationError,
                  workshop: _workshop,
                  isCheckinLoading: state is CheckinLoading,
                  onCheckin: _isInsideGeofence ? _executeCheckin : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Workshop Info Header ───────────────────────────────────────────────────────
class _WorkshopInfoHeader extends StatelessWidget {
  final WorkshopModel workshop;
  const _WorkshopInfoHeader({required this.workshop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      color: AppColors.primaryContainer,
      child: Row(
        children: [
          const Icon(Icons.groups_outlined,
              color: AppColors.primaryDark, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workshop.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.primaryDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Radius check-in: ${workshop.geofenceRadiusMeters} meter',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Radar View ─────────────────────────────────────────────────────────────────
class _RadarView extends StatelessWidget {
  final AnimationController radarController;
  final Animation<double> pulseAnim;
  final bool isInsideGeofence;
  final double distanceToTarget;
  final Position? currentPosition;
  final WorkshopModel? workshop;
  final double bearing;

  const _RadarView({
    required this.radarController,
    required this.pulseAnim,
    required this.isInsideGeofence,
    required this.distanceToTarget,
    required this.currentPosition,
    required this.workshop,
    required this.bearing,
  });

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final activeColor = isInsideGeofence ? AppColors.success : AppColors.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),

        // ── Animated Radar ───────────────────────────────────────────
        AnimatedBuilder(
          animation: radarController,
          builder: (context, child) {
            return ScaleTransition(
              scale: pulseAnim,
              child: SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: GeofenceRadarPainter(
                    animationValue: radarController.value,
                    isInside: isInsideGeofence,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isInsideGeofence
                              ? Icons.check_circle_rounded
                              : Icons.my_location_rounded,
                          color: activeColor,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isInsideGeofence ? 'Dalam Area' : 'Di Luar Area',
                          style: TextStyle(
                            color: activeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // ── Distance Display ─────────────────────────────────────────
        if (distanceToTarget != double.infinity) ...[
          Text(
            distanceToTarget >= 1000
                ? '${(distanceToTarget / 1000).toStringAsFixed(2)} km'
                : '${distanceToTarget.toStringAsFixed(0)} m',
            style: AppTextStyles.displayMedium.copyWith(color: activeColor),
          ),
          Text(
            'dari lokasi workshop',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
        ],

        // ── GPS Coordinates ──────────────────────────────────────────
        if (currentPosition != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gps_fixed_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '${currentPosition!.latitude.toStringAsFixed(5)}, '
                      '${currentPosition!.longitude.toStringAsFixed(5)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // ── Directional Hint ─────────────────────────────────────────
        if (!isInsideGeofence && workshop?.location != null)
          _DirectionalHint(bearing: bearing),
      ],
    );
  }
}

// ── Directional Arrow ─────────────────────────────────────────────────────────
class _DirectionalHint extends StatelessWidget {
  final double bearing;
  const _DirectionalHint({required this.bearing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: bearing,
            child: const Icon(
              Icons.navigation_rounded,
              color: AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Menuju lokasi workshop',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.info),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Action Panel ────────────────────────────────────────────────────────
class _BottomActionPanel extends StatelessWidget {
  final bool isInsideGeofence;
  final double distanceToTarget;
  final bool locationLoading;
  final String locationError;
  final WorkshopModel? workshop;
  final bool isCheckinLoading;
  final VoidCallback? onCheckin;

  const _BottomActionPanel({
    required this.isInsideGeofence,
    required this.distanceToTarget,
    required this.locationLoading,
    required this.locationError,
    required this.workshop,
    required this.isCheckinLoading,
    required this.onCheckin,
  });

  @override
  Widget build(BuildContext context) {
    final theme         = Theme.of(context);
    final canCheckin    = isInsideGeofence && locationError.isEmpty && !locationLoading;
    final radius        = workshop?.geofenceRadiusMeters ?? 100;
    final remaining     = (distanceToTarget - radius).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Status Indicator ───────────────────────────────────────
          if (!locationLoading && locationError.isEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isInsideGeofence
                    ? AppColors.successLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isInsideGeofence
                      ? AppColors.success
                      : AppColors.warning,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isInsideGeofence
                        ? Icons.location_on_rounded
                        : Icons.location_searching_rounded,
                    color: isInsideGeofence
                        ? AppColors.success
                        : AppColors.warning,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isInsideGeofence
                              ? 'Anda berada dalam area check-in!'
                              : 'Anda belum dalam area check-in',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isInsideGeofence
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        if (!isInsideGeofence &&
                            distanceToTarget != double.infinity)
                          Text(
                            'Dekati ${remaining.toStringAsFixed(0)} meter lagi ke lokasi workshop.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Check-in Button ────────────────────────────────────────
          PrimaryButton(
            label: canCheckin ? 'Konfirmasi Check-in' : 'Belum Dalam Radius',
            icon: canCheckin
                ? Icons.how_to_reg_rounded
                : Icons.location_off_outlined,
            isLoading: isCheckinLoading,
            onPressed: canCheckin ? onCheckin : null,
          ),

          if (!canCheckin && !locationLoading && locationError.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Tombol akan aktif saat Anda berada dalam radius ${workshop?.geofenceRadiusMeters ?? 100} meter dari lokasi workshop.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ── GPS Loading View ───────────────────────────────────────────────────────────
class _GpsLoadingView extends StatelessWidget {
  const _GpsLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLoadingIndicator(size: 48),
          const SizedBox(height: 20),
          Text(
            'Mendeteksi lokasi Anda...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan GPS aktif dan izin lokasi diberikan.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── GPS Error View ─────────────────────────────────────────────────────────────
class _GpsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _GpsErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gps_off_rounded,
                size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Gagal Mendapatkan Lokasi',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Check-in Success View ──────────────────────────────────────────────────────
class _CheckinSuccessView extends StatelessWidget {
  final String workshopTitle;
  final VoidCallback onBack;
  const _CheckinSuccessView({required this.workshopTitle, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Animated Success Icon ───────────────────────────────
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.how_to_reg_rounded,
                  size: 52,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Check-in Berhasil!',
              style: theme.textTheme.displayMedium
                  ?.copyWith(color: AppColors.success),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Kehadiran Anda untuk kegiatan',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '"$workshopTitle"',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: AppColors.primaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'telah berhasil dikonfirmasi.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volunteer_activism_outlined,
                      color: AppColors.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Jam relawan Anda akan diperbarui setelah kegiatan selesai.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Kembali ke Detail Workshop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}