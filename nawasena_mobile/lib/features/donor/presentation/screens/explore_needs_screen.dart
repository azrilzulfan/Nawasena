import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';
import 'package:nawasena_mobile/features/donor/presentation/widgets/inventory_card.dart';

class ExploreNeedsScreen extends StatefulWidget {
  const ExploreNeedsScreen({super.key});

  @override
  State<ExploreNeedsScreen> createState() => _ExploreNeedsScreenState();
}

class _ExploreNeedsScreenState extends State<ExploreNeedsScreen> {
  String? _selectedCategory;
  String? _selectedUrgency;

  static const List<({String? value, String label})> _categories = [
    (value: null,         label: 'Semua'),
    (value: 'Logistik',   label: 'Logistik'),
    (value: 'Edukasi',    label: 'Edukasi'),
    (value: 'Medis',      label: 'Medis'),
  ];

  static const List<({String? value, String label})> _urgencies = [
    (value: null,     label: 'Semua'),
    (value: 'high',   label: 'Mendesak'),
    (value: 'medium', label: 'Sedang'),
    (value: 'low',    label: 'Rendah'),
  ];

  @override
  void initState() {
    super.initState();
    _loadInventories();
  }

  void _loadInventories() {
    context.read<DonorBloc>().add(
      LoadGlobalInventories(
        category:    _selectedCategory,
        urgentLevel: _selectedUrgency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jelajahi Kebutuhan')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter Bar ────────────────────────────────────────────
          _FilterSection(
            categories:      _categories,
            urgencies:       _urgencies,
            selectedCategory: _selectedCategory,
            selectedUrgency:  _selectedUrgency,
            onCategoryChanged: (v) {
              setState(() => _selectedCategory = v);
              _loadInventories();
            },
            onUrgencyChanged: (v) {
              setState(() => _selectedUrgency = v);
              _loadInventories();
            },
          ),

          // ── Inventory List ────────────────────────────────────────
          Expanded(
            child: BlocConsumer<DonorBloc, DonorState>(
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
                if (state is GlobalInventoriesLoading) {
                  return const Center(child: AppLoadingIndicator(size: 40));
                }
                if (state is GlobalInventoriesLoaded) {
                  return _InventoryListView(
                    inventories: state.inventories,
                    onRefresh:   _loadInventories,
                  );
                }
                return const Center(
                  child: Text(
                    'Pilih filter untuk mulai menjelajah.',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final List<({String? value, String label})> categories;
  final List<({String? value, String label})> urgencies;
  final String? selectedCategory;
  final String? selectedUrgency;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onUrgencyChanged;

  const _FilterSection({
    required this.categories,
    required this.urgencies,
    required this.selectedCategory,
    required this.selectedUrgency,
    required this.onCategoryChanged,
    required this.onUrgencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chips
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding:         const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount:       categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = categories[i];
              final selected = selectedCategory == cat.value;
              return _FilterChip(
                label:      cat.label,
                isSelected: selected,
                onTap:      () => onCategoryChanged(cat.value),
              );
            },
          ),
        ),

        // Urgency chips
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Text('Urgensi', style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding:         const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount:       urgencies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final urg = urgencies[i];
              final selected = selectedUrgency == urg.value;
              return _FilterChip(
                label:      urg.label,
                isSelected: selected,
                onTap:      () => onUrgencyChanged(urg.value),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color:        isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color:      isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _InventoryListView extends StatelessWidget {
  final List<InventoryModel> inventories;
  final VoidCallback onRefresh;

  const _InventoryListView({
    required this.inventories,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (inventories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 56, color: AppColors.textHint),
            const SizedBox(height: 14),
            const Text('Tidak ada item ditemukan.'),
            const SizedBox(height: 12),
            TextButton(onPressed: onRefresh, child: const Text('Muat Ulang')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: ListView.separated(
        padding:     const EdgeInsets.all(20),
        itemCount:   inventories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final inv = inventories[i];
          return InventoryCard(
            inventory:        inv,
            showFoundationId: true,
            onTap: () => context.push(AppRoutes.itemDetailPath(inv.id)),
          );
        },
      ),
    );
  }
}