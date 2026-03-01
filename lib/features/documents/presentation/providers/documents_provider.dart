import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/documents_remote_datasource.dart';

final documentsRemoteProvider = Provider<DocumentsRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DocumentsRemoteDatasource(apiClient);
});

final documentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final datasource = ref.watch(documentsRemoteProvider);
  return datasource.getDocuments();
});
