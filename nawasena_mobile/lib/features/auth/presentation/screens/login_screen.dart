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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _emailController  = TextEditingController();
  final _passController   = TextEditingController();
  bool _obscurePass       = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      LoginRequested(
        email:    _emailController.text.trim(),
        password: _passController.text,
      ),
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
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
                  const SizedBox(height: 56),

                  // ── Logo ────────────────────────────────────────────
                  const Center(child: NawasenaLogo(size: 72)),
                  const SizedBox(height: 48),

                  // ── Header ──────────────────────────────────────────
                  Text('Selamat Datang', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Masuk untuk melanjutkan misi sosial Anda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 36),

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
                    controller: _passController,
                    label:      'Password',
                    hint:       'Minimal 8 karakter',
                    obscureText: _obscurePass,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    validator:  Validators.password,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit ───────────────────────────────────────────
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        label:     'Masuk',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Divider ──────────────────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'atau',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Register Link ────────────────────────────────────
                  OutlinedButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text('Daftar Akun Baru'),
                  ),
                  const SizedBox(height: 32),

                  // ── Footer ───────────────────────────────────────────
                  Center(
                    child: Text(
                      'Nawasena © 2026 — Platform Panti Asuhan Digital',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}