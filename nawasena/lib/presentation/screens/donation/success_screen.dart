import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/donation_repository.dart';
import '../../../data/models/donation_model.dart';

class SuccessScreen extends StatefulWidget {
  final String donationId;
  const SuccessScreen({super.key, required this.donationId});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  final _repo = DonationRepository();
  DonationModel? _donation;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(
        parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
    _loadDonation();
  }

  Future<void> _loadDonation() async {
    try {
      final d = await _repo.getDonationDetail(widget.donationId);
      setState(() => _donation = d);
    } catch (_) {}
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df =
        DateFormat('d MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Check
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Alhamdulillah!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Pembayaran berhasil diterima. Bantuan Anda segera diproses untuk dikirimkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85), height: 1.5),
              ),
              const SizedBox(height: 24),

              // Receipt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('BUKTI TRANSAKSI',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2)),
                    ),
                    const Divider(height: 20),
                    _receiptRow('No. Referensi',
                        _donation?.referenceNumber ?? '—'),
                    _receiptRow('Waktu',
                        _donation?.createdAt != null
                            ? df.format(_donation!.createdAt!)
                            : '—'),
                    _receiptRow(
                        'Bantuan',
                        _donation != null
                            ? '${_donation!.itemQty}x ${_donation!.itemName}'
                            : '—'),
                    _receiptRow('Penerima',
                        _donation?.foundationId ?? '—'),
                    const Divider(height: 20),
                    _receiptRow('Total', 'Rp150.000',
                        bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {}, // TODO: Navigate to timeline
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lihat Lini Masa Pengiriman',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text(value,
                style: TextStyle(
                    fontWeight:
                        bold ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13)),
          ],
        ),
      );
}