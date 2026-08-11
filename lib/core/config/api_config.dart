import 'dart:io' show Platform;

class ApiConfig {
  // Android emulator reaches the host machine via 10.0.2.2
  // iOS simulator reaches it via localhost
  static const String prodBaseUrl = 'https://api.ibogha.elowe.fr';

  static String get baseUrl {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) return prodBaseUrl;
    return Platform.isAndroid
        ? 'http://10.0.2.2:3002'
        : 'http://localhost:3002';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
