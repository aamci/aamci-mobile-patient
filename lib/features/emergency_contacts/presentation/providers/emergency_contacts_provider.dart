import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/emergency_contacts_remote_datasource.dart';

final emergencyContactsRemoteProvider = Provider<EmergencyContactsRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EmergencyContactsRemoteDatasource(apiClient);
});

class EmergencyContactsState {
  final List<EmergencyContact> contacts;
  final bool isLoading;
  final String? error;

  const EmergencyContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.error,
  });

  EmergencyContactsState copyWith({
    List<EmergencyContact>? contacts,
    bool? isLoading,
    String? error,
  }) {
    return EmergencyContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EmergencyContactsNotifier extends StateNotifier<EmergencyContactsState> {
  final EmergencyContactsRemoteDatasource _datasource;
  final String? _userId;

  EmergencyContactsNotifier(this._datasource, this._userId)
      : super(const EmergencyContactsState());

  Future<void> load() async {
    final userId = _userId;
    if (userId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contacts = await _datasource.getContacts(userId);
      state = state.copyWith(isLoading: false, contacts: contacts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur de chargement');
    }
  }

  Future<bool> add(Map<String, dynamic> data) async {
    final userId = _userId;
    if (userId == null) return false;
    try {
      final contact = await _datasource.createContact(userId, data);
      state = state.copyWith(contacts: [...state.contacts, contact]);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de l\'ajout');
      return false;
    }
  }

  Future<bool> delete(String contactId) async {
    try {
      await _datasource.deleteContact(contactId);
      state = state.copyWith(
        contacts: state.contacts.where((c) => c.id != contactId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la suppression');
      return false;
    }
  }
}

final emergencyContactsProvider =
    StateNotifierProvider<EmergencyContactsNotifier, EmergencyContactsState>((ref) {
  final datasource = ref.watch(emergencyContactsRemoteProvider);
  final userId = ref.watch(authProvider).user?.id;
  return EmergencyContactsNotifier(datasource, userId);
});
