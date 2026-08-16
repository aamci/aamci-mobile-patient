import 'dart:io' show Platform;

class ApiConfig {
  // Android emulator reaches the host machine via 10.0.2.2
  // iOS simulator reaches it via localhost
  static const String prodBaseUrl = 'https://api.ibogha241.ga';

  static String get baseUrl {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    const useProd = bool.fromEnvironment('USE_PROD');
    if (isProduction || useProd) return prodBaseUrl;
    return Platform.isAndroid
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
