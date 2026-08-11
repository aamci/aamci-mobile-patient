import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class EmergencyContact {
  final String id;
  final String fullName;
  final String phone;
  final String? phoneSecondary;
  final String? email;
  final String relationship;

  const EmergencyContact({
    required this.id,
    required this.fullName,
    required this.phone,
    this.phoneSecondary,
    this.email,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      phoneSecondary: json['phoneSecondary']?.toString(),
      email: json['email']?.toString(),
      relationship: json['relationship']?.toString() ?? '',
    );
  }
}

class EmergencyContactsRemoteDatasource {
  final ApiClient _apiClient;

  EmergencyContactsRemoteDatasource(this._apiClient);

  Future<List<EmergencyContact>> getContacts(String userId) async {
    final response = await _apiClient.get(ApiEndpoints.emergencyContacts(userId));
    final list = response.data as List;
    return list.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EmergencyContact> createContact(String userId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiEndpoints.emergencyContacts(userId),
      data: data,
    );
    return EmergencyContact.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteContact(String contactId) async {
    await _apiClient.delete(ApiEndpoints.emergencyContactById(contactId));
  }
}
