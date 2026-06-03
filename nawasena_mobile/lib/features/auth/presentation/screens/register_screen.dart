import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nawasena_mobile/core/router/app_router.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/theme/app_text_styles.dart';
import 'package:nawasena_mobile/core/utils/validators.dart';
import 'package:nawasena_mobile/core/widgets/app_snackbar.dart';
import 'package:nawasena_mobile/core/widgets/app_text_field.dart';
import 'package:nawasena_mobile/core/widgets/nawasena_logo.dart';
import 'package:nawasena_mobile/core/widgets/primary_button.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:nawasena_mobile/features/auth/presentation/bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  final _passController  = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'donor';

  static const List<({String value, String label, String description, IconData icon})>
  _roles = [
    (
    value:       'donor',
    label:       'Donor',
    description: 'Donasikan barang & kebutuhan ke panti',
    icon:        Icons.volunteer_activism_outlined,
    ),
    (
    value:       'volunteer',
    label:       'Relawan',
    description: 'Ikuti kegiatan sosial & workshop panti',
    icon:        Icons.people_outline_rounded,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      RegisterRequested(
        fullName:             _nameController.text.trim(),
        email:                _emailController.text.trim(),
        password:             _passController.text,
        passwordConfirmation: _confirmController.text,
        role:                 _selectedRole,
      ),
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      AppSnackBar.show(
        context,
        message: 'Selamat datang, ${state.user.fullName}!',
        type: SnackBarType.success,
      );
      final dest = state.user.role == 'volunteer'
          ? AppRoutes.volunteerDashboard
          : AppRoutes.donorHome;
      context.go(dest);
    } else if (state is AuthFailure) {
      AppSnackBar.show(context, message: state.message, type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // ── Back + Logo ──────────────────────────────────────
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      const NawasenaLogo(size: 40),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Text('Buat Akun Baru', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Bergabunglah dan mulai membuat dampak nyata.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // ── Nama Lengkap ─────────────────────────────────────
                  AppTextField(
                    controller:  _nameController,
                    label:       'Nama Lengkap',
                    hint:        'Nama sesuai identitas',
                    prefixIcon:  const Icon(Icons.person_outline_rounded),
                    validator:   Validators.fullName,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // ── Email ────────────────────────────────────────────
                  AppTextField(
                    controller:   _emailController,
                    label:        'Email',
                    hint:         'nama@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon:   const Icon(Icons.email_outlined),
                    validator:    Validators.email,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // ── Password ─────────────────────────────────────────
                  AppTextField(
                    controller:  _passController,
                    label:       'Password',
                    hint:        'Minimal 8 karakter',
                    obscureText: _obscurePass,
                    prefixIcon:  const Icon(Icons.lock_outline_rounded),
                    validator:   Validators.password,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Konfirmasi Password ──────────────────────────────
                  AppTextField(
                    controller:  _confirmController,
                    label:       'Konfirmasi Password',
                    hint:        'Ulangi password Anda',
                    obscureText: _obscureConfirm,
                    prefixIcon:  const Icon(Icons.lock_outline_rounded),
                    textInputAction: TextInputAction.done,
                    validator: (v) =>
                        Validators.confirmPassword(v, _passController.text),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Pilih Role ───────────────────────────────────────
                  Text(
                    'Saya bergabung sebagai:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ..._roles.map((role) => _RoleTile(
                    role:       role,
                    isSelected: _selectedRole == role.value,
                    onTap:      () => setState(() => _selectedRole = role.value),
                  )),
                  const SizedBox(height: 32),

                  // ── Submit ───────────────────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        label:     'Daftar Sekarang',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Login Link ───────────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Sudah punya akun? ',
                          style: AppTextStyles.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Masuk',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role Selection Tile ─────────────────────────────────────────────────────
class _RoleTile extends StatelessWidget {
  final ({String value, String label, String description, IconData icon}) role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                role.icon,
                color: isSelected ? Colors.white : AppColors.textHint,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role.label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(role.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}