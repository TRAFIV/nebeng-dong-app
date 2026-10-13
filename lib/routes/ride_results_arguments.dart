import 'package:praktikum_mobile/features/ride_search/data/ride_repository.dart';
import 'package:praktikum_mobile/features/ride_search/models/ride_search_request.dart';

/// Route-only dependencies. The domain search request contains no UI/service.
class RideResultsArguments {
  const RideResultsArguments({
    required this.request,
    this.repository,
    this.simulateError = false,
  });
  final RideSearchRequest request;
  final RideRepository? repository;
  final bool simulateError;
}
