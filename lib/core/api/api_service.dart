import 'package:dio/dio.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://YOUR_SERVER/api',
      headers: {
        'Accept': 'application/json',
      },
    ),
  );
}
