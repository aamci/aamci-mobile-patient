import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/appointment_model.dart';

class AppointmentsRemoteDatasource {
  final ApiClient _apiClient;

  AppointmentsRemoteDatasource(this._apiClient);

  Future<List<AppointmentModel>> getAppointments() async {
    final response = await _apiClient.get(ApiEndpoints.appointments);
    final list = response.data as List;
    return list.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AppointmentModel> createAppointment({
    required String doctorId,
    required DateTime slotStart,
    required DateTime slotEnd,
    String? kindId,
    String? notes,
    String? beneficiaryName,
    String? beneficiaryPhone,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.appointments,
      data: {
        'doctorId': doctorId,
        'slotStart': slotStart.toIso8601String(),
        'slotEnd': slotEnd.toIso8601String(),
        if (kindId != null) 'kindId': kindId,
        if (notes != null) 'notes': notes,
        if (beneficiaryName != null && beneficiaryName.isNotEmpty) 'beneficiaryName': beneficiaryName,
        if (beneficiaryPhone != null && beneficiaryPhone.isNotEmpty) 'beneficiaryPhone': beneficiaryPhone,
      },
    );
    return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelAppointment(String id) async {
    await _apiClient.patch(
      ApiEndpoints.appointmentStatus(id),
      data: {'status': 'CANCELLED'},
    );
  }
}
