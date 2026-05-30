import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/foundation_model.dart';
import '../../../data/repositories/foundation_repository.dart';

class FoundationDetailScreen extends StatefulWidget {
  final String id;
  const FoundationDetailScreen({super.key, required this.id});

  @override
  State<FoundationDetailScreen> createState() => _FoundationDetailScreenState();
}

class _FoundationDetailScreenState extends State<FoundationDetailScreen> {
  final _repo = FoundationRepository();
  FoundationModel? _foundation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await _repo.getFoundationDetail(widget.id);
      setState(() => _foundation = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_foundation == null) {
      return const Scaffold(body: Center(child: Text('Panti tidak ditemukan')));
    }

    final f = _foundation!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Image Header (SliverAppBar)
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: f.verificationDocs.isNotEmpty
                  ? Image.network(f.verificationDocs.first, fit: BoxFit.cover)
                  : Container(color: AppColors.primaryLight),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (f.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Terverifikasi Resmi',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(height: 8),
                  Text(f.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(f.description,
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _StatBadge('40', 'PENGHUNI'),
                      _StatBadge('5', 'PENGASUH'),
                      _StatBadge('1998', 'DIDIRIKAN'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text('Lokasi & Kontak',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Google Maps
                  if (f.latitude != null && f.longitude != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 180,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(f.latitude!, f.longitude!),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('foundation'),
                              position: LatLng(f.latitude!, f.longitude!),
                            )
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  Text(f.address,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      if (f.latitude != null) {
                        launchUrl(Uri.parse(
                            'https://maps.google.com/?q=${f.latitude},${f.longitude}'));
                      }
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Buka di Google Maps'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {}, // TODO: navigate to list inventories for this foundation
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Donasi Sekarang',
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value, label;
  const _StatBadge(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      );
}