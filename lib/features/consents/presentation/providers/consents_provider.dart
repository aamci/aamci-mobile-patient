import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/consents_remote_datasource.dart';

class ConsentsState {
  final List<ConsentRecord> consents;
  final bool isLoading;
  final String? updatingType;
  final String? error;

  const ConsentsState({
    this.consents = const [],
    this.isLoading = false,
    this.updatingType,
    this.error,
  });

  ConsentsState copyWith({
    List<ConsentRecord>? consents,
    bool? isLoading,
    String? updatingType,
    String? error,
    bool clearUpdating = false,
  }) =>
      ConsentsState(
        consents: consents ?? this.consents,
        isLoading: isLoading ?? this.isLoading,
        updatingType: clearUpdating ? null : (updatingType ?? this.updatingType),
        error: error,
      );
}

class ConsentsNotifier extends StateNotifier<ConsentsState> {
  final ConsentsRemoteDatasource _datasource;
  final String _userId;

  ConsentsNotifier(this._datasource, this._userId) : super(const ConsentsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _datasource.getConsents(_userId);
      state = state.copyWith(consents: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> update(String type, bool granted) async {
    state = state.copyWith(updatingType: type);
    try {
      await _datasource.updateConsent(_userId, type, granted);
      final updated = state.consents.map((c) {
        if (c.type == type) {
          return ConsentRecord(
            type: type,
            granted: granted,
            grantedAt: granted ? DateTime.now() : c.grantedAt,
            revokedAt: granted ? null : DateTime.now(),
          );
        }
        return c;
      }).toList();
      // Add if not present
      if (!updated.any((c) => c.type == type)) {
        updated.add(ConsentRecord(
          type: type,
          granted: granted,
          grantedAt: granted ? DateTime.now() : null,
          revokedAt: granted ? null : DateTime.now(),
        ));
      }
      state = state.copyWith(consents: updated, clearUpdating: true);
    } catch (e) {
      state = state.copyWith(clearUpdating: true, error: e.toString());
    }
  }
}

final consentsProvider = StateNotifierProvider<ConsentsNotifier, ConsentsState>((ref) {
  final userId = ref.watch(authProvider).user?.id ?? '';
  final apiClient = ref.read(apiClientProvider);
  final datasource = ConsentsRemoteDatasource(apiClient);
  return ConsentsNotifier(datasource, userId);
});
