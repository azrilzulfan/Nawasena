import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/utils/validators.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/core/widgets/app_text_field.dart';
import 'package:nawasena_mobile/core/widgets/primary_button.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';

class DonationPledgeScreen extends StatefulWidget {
  final String inventoryId;
  final String foundationId;

  const DonationPledgeScreen({
    super.key,
    required this.inventoryId,
    required this.foundationId,
  });

  @override
  State<DonationPledgeScreen> createState() => _DonationPledgeScreenState();
}

class _DonationPledgeScreenState extends State<DonationPledgeScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _qtyController  = TextEditingController();
  final _noteController = TextEditingController();

  bool _isAnonymous = false;
  String _itemName  = '';
  String _itemUnit  = '';

  @override
  void initState() {
    super.initState();
    // Ambil info item dari state DonorBloc yang masih tersimpan
    final state = context.read<DonorBloc>().state;
    if (state is InventoryDetailLoaded) {
      _itemName = state.inventory.itemName;
      _itemUnit = state.inventory.unit;
      _qtyController.text = state.inventory.remainingQty.toString();
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<DonorBloc>().add(
      SubmitDonationPledge(
        foundationId: widget.foundationId,
        inventoryId:  widget.inventoryId,
        itemName:     _itemName,
        qty:          int.parse(_qtyController.text.trim()),
        unit:         _itemUnit,
        isAnonymous:  _isAnonymous,
      ),
    );
  }

  void _handleState(BuildContext context, DonorState state) {
    if (state is DonationPledgeSuccess) {
      AppSnackBar.show(
        context,
        message: 'Donasi berhasil diajukan!',
        type:    SnackBarType.success,
      );
      context.pushReplacement(
        AppRoutes.donationDetailPath(state.donation.id),
      );
    } else if (state is DonorError) {
      AppSnackBar.show(context, message: state.message, type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<DonorBloc, DonorState>(
      listener: _handleState,
      child: Scaffold(
        appBar: AppBar(title: const Text('Form Donasi')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Info Header ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          color: AppColors.primaryDark, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Item yang Didonasikan',
                                style: theme.textTheme.bodySmall),
                            Text(
                              _itemName.isNotEmpty ? _itemName : 'Item Kebutuhan',
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Jumlah ───────────────────────────────────────────
                Text('Jumlah Donasi', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  _itemUnit.isNotEmpty
                      ? 'Satuan: $_itemUnit'
                      : 'Masukkan jumlah yang ingin Anda donasikan.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:   _qtyController,
                  label:        'Jumlah (${_itemUnit.isNotEmpty ? _itemUnit : "unit"})',
                  keyboardType: TextInputType.number,
                  prefixIcon:   const Icon(Icons.numbers_rounded),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator:    (v) => Validators.positiveInteger(v, fieldName: 'Jumlah'),
                ),
                const SizedBox(height: 28),

                // ── Catatan ──────────────────────────────────────────
                Text('Catatan (Opsional)', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                AppTextField(
                  controller:  _noteController,
                  label:       'Pesan untuk panti...',
                  maxLines:    3,
                  prefixIcon:  const Icon(Icons.notes_outlined),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),

                // ── Anonim Toggle ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color:        AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border:       Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_off_outlined,
                          color: AppColors.textHint, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Donasi Anonim', style: theme.textTheme.titleMedium),
                            Text(
                              'Nama Anda tidak akan ditampilkan di portofolio publik.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value:    _isAnonymous,
                        onChanged: (v) => setState(() => _isAnonymous = v),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Disclaimer ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:        AppColors.infoLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.info, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Setelah mengajukan donasi, Anda perlu mengirimkan barang secara fisik ke panti dan mengupdate status pengiriman.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Submit ───────────────────────────────────────────
                BlocBuilder<DonorBloc, DonorState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      label:     'Ajukan Donasi',
                      isLoading: state is DonationPledgeLoading,
                      icon:      Icons.send_outlined,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}