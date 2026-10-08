import 'package:flutter/material.dart';

import 'package:praktikum_mobile/legacy/driver/data/legacy_driver_repository.dart';
import 'package:praktikum_mobile/shared/models/ride.dart';
import 'package:praktikum_mobile/legacy/driver/routes/legacy_driver_routes.dart';
import 'package:praktikum_mobile/legacy/driver/viewmodels/my_routes_view_model.dart';
import 'package:praktikum_mobile/theme/app_colors.dart';
import 'package:praktikum_mobile/theme/app_spacing.dart';
import 'package:praktikum_mobile/shared/widgets/app_button.dart';
import 'package:praktikum_mobile/shared/widgets/ride_card.dart';
import 'package:praktikum_mobile/shared/widgets/section_header.dart';
import 'package:praktikum_mobile/shared/widgets/state_views.dart';

class MyRoutesScreen extends StatefulWidget {
  const MyRoutesScreen({
    super.key,
    required this.repository,
    required this.userName,
  });
  final LegacyDriverRepository repository;
  final String userName;

  @override
  State<MyRoutesScreen> createState() => _MyRoutesScreenState();
}

class _MyRoutesScreenState extends State<MyRoutesScreen> {
  late final MyRoutesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MyRoutesViewModel(repository: widget.repository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _feedback(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm([Ride? ride]) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final result = await Navigator.pushNamed<Ride>(
      context,
      LegacyDriverRoutes.postRoute,
      arguments: RouteManagementArguments(
        repository: widget.repository,
        userName: widget.userName,
        ride: ride,
      ),
    );
    if (!mounted || result == null) return;
    _feedback(
      ride == null ? 'Rute berhasil diposting' : 'Rute berhasil diperbarui',
    );
  }

  Future<void> _delete(Ride ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus rute ini?'),
        content: Text(
          '${ride.origin} → ${ride.destination}\nRute akan hilang dari pencarian.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _feedback(_viewModel.delete(ride));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => _buildPage(),
    );
  }

  Widget _buildPage() {
    final rides = _viewModel.rides;
    return Scaffold(
      appBar: AppBar(title: const Text('Rute Saya')),
      body: rides.isEmpty
          ? const EmptyView(
              message: 'Belum ada rute kamu. Yuk, bikin rute pertama!',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Beri Tebengan • Rute yang kamu tawarkan'),
                  const SizedBox(height: AppSpacing.md),
                  SectionHeader(
                    title: 'Rute rutin kamu',
                    actionLabel: _viewModel.managing ? 'Selesai' : 'Atur',
                    onAction: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      _viewModel.toggleManaging();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final ride in rides) ...[
                    RideCard(
                      ride: ride,
                      owned: true,
                      onTap: () => _openForm(ride),
                    ),
                    if (_viewModel.managing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _openForm(ride),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () => _delete(ride),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Hapus'),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppButton(label: 'Bikin Rute Baru', onPressed: _openForm),
        ),
      ),
    );
  }
}
