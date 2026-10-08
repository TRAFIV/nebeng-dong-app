import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/theme/app_text_styles.dart';
import 'package:praktikum_mobile/routes/app_routes.dart';
import 'package:praktikum_mobile/features/auth/viewmodels/login_view_model.dart';
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
  final _viewModel = LoginViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userName = _viewModel.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (userName != null) _enterHome(userName);
  }

  void _devLogin() {
    // Compile-time guard: never enable this shortcut in profile/release.
    if (!kDebugMode) return;
    final userName = _viewModel.devLogin();
    if (userName != null) _enterHome(userName);
  }

  void _enterHome(String userName) {
    FocusScope.of(context).unfocus();
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: userName,
    );
  }

  void _showRegisterUnavailable() {
    Navigator.pushNamed(context, '/tidak-ada');
  }

  @override
  Widget build(BuildContext context) {
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
                            validator: _viewModel.validateEmail,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Password',
                            hint: 'Ketik password kamu',
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: _viewModel.validatePassword,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(label: 'Gas Masuk!', onPressed: _submit),
                          if (kDebugMode) ...[
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: 'Masuk cepat (Dev)',
                              variant: AppButtonVariant.secondary,
                              onPressed: _devLogin,
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
        // Sementara berupa inisial; diganti gambar logo setelah tersedia.
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.brand,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Text(
            'ND',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.onBrand,
            ),
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
