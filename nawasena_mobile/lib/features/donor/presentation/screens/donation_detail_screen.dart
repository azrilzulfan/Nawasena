import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/core/widgets/primary_button.dart';
import 'package:nawasena_mobile/features/donor/data/models/donation_model.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';
import 'package:nawasena_mobile/features/donor/presentation/widgets/donation_status_chip.dart';

class DonationDetailScreen extends StatefulWidget {
  final String donationId;
  const DonationDetailScreen({super.key, required this.donationId});

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  File? _proofImage;

  @override
  void initState() {
    super.initState();
    context.read<DonorBloc>().add(
      LoadDonationDetail(donationId: widget.donationId),
    );
  }

  Future<void> _pickProofImage() async {
    final picker = ImagePicker();
    final file   = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null) setState(() => _proofImage = File(file.path));
  }

  void _markAsSent() {
    context.read<DonorBloc>().add(
      UpdateDonationToSent(
        donationId:     widget.donationId,
        proofImagePath: _proofImage?.path,
      ),
    );
  }

  void _handleState(BuildContext context, DonorState state) {
    if (state is DonationStatusUpdated) {
      AppSnackBar.show(
        context,
        message: 'Status donasi berhasil diperbarui!',
        type: SnackBarType.success,
      );
      // Reload detail
      context.read<DonorBloc>().add(
        LoadDonationDetail(donationId: widget.donationId),
      );
    } else if (state is DonorError) {
      AppSnackBar.show(context, message: state.message, type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DonorBloc, DonorState>(
      listener: _handleState,
      child: BlocBuilder<DonorBloc, DonorState>(
        builder: (context, state) {
          if (state is DonationDetailLoading) {
            return const Scaffold(body: Center(child: AppLoadingIndicator(size: 40)));
          }
          if (state is DonationDetailLoaded || state is DonationStatusUpdated) {
            final donation = state is DonationDetailLoaded
                ? state.donation
                : (state as DonationStatusUpdated).donation;
            return _DonationDetailView(
              donation:     donation,
              proofImage:   _proofImage,
              onPickProof:  _pickProofImage,
              onMarkSent:   _markAsSent,
              isUpdating:   false,
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Donasi')),
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.read<DonorBloc>().add(
                  LoadDonationDetail(donationId: widget.donationId),
                ),
                child: const Text('Coba Lagi'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DonationDetailView extends StatelessWidget {
  final DonationModel donation;
  final File? proofImage;
  final VoidCallback onPickProof;
  final VoidCallback onMarkSent;
  final bool isUpdating;

  const _DonationDetailView({
    required this.donation,
    required this.proofImage,
    required this.onPickProof,
    required this.onMarkSent,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final canMarkSent = donation.status == DonationStatus.pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Donasi'),
        actions: [
          if (donation.status != DonationStatus.verified)
            IconButton(
              icon:    const Icon(Icons.qr_code_2_rounded),
              tooltip: 'QR Code Serah Terima',
              onPressed: () =>
                  context.push(AppRoutes.qrCodePath(donation.id)),
            ),
        ],
      ),
      bottomNavigationBar: canMarkSent
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: BlocBuilder<DonorBloc, DonorState>(
            builder: (context, state) {
              return PrimaryButton(
                label:     'Tandai Sudah Dikirim',
                isLoading: state is DonationDetailLoading,
                icon:      Icons.local_shipping_outlined,
                onPressed: onMarkSent,
              );
            },
          ),
        ),
      )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status Card ──────────────────────────────────────────
            _StatusCard(donation: donation),
            const SizedBox(height: 20),

            // ── Item Info ────────────────────────────────────────────
            _InfoSection(
              title: 'Informasi Item',
              children: [
                _InfoRow(label: 'Nama Item',   value: donation.itemDetail.name),
                _InfoRow(
                  label: 'Jumlah',
                  value: '${donation.itemDetail.qty} ${donation.itemDetail.unit}',
                ),
                _InfoRow(label: 'Tipe',        value: donation.type),
                _InfoRow(
                  label: 'Anonim',
                  value: donation.isAnonymous ? 'Ya' : 'Tidak',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Upload Bukti (pending only) ──────────────────────────
            if (canMarkSent) ...[
              _InfoSection(
                title: 'Bukti Pengiriman (Opsional)',
                children: [
                  if (proofImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        proofImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: onPickProof,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color:        AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file_outlined,
                                color: AppColors.textHint, size: 32),
                            SizedBox(height: 6),
                            Text('Upload foto resi / bukti pengiriman',
                                style: TextStyle(
                                    color: AppColors.textHint, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  if (proofImage != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onPickProof,
                        icon:  const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Ganti Foto'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── Timeline Log ─────────────────────────────────────────
            _StatusTimeline(logs: donation.historyLogs),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final DonationModel donation;
  const _StatusCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final status = donation.status;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        status.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: status.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color:  status.color.withValues(alpha: 0.15),
              shape:  BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, color: status.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Donasi', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                DonationStatusChip(status: status),
                const SizedBox(height: 4),
                if (donation.createdAt != null)
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(donation.createdAt!),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          const Text(' : ',
              style: TextStyle(color: AppColors.textHint)),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final List<DonationHistoryLog> logs;
  const _StatusTimeline({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Status', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics:    const NeverScrollableScrollPhysics(),
          itemCount:  logs.length,
          itemBuilder: (context, i) {
            final log      = logs[i];
            final isLast   = i == logs.length - 1;
            final isLatest = i == 0;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Timeline Indicator ───────────────────────────
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        Container(
                          width:  20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isLatest
                                ? log.status.color
                                : AppColors.border,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isLatest
                                  ? log.status.color
                                  : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: isLatest
                              ? const Icon(Icons.check,
                              size: 11, color: Colors.white)
                              : null,
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: AppColors.border,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ── Log Content ──────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DonationStatusChip(status: log.status),
                          const SizedBox(height: 4),
                          Text(log.note,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm')
                                .format(log.timestamp),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}