import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tulis Catatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Catatan',
                hint: 'Tulis catatan untuk tebengan ini',
                controller: _catatanController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    Validators.minLength(value, 5, fieldName: 'Catatan'),
                onFieldSubmitted: (_) => _simpan(),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(label: 'Simpan', onPressed: _simpan),
            ],
          ),
        ),
      ),
    );
  }
}
