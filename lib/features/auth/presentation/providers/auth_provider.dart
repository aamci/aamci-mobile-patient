import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

final authDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRemoteDatasource(apiClient, storage);
});

enum AuthStatus { initial, authenticated, unauthenticated, loading, emailVerificationRequired }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDatasource _datasource;
  final SecureStorageService _storage;

  AuthNotifier(this._datasource, this._storage) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storage.getToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _datasource.getCurrentUser();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _storage.clearToken();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _datasource.login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      final msg = e.toString();
      String errorMsg = 'Email ou mot de passe incorrect';
      if (msg.toLowerCase().contains('not verified') || msg.toLowerCase().contains('verify')) {
        errorMsg = 'Veuillez vérifier votre email avant de vous connecter.';
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: errorMsg,
      );
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _datasource.register(email, password, fullName);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      if (e.toString().contains('EMAIL_VERIFICATION_REQUIRED')) {
        state = state.copyWith(
          status: AuthStatus.emailVerificationRequired,
          error: 'Compte créé ! Vérifiez votre boîte mail pour activer votre compte.',
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Erreur lors de l\'inscription. Veuillez réessayer.',
        );
      }
    }
  }

  Future<void> logout() async {
    await _datasource.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final datasource = ref.watch(authDatasourceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(datasource, storage);
});
