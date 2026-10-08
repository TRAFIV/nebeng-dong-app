import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Form catatan untuk pengemudi. Menutup layar sambil mengirim teks catatan
/// ke layar sebelumnya lewat `Navigator.pop`.
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Tutup layar ini sambil MEMBAWA teks catatan ke layar sebelumnya
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tulis Catatan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Catatan buat pengemudi',
                  hint: 'Contoh: Aku bawa helm sendiri, ya',
                  controller: _catatanController,
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      Validators.minLength(value, 5, fieldName: 'Catatan'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(label: 'Simpan', onPressed: _simpan),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
