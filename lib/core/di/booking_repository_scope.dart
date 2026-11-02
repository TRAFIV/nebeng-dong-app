import 'package:flutter/material.dart';
import 'package:praktikum_mobile/features/booking/data/booking_repository.dart';
import 'package:praktikum_mobile/features/booking/data/local_booking_repository.dart';

/// Provider siklus hidup BookingRepository di level root aplikasi.
class BookingRepositoryProvider extends StatefulWidget {
  const BookingRepositoryProvider({
    super.key,
    this.repository,
    required this.child,
  });

  final BookingRepository? repository;
  final Widget child;

  @override
  State<BookingRepositoryProvider> createState() =>
      _BookingRepositoryProviderState();
}

class _BookingRepositoryProviderState extends State<BookingRepositoryProvider> {
  late BookingRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalBookingRepository();
  }

  @override
  void didUpdateWidget(BookingRepositoryProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      if (oldWidget.repository == null) _repository.dispose();
      _repository = widget.repository ?? LocalBookingRepository();
    }
  }

  @override
  void dispose() {
    if (widget.repository == null) _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BookingRepositoryScope(repository: _repository, child: widget.child);
}

class BookingRepositoryScope extends InheritedWidget {
  const BookingRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final BookingRepository repository;

  static BookingRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<BookingRepositoryScope>()
      ?.repository;

  static BookingRepository of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'BookingRepositoryScope tidak ditemukan di konteks');
    return scope!;
  }

  @override
  bool updateShouldNotify(BookingRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
