class ApiConfig {
  // Android emulator uses 10.0.2.2 to reach host; iOS simulator uses localhost
  static const String devBaseUrl = 'http://10.0.2.2:3002';
  static const String prodBaseUrl = 'https://api-ieis.onrender.com';

  static String get baseUrl {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? prodBaseUrl : devBaseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
