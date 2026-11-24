import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/core/di/auth_repository_scope.dart';
import 'package:praktikum_mobile/features/auth/data/auth_repository.dart';
import 'package:praktikum_mobile/features/auth/models/auth_user.dart';
import 'package:praktikum_mobile/features/auth/viewmodels/login_view_model.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginViewModel? _viewModel;

  LoginViewModel get _vm => _viewModel!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) return;
    _viewModel = LoginViewModel(
      repository:
          AuthRepositoryScope.maybeOf(context) ?? const LocalAuthRepository(),
    );
    // Token tersimpan masih berlaku: langsung masuk tanpa mengetik lagi.
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final user = await _vm.restoreSession();
    if (mounted && user != null) _enterHome(user);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = await _vm.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted && user != null) _enterHome(user);
  }

  Future<void> _devLogin() async {
    // Compile-time guard: never enable this shortcut in profile/release.
    if (!kDebugMode) return;
    final user = await _vm.devLogin();
    if (mounted && user != null) _enterHome(user);
  }

  void _enterHome(AuthUser user) {
    FocusScope.of(context).unfocus();
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: user.firstName,
    );
  }

  void _showRegisterUnavailable() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Pendaftaran belum dibuka. Akunmu dibuatkan admin dulu, ya.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) => _buildPage(context),
  );

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight = (constraints.maxHeight - AppSpacing.lg * 2).clamp(
              0.0,
              double.infinity,
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _LoginHeader(),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            label: 'Email kampus kamu',
                            hint: 'nama@student.unand.ac.id',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _vm.validateEmail,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Password',
                            hint: 'Ketik password kamu',
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: _vm.validatePassword,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_vm.errorMessage != null) ...[
                            ErrorBanner(message: _vm.errorMessage!),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          AppButton(
                            label: _vm.restoring
                                ? 'Memeriksa sesi…'
                                : _vm.submitting
                                ? 'Lagi masuk…'
                                : 'Gas Masuk!',
                            onPressed: _vm.busy ? null : _submit,
                          ),
                          if (kDebugMode) ...[
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: 'Masuk cepat (Dev)',
                              variant: AppButtonVariant.secondary,
                              onPressed: _vm.busy ? null : _devLogin,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: _showRegisterUnavailable,
                                child: const Text('Daftar dulu, yuk'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Simbol logo "ND" putih di kotak brand, sama dengan ikon aplikasi.
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.brand,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Image.asset(
            'assets/images/logo_mark.png',
            width: 40,
            semanticLabel: 'Logo Nebeng Dong',
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Nebeng Dong',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Searah ke kampus? Nebeng aja, ongkos jadi ringan!',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
