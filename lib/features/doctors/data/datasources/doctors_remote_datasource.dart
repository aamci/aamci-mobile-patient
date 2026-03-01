import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/doctor_model.dart';
import '../models/slot_model.dart';
import '../models/appointment_kind_model.dart';

class DoctorsRemoteDatasource {
  final ApiClient _apiClient;

  DoctorsRemoteDatasource(this._apiClient);

  Future<List<DoctorModel>> searchDoctors({
    String? query,
    String? city,
    String? specialty,
  }) async {
    final params = <String, dynamic>{};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (specialty != null && specialty.isNotEmpty) params['specialty'] = specialty;

    final response = await _apiClient.get(
      ApiEndpoints.searchDoctors,
      queryParameters: params,
    );
    final list = response.data as List;
    return list.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SlotModel>> getAvailableSlots(String doctorId) async {
    final response = await _apiClient.get(ApiEndpoints.availableSlots(doctorId));
    final list = response.data as List;
    return list.map((e) => SlotModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AppointmentKindModel>> getAppointmentKinds(String doctorId) async {
    final response = await _apiClient.get(ApiEndpoints.appointmentKinds(doctorId));
    final list = response.data as List;
    return list.map((e) => AppointmentKindModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
