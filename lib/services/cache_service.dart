import '../models/article.dart';

class CacheService {
  final Map<String, List<Article>> _sectionCache = {};
  final Map<String, DateTime> _lastUpdated = {};
  final Map<String, String> _latestArticleId = {};
  static const Duration _cacheTTL = Duration(minutes: 10);

  bool isFresh(String key) {
    final last = _lastUpdated[key];
    if (last == null) return false;
    return DateTime.now().difference(last) < _cacheTTL;
  }

  void set(String key, List<Article> data) {
    _sectionCache[key] = data;
    _lastUpdated[key] = DateTime.now();
  }

  List<Article>? get(String key) => _sectionCache[key];

  String? getLatestId(String key) => _latestArticleId[key];

  void setLatestId(String key, String id) {
    _latestArticleId[key] = id;
  }
}