import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/donation_repository.dart';

class PaymentScreen extends StatefulWidget {
  final String donationId;
  const PaymentScreen({super.key, required this.donationId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _repo = DonationRepository();
  Timer? _timer;
  Timer? _pollTimer;
  int _seconds = 15 * 60; // 15 minutes
  String? _qrData;
  bool _loadingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadQr();
    _startTimer();
  }

  Future<void> _loadQr() async {
    try {
      final data = await _repo.getQrCode(widget.donationId);
      setState(() => _qrData = data['qr_code_hash']);
    } catch (_) {}
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds <= 0) {
        _timer?.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _checkStatus() async {
    setState(() => _loadingStatus = true);
    try {
      final donation = await _repo.getDonationDetail(widget.donationId);
      if (donation.status != 'pending') {
        if (mounted) context.go('/success/${widget.donationId}');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembayaran belum terkonfirmasi. Silakan tunggu.'),
            ),
          );
        }
      }
    } finally {
      setState(() => _loadingStatus = false);
    }
  }

  String get _timerLabel {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Selesaikan pembayaran dalam',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(
              _timerLabel,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _seconds < 60 ? AppColors.urgentRed : AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('QRIS Payment',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_qrData != null)
                    QrImageView(
                      data: _qrData!,
                      size: 200,
                      backgroundColor: Colors.white,
                    )
                  else
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  const SizedBox(height: 16),
                  Text('Total Tagihan',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const Text('Rp150.000',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: 'GoPay',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: ['GoPay', 'OVO', 'Dana', 'QRIS Lainnya']
                        .map((m) => DropdownMenuItem(
                            value: m, child: Text(m)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loadingStatus ? null : _checkStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loadingStatus
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cek Status Pembayaran',
                        style:
                            TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Batalkan Transaksi',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}