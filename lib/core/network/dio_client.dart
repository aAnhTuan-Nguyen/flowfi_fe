import 'package:dio/dio.dart';

import '../config/app_config.dart';

Dio createDioClient() {
  return Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
}
