import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/theme/app_text_styles.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/features/donor/data/models/donation_model.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';

class QrCodeScreen extends StatefulWidget {
  final String donationId;
  const QrCodeScreen({super.key, required this.donationId});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DonorBloc>().add(LoadDonationQr(donationId: widget.donationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Serah Terima'),
        centerTitle: true,
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
          if (state is DonationQrLoading) {
            return const Center(child: AppLoadingIndicator(size: 48));
          }
          if (state is DonationQrLoaded) {
            return _QrContent(qr: state.qrCode);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_2_rounded,
                    size: 64, color: AppColors.textHint),
                const SizedBox(height: 16),
                const Text('Gagal memuat QR Code.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<DonorBloc>().add(
                    LoadDonationQr(donationId: widget.donationId),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QrContent extends StatelessWidget {
  final QrCodeModel qr;
  const _QrContent({required this.qr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Status Badge ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color:        qr.status.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Status: ${qr.status.label}',
              style: TextStyle(
                color:      qr.status.color,
                fontWeight: FontWeight.w700,
                fontSize:   13,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── QR Code Card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color:      AppColors.shadow,
                  blurRadius: 20,
                  offset:     const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // QR image rendered from hash string
                QrImageView(
                  data:            qr.qrCodeHash,
                  version:         QrVersions.auto,
                  size:            240,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape:  QrEyeShape.square,
                    color:     AppColors.primaryDark,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color:           AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:        AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ID Donasi',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        qr.donationId,
                        style: AppTextStyles.labelSmall.copyWith(
                          color:          AppColors.primaryDark,
                          letterSpacing:  1.2,
                          fontWeight:     FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Instruction ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:        AppColors.infoLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Cara Penggunaan QR Code',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.info),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Tunjukkan QR Code ini kepada petugas panti saat menyerahkan donasi.\n'
                      '2. Petugas akan memindai kode ini untuk memverifikasi donasi Anda.\n'
                      '3. Setelah dipindai, status donasi akan otomatis berubah menjadi Terverifikasi.',
                  style:     theme.textTheme.bodySmall,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Warning if already verified ───────────────────────────
          if (qr.status == DonationStatus.verified)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:        AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Donasi ini sudah berhasil terverifikasi. QR Code tidak dapat digunakan kembali.',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}