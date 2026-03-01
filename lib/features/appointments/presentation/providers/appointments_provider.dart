import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/appointments_remote_datasource.dart';
import '../../data/models/appointment_model.dart';

final appointmentsRemoteProvider = Provider<AppointmentsRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppointmentsRemoteDatasource(apiClient);
});

class AppointmentsState {
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final String? error;

  const AppointmentsState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
  });

  List<AppointmentModel> get upcoming =>
      appointments.where((a) => a.isUpcoming).toList()
        ..sort((a, b) => (a.slot?.start ?? a.createdAt).compareTo(b.slot?.start ?? b.createdAt));

  List<AppointmentModel> get past =>
      appointments.where((a) => !a.isUpcoming).toList()
        ..sort((a, b) => (b.slot?.start ?? b.createdAt).compareTo(a.slot?.start ?? a.createdAt));
}

class AppointmentsNotifier extends StateNotifier<AppointmentsState> {
  final AppointmentsRemoteDatasource _datasource;

  AppointmentsNotifier(this._datasource) : super(const AppointmentsState());

  Future<void> load() async {
    state = AppointmentsState(isLoading: true, appointments: state.appointments);
    try {
      final appointments = await _datasource.getAppointments();
      state = AppointmentsState(appointments: appointments);
    } catch (e) {
      state = AppointmentsState(
        appointments: state.appointments,
        error: 'Erreur lors du chargement',
      );
    }
  }

  Future<bool> book({
    required String doctorId,
    required DateTime slotStart,
    required DateTime slotEnd,
    String? kindId,
    String? notes,
    String? beneficiaryName,
    String? beneficiaryPhone,
  }) async {
    try {
      await _datasource.createAppointment(
        doctorId: doctorId,
        slotStart: slotStart,
        slotEnd: slotEnd,
        kindId: kindId,
        notes: notes,
        beneficiaryName: beneficiaryName,
        beneficiaryPhone: beneficiaryPhone,
      );
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel(String id) async {
    try {
      await _datasource.cancelAppointment(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, AppointmentsState>((ref) {
  final datasource = ref.watch(appointmentsRemoteProvider);
  return AppointmentsNotifier(datasource);
});
