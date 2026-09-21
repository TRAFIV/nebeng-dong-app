import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

/// Domain email kampus yang diizinkan (FR-17).
/// Asumsi: Universitas Andalas, termasuk subdomain seperti student.unand.ac.id.
const campusEmailDomain = 'unand.ac.id';

final _campusEmailPattern = RegExp(
  '^[^@\\s]+@([a-z0-9-]+\\.)*${RegExp.escape(campusEmailDomain)}\$',
  caseSensitive: false,
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email kampusnya diisi dulu, ya';
    if (!_campusEmailPattern.hasMatch(email)) {
      return 'Pakai email kampus ($campusEmailDomain), ya!';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password-nya jangan dikosongin, dong';
    }
    return null;
  }

  /// "mikail.samyth@student.unand.ac.id" → "Mikail".
  String _displayNameFromEmail(String email) {
    final firstPart = email.split('@').first.split('.').first;
    if (firstPart.isEmpty) return 'Kamu';
    return firstPart[0].toUpperCase() + firstPart.substring(1);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Backend (REST API) belum tersedia, jadi login langsung menuju Home.
    final userName = _displayNameFromEmail(_emailController.text.trim());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => HomeScreen(userName: userName)),
    );
  }

  void _showRegisterUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur daftar lagi disiapin. Sabar, ya!')),
    );
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
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Password',
                            hint: 'Ketik password kamu',
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(label: 'Gas Masuk!', onPressed: _submit),
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
