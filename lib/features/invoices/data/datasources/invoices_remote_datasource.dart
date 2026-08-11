import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class InvoiceModel {
  final String id;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? appointmentId;

  const InvoiceModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.appointmentId,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      appointmentId: json['appointmentId']?.toString(),
    );
  }
}

class InvoicesRemoteDatasource {
  final ApiClient _apiClient;

  InvoicesRemoteDatasource(this._apiClient);

  Future<List<InvoiceModel>> getInvoices() async {
    final response = await _apiClient.get(ApiEndpoints.invoices);
    final list = response.data as List;
    return list.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
