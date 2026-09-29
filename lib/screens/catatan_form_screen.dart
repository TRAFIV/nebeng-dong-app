import 'package:flutter/material.dart';

import '../utils/validators.dart';

// Ditambahkan: halaman untuk menulis dan mengembalikan catatan.
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
    // Lepaskan controller saat halaman ditutup.
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Tutup halaman dan kirim teks catatan ke halaman Detail.
    Navigator.pop<String>(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tulis Catatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
                // Catatan wajib diisi dan minimal 5 karakter.
                validator: (value) =>
                    Validators.minLength(value, 5, fieldName: 'Catatan'),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _simpan, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
