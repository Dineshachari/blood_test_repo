import 'package:dio/dio.dart';


class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static Future<Response<dynamic>> getReports(int userId) async {
    const url = 'https://my-kaizen-backend.onrender.com/api/getReports';

    try {
      final response = await _dio.post(
        url,
        data: {'userId': userId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'API request failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('API request failed: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
