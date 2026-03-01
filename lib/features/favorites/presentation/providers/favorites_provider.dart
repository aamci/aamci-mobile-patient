import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/favorites_remote_datasource.dart';
import '../../../doctors/data/models/doctor_model.dart';

final favoritesRemoteProvider = Provider<FavoritesRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FavoritesRemoteDatasource(apiClient);
});

class FavoritesState {
  final List<DoctorModel> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRemoteDatasource _datasource;

  FavoritesNotifier(this._datasource) : super(const FavoritesState());

  Future<void> load() async {
    state = FavoritesState(isLoading: true, favorites: state.favorites);
    try {
      final favorites = await _datasource.getFavorites();
      state = FavoritesState(favorites: favorites);
    } catch (e) {
      state = FavoritesState(favorites: state.favorites, error: 'Erreur de chargement');
    }
  }

  Future<void> toggle(String doctorId) async {
    try {
      await _datasource.toggleFavorite(doctorId);
      await load();
    } catch (_) {}
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final datasource = ref.watch(favoritesRemoteProvider);
  return FavoritesNotifier(datasource);
});
