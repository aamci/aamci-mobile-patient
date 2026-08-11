import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class InsuranceData {
  final String? provider;
  final String? number;
  final String? expiryDate;
  final String? mutualInsurance;
  final String? socialSecurityNumber;

  const InsuranceData({
    this.provider,
    this.number,
    this.expiryDate,
    this.mutualInsurance,
    this.socialSecurityNumber,
  });

  factory InsuranceData.fromJson(Map<String, dynamic> json) {
    return InsuranceData(
      provider: json['provider']?.toString(),
      number: json['number']?.toString(),
      expiryDate: json['expiryDate']?.toString(),
      mutualInsurance: json['mutualInsurance']?.toString(),
      socialSecurityNumber: json['socialSecurityNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (provider != null) 'provider': provider,
      if (number != null) 'number': number,
      if (expiryDate != null) 'expiryDate': expiryDate,
      if (mutualInsurance != null) 'mutualInsurance': mutualInsurance,
      if (socialSecurityNumber != null) 'socialSecurityNumber': socialSecurityNumber,
    };
  }
}

class InsuranceRemoteDatasource {
  final ApiClient _apiClient;

  InsuranceRemoteDatasource(this._apiClient);

  Future<InsuranceData?> getInsurance() async {
    final response = await _apiClient.get(ApiEndpoints.insurance);
    if (response.data == null) return null;
    return InsuranceData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InsuranceData> updateInsurance(Map<String, dynamic> data) async {
    final response = await _apiClient.patch(ApiEndpoints.insurance, data: data);
    return InsuranceData.fromJson(response.data as Map<String, dynamic>);
  }
}
