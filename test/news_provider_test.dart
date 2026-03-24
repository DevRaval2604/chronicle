import 'package:flutter_test/flutter_test.dart';
import 'package:chronicle/providers/news_provider.dart';
import 'package:chronicle/models/article.dart';

Article createArticle({
  required String title,
  required String byline,
  required String date,
  required String url,
  List<String> geo = const [],
}) {
  return Article(
    title: title,
    abstract: 'This is a sufficiently long abstract for testing purposes',
    byline: byline,
    publishedDate: date,
    url: url,
    imageUrl: 'img',
    section: 'home',
    subsection: '',
    caption: '',
    geoFacet: geo,
  );
}

void main() {
  group('NewsProvider Tests', () {
    late NewsProvider provider;

    setUp(() {
      provider = NewsProvider();
    });

    // ✅ 1. AUTHOR FILTER
    test('filters articles by author correctly', () {
      final articles = [
        createArticle(
          title: 'A',
          byline: 'By John Doe',
          date: '2024-01-01',
          url: '1',
        ),
        createArticle(
          title: 'B',
          byline: 'By Jane Smith',
          date: '2024-01-02',
          url: '2',
        ),
      ];

      provider.setArticlesForTest(articles);
      provider.applyFilters(author: 'john');

      expect(provider.articles.length, 1);
      expect(
          provider.articles.first.authorName.toLowerCase(), contains('john'));
    });

    // ✅ 2. LOCATION FILTER
    test('filters articles by location correctly', () {
      final articles = [
        createArticle(
          title: 'India News',
          byline: 'By A',
          date: '2024-01-01',
          url: '1',
          geo: ['India'],
        ),
        createArticle(
          title: 'USA News',
          byline: 'By B',
          date: '2024-01-02',
          url: '2',
          geo: ['USA'],
        ),
      ];

      provider.setArticlesForTest(articles);
      provider.applyFilters(location: 'india');

      expect(provider.articles.length, 1);
      expect(provider.articles.first.geoFacet.first.toLowerCase(),
          contains('india'));
    });

    // ✅ 3. SEARCH FILTER
    test('filters articles by search query', () async {
      final articles = [
        createArticle(
          title: 'Flutter News',
          byline: 'By A',
          date: '2024-01-01',
          url: '1',
        ),
        createArticle(
          title: 'React News',
          byline: 'By B',
          date: '2024-01-02',
          url: '2',
        ),
      ];

      provider.setArticlesForTest(articles);
      provider.updateSearch('flutter');

      // wait for debounce
      await Future.delayed(const Duration(milliseconds: 400));

      expect(provider.articles.length, 1);
      expect(provider.articles.first.title.toLowerCase(), contains('flutter'));
    });

    // ✅ 4. SORTING
    test('sorts articles newest first', () {
      final articles = [
        createArticle(
          title: 'Old',
          byline: 'By A',
          date: '2023-01-01',
          url: '1',
        ),
        createArticle(
          title: 'New',
          byline: 'By B',
          date: '2024-01-01',
          url: '2',
        ),
      ];

      provider.setArticlesForTest(articles);
      provider.applyFilters(sort: NewsSortOrder.newest);

      expect(provider.articles.first.title, 'New');
    });

    // ✅ 5. SORT OLDEST
    test('sorts articles oldest first', () {
      final articles = [
        createArticle(
          title: 'Old',
          byline: 'By A',
          date: '2023-01-01',
          url: '1',
        ),
        createArticle(
          title: 'New',
          byline: 'By B',
          date: '2024-01-01',
          url: '2',
        ),
      ];

      provider.setArticlesForTest(articles);
      provider.applyFilters(sort: NewsSortOrder.oldest);

      expect(provider.articles.first.title, 'Old');
    });

    // ✅ 6. CLEAR FILTERS
    test('clears filters correctly', () {
      final articles = [
        createArticle(
          title: 'Test',
          byline: 'By John',
          date: '2024-01-01',
          url: '1',
        ),
      ];

      provider.setArticlesForTest(articles);
      provider.applyFilters(author: 'john');

      expect(provider.articles.length, 1);

      provider.clearFilters();

      expect(provider.articles.length, 1);
      expect(provider.searchQuery, '');
    });

    // ✅ 7. BOOKMARK TOGGLE (LOGIC ONLY)
    test('bookmark logic works (in-memory check)', () async {
      final article = createArticle(
        title: 'Test',
        byline: 'By A',
        date: '2024-01-01',
        url: '1',
      );

      await provider.toggleBookmark(article);
      expect(provider.isBookmarked(article), true);

      await provider.toggleBookmark(article);
      expect(provider.isBookmarked(article), false);
    });
  });
}