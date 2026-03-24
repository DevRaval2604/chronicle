import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/article.dart';

class NewsService {
  static const _baseUrl =
      'https://api.nytimes.com/svc/topstories/v2';

  late final Dio _dio;

  NewsService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  Future<List<Article>> fetchTopStories(String section) async {
    final apiKey = dotenv.env['NYT_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Missing API key');
    }

    try {
      final res = await _dio.get(
        '/$section.json',
        queryParameters: {'api-key': apiKey},
      );

      final List data = res.data['results'] ?? [];
      return data
          .map((e) => Article.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  String _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Timeout. Check connection';
      case DioExceptionType.connectionError:
        return 'No internet';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 429) {
        return 'Too many requests. Please wait a moment and try again.';
        }
        if (code == 401) {
          return 'Invalid API key';
        }
        return 'Server error';
      default:
        return 'Unexpected error';
    }
  }
}