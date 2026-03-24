import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import '../services/cache_service.dart';
import '../services/filter_service.dart';

enum NewsSortOrder { newest, oldest }

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  final CacheService _cacheService = CacheService();

  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  List<Article> _bookmarks = [];

  Timer? _autoRefreshTimer;

  bool _isLoading = false;
  bool _isOffline = false;
  String _errorMessage = '';
  bool _hasError = false;

  String _selectedSection = 'home';

  final List<Map<String, dynamic>> sections = [
    {'label': 'Home', 'value': 'home', 'icon': Icons.home_rounded},
    {'label': 'World', 'value': 'world', 'icon': Icons.public_rounded},
    {'label': 'Arts', 'value': 'arts', 'icon': Icons.palette_rounded},
    {'label': 'Science', 'value': 'science', 'icon': Icons.science_rounded},
    {'label': 'Tech', 'value': 'technology', 'icon': Icons.computer_rounded},
    {'label': 'Health', 'value': 'health', 'icon': Icons.favorite_rounded},
    {'label': 'Travel', 'value': 'travel', 'icon': Icons.flight_rounded},
    {'label': 'Food', 'value': 'food', 'icon': Icons.restaurant_rounded},
    {'label': 'Opinion', 'value': 'opinion', 'icon': Icons.rate_review_rounded},
  ];

  String _searchQuery = '';
  String _filterAuthor = '';
  String _filterLocation = '';
  NewsSortOrder? _sortOrder;
  Timer? _debounce;
  int _visibleCount = 10;

  ThemeMode _themeMode = ThemeMode.system;

  List<Article> get articles => _filteredArticles.take(_visibleCount).toList();
  List<Article> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get selectedSection => _selectedSection;
  String get searchQuery => _searchQuery;
  String get filterAuthor => _filterAuthor;
  String get filterLocation => _filterLocation;
  NewsSortOrder? get sortOrder => _sortOrder;
  ThemeMode get themeMode => _themeMode;

  bool get hasActiveFilters =>
      _filterAuthor.isNotEmpty ||
      _filterLocation.isNotEmpty ||
      _sortOrder != null;

  int get activeFilterCount {
    int count = 0;
    if (_filterAuthor.isNotEmpty) count++;
    if (_filterLocation.isNotEmpty) count++;
    if (_sortOrder != null) count++;
    return count;
  }

  // ONLY FOR TESTING
  void setArticlesForTest(List<Article> articles) {
    _articles = articles;
    _applyFilters();
  }

  bool isBookmarked(Article article) =>
      _bookmarks.any((b) => b.url == article.url);

  List<Article> _filterValidArticles(List<Article> raw) {
    return raw.where((article) {
      final hasValidTitle = article.title.trim().isNotEmpty;
      final hasValidAbstract =
          article.abstract.trim().isNotEmpty && article.abstract.length > 25;
      final hasValidAuthor = article.authorName.trim().isNotEmpty &&
          !article.authorName.toLowerCase().contains('unknown');
      final hasImage = article.imageUrl.trim().isNotEmpty;

      return hasValidTitle &&
          hasValidAbstract &&
          hasValidAuthor &&
          hasImage;
    }).toList();
  }

  Future<void> initialize() async {
    _loadBookmarks();
    await _prefetchAllSections();
  }

  Future<void> _prefetchAllSections() async {
    _setLoading(true);

    try {
      final raw =
          await _newsService.fetchTopStories(_selectedSection);
      final currentResults = _filterValidArticles(raw);

      _cacheService.set(_selectedSection, currentResults);

      _articles = currentResults;
      _applyFilters();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _setLoading(false);
    _backgroundPrefetchRest();
  }

  Future<void> _backgroundPrefetchRest() async {
    for (var section in sections) {
      final key = section['value'];
      if (key == _selectedSection) continue;

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final raw = await _newsService.fetchTopStories(key);
        final results = _filterValidArticles(raw);
        _cacheService.set(key, results);
      } catch (_) {}
    }
    _startAutoRefresh();
  }

  Future<void> changeSection(String section) async {
    if (_selectedSection == section) return;

    _debounce?.cancel();
    _selectedSection = section;

    _searchQuery = '';
    _sortOrder = null;
    _filterAuthor = '';
    _filterLocation = '';

    _articles = _cacheService.get(section) ?? [];

    if (_articles.isEmpty) {
      _fetchSectionSilent(section);
    }

    _applyFilters();
    notifyListeners();
  }

  Future<void> _fetchSectionSilent(String section) async {
    try {
      final raw = await _newsService.fetchTopStories(section);
      final results = _filterValidArticles(raw);

      _cacheService.set(section, results);

      if (_selectedSection == section) {
        _articles = results;
        _applyFilters();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchArticles({
    bool isRefresh = false,
    bool isInitialLoad = false,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();

    final hasConnection = connectivity.any(
      (c) => c != ConnectivityResult.none,
    );

    if (!hasConnection) {
      _isOffline = true;
    } else {
      _isOffline = false;
    }
    notifyListeners();

    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final raw =
          await _newsService.fetchTopStories(_selectedSection);
      final results = _filterValidArticles(raw);

      results.sort(
          (a, b) => b.publishedDate.compareTo(a.publishedDate));

      final newLatestId =
          results.isNotEmpty ? results.first.url : null;
      final oldLatestId = _cacheService.getLatestId(_selectedSection);

      if (newLatestId != null && newLatestId == oldLatestId) {
        return;
      }

      if (newLatestId != null) {
        _cacheService.setLatestId(_selectedSection, newLatestId);
      }

      _cacheService.set(_selectedSection, results);

      _articles = results;
      _isOffline = false;
      _applyFilters();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString().replaceAll('Exception: ', '');

      if (_articles.isNotEmpty) {
        _hasError = false;
      } else {
        _articles = [];
        _filteredArticles = [];
      }
    } finally {
      _setLoading(false);
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _refreshStaleSections(),
    );
  }

  Future<void> _refreshStaleSections() async {
    for (var section in sections) {
      final key = section['value'];

      if (!_cacheService.isFresh(key)) {
        try {
          final raw = await _newsService.fetchTopStories(key);
          final results = _filterValidArticles(raw);

          _cacheService.set(key, results);

          if (_selectedSection == key) {
            _articles = results;
            _applyFilters();
            notifyListeners();
          }
        } catch (_) {}
      }
    }
  }

  void updateSearch(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
      notifyListeners();
    });
  }

  void loadMore() {
    if (_visibleCount < _filteredArticles.length) {
      _visibleCount += 10;
      notifyListeners();
    }
  }

  void applyFilters({
    String author = '',
    String location = '',
    NewsSortOrder? sort,
  }) {
    _filterAuthor = author;
    _filterLocation = location;
    _sortOrder = sort;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _filterAuthor = '';
    _filterLocation = '';
    _sortOrder = null;
    _searchQuery = '';
    _filteredArticles = List.from(_articles);
    notifyListeners();
  }

  void _applyFilters() {
    _visibleCount = 10; // Reset pagination on filter change

    _filteredArticles = FilterService.apply(
      articles: _articles,
      search: _searchQuery,
      author: _filterAuthor,
      location: _filterLocation,
      sort: _sortOrder,
    );
  }

  void _loadBookmarks() {
    final box = Hive.box<Article>('bookmarks');
    _bookmarks = box.values.toList();
  }

  Future<void> toggleBookmark(Article article) async {
    try {
      // Try to persist if Hive is ready (skips in tests)
      if (Hive.isBoxOpen('bookmarks')) {
        final box = Hive.box<Article>('bookmarks');
        if (isBookmarked(article)) {
          final key = box.keys.firstWhere(
            (k) => box.get(k)?.url == article.url,
            orElse: () => null,
          );
          if (key != null) await box.delete(key);
        } else {
          await box.add(article);
        }
      }
    } catch (_) {}

    // Always update local state
    if (isBookmarked(article)) {
      _bookmarks.removeWhere((b) => b.url == article.url);
    } else {
      _bookmarks.add(article);
    }

    notifyListeners();
  }

  void toggleTheme(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      final brightness =
          MediaQuery.of(context).platformBrightness;
      _themeMode = brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    } else {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    }

    notifyListeners();
  }

  IconData getThemeIcon(BuildContext context) {
    final brightness =
        MediaQuery.of(context).platformBrightness;

    if (_themeMode == ThemeMode.system) {
      return brightness == Brightness.dark
          ? Icons.dark_mode_rounded
          : Icons.light_mode_rounded;
    }

    return _themeMode == ThemeMode.dark
        ? Icons.dark_mode_rounded
        : Icons.light_mode_rounded;
  }

  Future<void> retry() =>
      fetchArticles(isInitialLoad: true);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}