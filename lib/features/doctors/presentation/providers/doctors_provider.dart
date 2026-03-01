import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/doctors_remote_datasource.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/slot_model.dart';
import '../../data/models/appointment_kind_model.dart';

final doctorsRemoteProvider = Provider<DoctorsRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DoctorsRemoteDatasource(apiClient);
});

class DoctorSearchState {
  final List<DoctorModel> doctors;
  final bool isLoading;
  final String? error;

  const DoctorSearchState({
    this.doctors = const [],
    this.isLoading = false,
    this.error,
  });

  DoctorSearchState copyWith({
    List<DoctorModel>? doctors,
    bool? isLoading,
    String? error,
  }) {
    return DoctorSearchState(
      doctors: doctors ?? this.doctors,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DoctorSearchNotifier extends StateNotifier<DoctorSearchState> {
  final DoctorsRemoteDatasource _datasource;

  DoctorSearchNotifier(this._datasource) : super(const DoctorSearchState());

  Future<void> search({String? query, String? city, String? specialty}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final doctors = await _datasource.searchDoctors(
        query: query,
        city: city,
        specialty: specialty,
      );
      state = state.copyWith(doctors: doctors, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la recherche',
      );
    }
  }

  Future<void> loadAll() async {
    await search();
  }
}

final doctorSearchProvider =
    StateNotifierProvider<DoctorSearchNotifier, DoctorSearchState>((ref) {
  final datasource = ref.watch(doctorsRemoteProvider);
  return DoctorSearchNotifier(datasource);
});

final doctorSlotsProvider =
    FutureProvider.family<List<SlotModel>, String>((ref, doctorId) async {
  final datasource = ref.watch(doctorsRemoteProvider);
  return datasource.getAvailableSlots(doctorId);
});

final doctorKindsProvider =
    FutureProvider.family<List<AppointmentKindModel>, String>((ref, doctorId) async {
  final datasource = ref.watch(doctorsRemoteProvider);
  return datasource.getAppointmentKinds(doctorId);
});
