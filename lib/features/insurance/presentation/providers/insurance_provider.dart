import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/insurance_remote_datasource.dart';

final insuranceRemoteProvider = Provider<InsuranceRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InsuranceRemoteDatasource(apiClient);
});

class InsuranceState {
  final InsuranceData? data;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const InsuranceState({
    this.data,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  InsuranceState copyWith({
    InsuranceData? data,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return InsuranceState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class InsuranceNotifier extends StateNotifier<InsuranceState> {
  final InsuranceRemoteDatasource _datasource;

  InsuranceNotifier(this._datasource) : super(const InsuranceState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _datasource.getInsurance();
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      // 404 means no insurance record yet — treat as empty
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> save(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final updated = await _datasource.updateInsurance(data);
      state = state.copyWith(isSaving: false, data: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Erreur lors de l\'enregistrement');
      return false;
    }
  }
}

final insuranceProvider = StateNotifierProvider<InsuranceNotifier, InsuranceState>((ref) {
  final datasource = ref.watch(insuranceRemoteProvider);
  return InsuranceNotifier(datasource);
});
