import 'package:flutter/material.dart';

import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/features/booking/viewmodels/catatan_form_view_model.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/app_text_field.dart';

class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();
  final _viewModel = CatatanFormViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final result = _viewModel.save(_catatanController.text);
    if (result != null) Navigator.pop(context, result);
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
                validator: _viewModel.validate,
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
