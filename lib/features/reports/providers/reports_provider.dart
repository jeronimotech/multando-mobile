import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multando_sdk/multando_sdk.dart';

import '../../../core/api_client.dart';

/// State for the reports list screen.
class ReportsState {
  const ReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  final List<ReportSummary> reports;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  ReportsState copyWith({
    List<ReportSummary>? reports,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ReportsNotifier extends Notifier<ReportsState> {
  @override
  ReportsState build() {
    loadReports();
    return const ReportsState(isLoading: true);
  }

  Future<void> loadReports({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = ref.read(apiClientProvider);
      if (!client.isInitialized || !client.isAuthenticated) {
        state = const ReportsState();
        return;
      }

      final result = await client.reports.list(page: 1, pageSize: 20);
      state = ReportsState(
        reports: result.items,
        currentPage: result.page,
        totalPages: result.totalPages,
        hasMore: result.page < result.totalPages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);

    try {
      final client = ref.read(apiClientProvider);
      final nextPage = state.currentPage + 1;
      final result = await client.reports.list(page: nextPage, pageSize: 20);
      state = state.copyWith(
        reports: [...state.reports, ...result.items],
        currentPage: result.page,
        totalPages: result.totalPages,
        hasMore: result.page < result.totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reportsProvider =
    NotifierProvider<ReportsNotifier, ReportsState>(ReportsNotifier.new);

/// Provider for a single report detail.
final reportDetailProvider =
    FutureProvider.family.autoDispose<ReportDetail, String>((ref, id) async {
  final client = ref.watch(apiClientProvider);
  return client.reports.getById(id);
});

/// Provider for the infraction catalogue.
final infractionsProvider = FutureProvider.autoDispose((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.infractions.list();
});

/// State for the new report wizard.
class NewReportState {
  const NewReportState({
    this.step = 0,
    this.capturedImagePath,
    this.selectedInfractionId,
    this.plateNumber = '',
    this.vehicleTypeId,
    this.description = '',
    this.latitude,
    this.longitude,
    this.address,
    this.isSubmitting = false,
    this.error,
  });

  final int step;
  final String? capturedImagePath;
  final String? selectedInfractionId;
  final String plateNumber;
  final String? vehicleTypeId;
  final String description;
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool isSubmitting;
  final String? error;

  NewReportState copyWith({
    int? step,
    String? capturedImagePath,
    String? selectedInfractionId,
    String? plateNumber,
    String? vehicleTypeId,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    bool? isSubmitting,
    String? error,
  }) {
    return NewReportState(
      step: step ?? this.step,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      selectedInfractionId: selectedInfractionId ?? this.selectedInfractionId,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class NewReportNotifier extends Notifier<NewReportState> {
  @override
  NewReportState build() => const NewReportState();

  void setStep(int step) => state = state.copyWith(step: step);
  void setCapturedImage(String path) =>
      state = state.copyWith(capturedImagePath: path);
  void setInfraction(String id) =>
      state = state.copyWith(selectedInfractionId: id);
  void setPlateNumber(String plate) =>
      state = state.copyWith(plateNumber: plate);
  void setVehicleType(String id) =>
      state = state.copyWith(vehicleTypeId: id);
  void setDescription(String desc) =>
      state = state.copyWith(description: desc);
  void setLocation(double lat, double lng, String? address) =>
      state = state.copyWith(latitude: lat, longitude: lng, address: address);

  Future<ReportDetail?> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final client = ref.read(apiClientProvider);
      final report = ReportCreate(
        infractionId: state.selectedInfractionId!,
        plateNumber: state.plateNumber,
        location: LocationData(
          latitude: state.latitude!,
          longitude: state.longitude!,
          address: state.address,
        ),
        vehicleTypeId: state.vehicleTypeId,
        description: state.description.isEmpty ? null : state.description,
        occurredAt: DateTime.now(),
        source: ReportSource.mobileApp,
      );

      final result = await client.reports.create(report);

      // Refresh reports list
      ref.read(reportsProvider.notifier).loadReports(refresh: true);

      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  void reset() => state = const NewReportState();
}

final newReportProvider =
    NotifierProvider<NewReportNotifier, NewReportState>(NewReportNotifier.new);
