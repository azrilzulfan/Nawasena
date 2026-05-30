import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/inventory_model.dart';
import '../../../data/repositories/donation_repository.dart';
import '../../../data/repositories/inventory_repository.dart';

class DonationDetailScreen extends StatefulWidget {
  final String inventoryId;
  const DonationDetailScreen({super.key, required this.inventoryId});

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  final _donationRepo = DonationRepository();
  final _invRepo = InventoryRepository();

  InventoryModel? _item;
  int _quantity = 1;
  bool _isAnonymous = false;
  String _paymentMethod = 'QRIS';
  final _prayerController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    // Load inventory detail - adapt endpoint as needed
    setState(() => _loading = true);
    try {
      // For now we use a placeholder. Ideally: GET /inventories/{id}
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _proceed() async {
    if (_item == null) return;
    setState(() => _loading = true);
    try {
      final donation = await _donationRepo.createDonation(
        foundationId: _item!.foundationId,
        inventoryId: _item!.id,
        itemName: _item!.itemName,
        qty: _quantity,
        unit: _item!.unit,
        isAnonymous: _isAnonymous,
        prayer: _prayerController.text,
      );
      if (mounted) context.go('/payment/${donation.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat donasi. Coba lagi.')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Donasi'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                        width: 60,
                        height: 60,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.inventory_2_outlined,
                            color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beras Setra Ramos 5kg',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Panti Asuhan Kasih Ibu',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Text('Rp75.000',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quantity
            const Text('Jumlah Bantuan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kuantitas Barang'),
                  Row(
                    children: [
                      _qtyBtn(Icons.remove, () {
                        if (_quantity > 1) setState(() => _quantity--);
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_quantity',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      _qtyBtn(Icons.add, () => setState(() => _quantity++)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Prayer Field
            const Text('Doa & Dukungan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _prayerController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Tuliskan doa untuk anak-anak panti asuhan atau tinggalkan kosong...',
                hintStyle:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 16),

            // Anonymous Toggle
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _isAnonymous = v ?? false),
                ),
                const Text('Sembunyikan nama saya (Anonim)'),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Methods
            const Text('Metode Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _paymentOption('QRIS', 'QRIS (OVO, GoPay, Dana)'),
            const SizedBox(height: 8),
            _paymentOption('VA', 'BCA Virtual Account'),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Donasi',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text('Rp${75000 * _quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Lanjutkan Pembayaran',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );

  Widget _paymentOption(String value, String label) => GestureDetector(
        onTap: () => setState(() => _paymentMethod = value),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _paymentMethod == value
                  ? AppColors.primary
                  : AppColors.border,
              width: _paymentMethod == value ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  child: Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
              if (_paymentMethod == value)
                const Icon(Icons.check_circle,
                    color: AppColors.primary, size: 20),
            ],
          ),
        ),
      );
}