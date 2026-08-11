import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/invoices_remote_datasource.dart';

final invoicesRemoteProvider = Provider<InvoicesRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InvoicesRemoteDatasource(apiClient);
});

class InvoicesState {
  final List<InvoiceModel> invoices;
  final bool isLoading;
  final String? error;

  const InvoicesState({
    this.invoices = const [],
    this.isLoading = false,
    this.error,
  });

  InvoicesState copyWith({
    List<InvoiceModel>? invoices,
    bool? isLoading,
    String? error,
  }) {
    return InvoicesState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InvoicesNotifier extends StateNotifier<InvoicesState> {
  final InvoicesRemoteDatasource _datasource;

  InvoicesNotifier(this._datasource) : super(const InvoicesState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invoices = await _datasource.getInvoices();
      state = state.copyWith(isLoading: false, invoices: invoices);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur de chargement');
    }
  }
}

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, InvoicesState>((ref) {
  final datasource = ref.watch(invoicesRemoteProvider);
  return InvoicesNotifier(datasource);
});
