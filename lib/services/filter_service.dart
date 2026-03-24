import '../models/article.dart';
import '../providers/news_provider.dart';

class FilterService {
  static List<Article> apply({
    required List<Article> articles,
    required String search,
    required String author,
    required String location,
    required NewsSortOrder? sort,
  }) {
    String normalize(String s) => s.toLowerCase().trim();

    final q = normalize(search);
    final a = normalize(author);
    final l = normalize(location);

    var result = articles.where((article) {
      final title = normalize(article.title);
      final abstract = normalize(article.abstract);
      final authorName = normalize(article.authorName);

      final matchesSearch = q.isEmpty ||
          title.contains(q) ||
          abstract.contains(q) ||
          authorName.contains(q);

      final matchesAuthor = a.isEmpty || authorName.contains(a);

      final matchesLocation =
          l.isEmpty || article.geoFacet.any((g) => normalize(g).contains(l));

      return matchesSearch && matchesAuthor && matchesLocation;
    }).toList();

    if (sort != null) {
      result.sort((a, b) {
        final d1 = DateTime.tryParse(a.publishedDate) ?? DateTime(1970);
        final d2 = DateTime.tryParse(b.publishedDate) ?? DateTime(1970);

        return sort == NewsSortOrder.newest
            ? d2.compareTo(d1)
            : d1.compareTo(d2);
      });
    }

    return result;
  }
}