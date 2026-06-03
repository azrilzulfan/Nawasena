import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/utils/validators.dart';
import 'package:nawasena_mobile/core/widgets/app_loading_indicator.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/core/widgets/app_text_field.dart';
import 'package:nawasena_mobile/core/widgets/primary_button.dart';
import 'package:nawasena_mobile/features/auth/data/models/user_model.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:nawasena_mobile/features/profile/presentation/bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _nameController  = TextEditingController();
  final _skillController = TextEditingController();

  UserModel?  _currentUser;
  File?       _pickedImage;
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      _currentUser = auth.user;
      _nameController.text = auth.user.fullName;
      _skills = List.from(auth.user.volunteerProfile?.skills ?? []);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title:   const Text('Ambil Foto'),
                onTap:   () async {
                  Navigator.pop(ctx);
                  final f = await picker.pickImage(
                    source:   ImageSource.camera,
                    imageQuality: 75,
                  );
                  if (f != null) setState(() => _pickedImage = File(f.path));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title:   const Text('Pilih dari Galeri'),
                onTap:   () async {
                  Navigator.pop(ctx);
                  final f = await picker.pickImage(
                    source:   ImageSource.gallery,
                    imageQuality: 75,
                  );
                  if (f != null) setState(() => _pickedImage = File(f.path));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() => _skills.add(skill));
    _skillController.clear();
  }

  void _removeSkill(String skill) => setState(() => _skills.remove(skill));

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
      UpdateProfile(
        fullName:        _nameController.text.trim(),
        avatarImagePath: _pickedImage?.path,
        skills:          _currentUser?.isVolunteer ?? false ? _skills : null,
      ),
    );
  }

  void _handleState(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      AppSnackBar.show(
        context,
        message: 'Profil berhasil diperbarui!',
        type:    SnackBarType.success,
      );
      context.pop();
    } else if (state is ProfileError) {
      AppSnackBar.show(context, message: state.message, type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: _handleState,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profil')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Avatar Picker ──────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 3),
                          ),
                          child: ClipOval(
                            child: _pickedImage != null
                                ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                : (_currentUser?.avatarUrl != null
                                ? CachedNetworkImage(
                              imageUrl: _currentUser!.avatarUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                              const AppLoadingIndicator(),
                              errorWidget: (_, _, _) =>
                                  _avatarPlaceholder(),
                            )
                                : _avatarPlaceholder()),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _pickImage,
                    child: const Text('Ganti Foto Profil'),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Nama ───────────────────────────────────────────
                Text('Nama Lengkap', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                AppTextField(
                  controller:  _nameController,
                  label:       'Nama Lengkap',
                  prefixIcon:  const Icon(Icons.person_outline_rounded),
                  validator:   Validators.fullName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 28),

                // ── Skills (Volunteer Only) ────────────────────────
                if (_currentUser?.isVolunteer ?? false) ...[
                  Text('Keahlian / Skill', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Tambahkan keahlian yang Anda miliki sebagai relawan.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),

                  // Skill Input Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller:  _skillController,
                          label:       'Contoh: Mengajar, Medis, IT...',
                          prefixIcon:  const Icon(Icons.add_circle_outline),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onChanged:  (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 52,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _skillController.text.trim().isNotEmpty
                              ? _addSkill
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(52, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Icon(Icons.add, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Skill Chips
                  if (_skills.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills
                          .map(
                            (skill) => Chip(
                          label: Text(skill),
                          onDeleted: () => _removeSkill(skill),
                          deleteIconColor: AppColors.primaryDark,
                        ),
                      )
                          .toList(),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:         AppColors.surfaceVariant,
                        borderRadius:  BorderRadius.circular(12),
                        border:        Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Belum ada skill yang ditambahkan.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 28),
                ],

                // ── Submit ────────────────────────────────────────
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      label:     'Simpan Perubahan',
                      isLoading: state is ProfileLoading,
                      icon:      Icons.save_outlined,
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

  Widget _avatarPlaceholder() {
    final name = _currentUser?.fullName ?? '?';
    final initials = name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}