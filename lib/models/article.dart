import 'package:hive/hive.dart';

part 'article.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String abstract;

  @HiveField(2)
  final String byline;

  @HiveField(3)
  final String publishedDate;

  @HiveField(4)
  final String url;

  @HiveField(5)
  final String imageUrl;

  @HiveField(6)
  final String section;

  @HiveField(7)
  final String subsection;

  @HiveField(8)
  final String caption;

  @HiveField(9)
  final List<String> geoFacet;

  Article({
    required this.title,
    required this.abstract,
    required this.byline,
    required this.publishedDate,
    required this.url,
    required this.imageUrl,
    required this.section,
    required this.subsection,
    required this.caption,
    required this.geoFacet,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    String caption = '';

    final multimedia = json['multimedia'];
    if (multimedia is List && multimedia.isNotEmpty) {
      final item = multimedia.firstWhere(
        (m) => m['format'] == 'superJumbo',
        orElse: () => multimedia[0],
      );

      final raw = item['url'] ?? '';
      imageUrl = raw.startsWith('http')
          ? raw
          : 'https://www.nytimes.com/$raw';

      caption = item['caption'] ?? '';
    }

    return Article(
      title: json['title'] ?? '',
      abstract: json['abstract'] ?? '',
      byline: json['byline'] ?? '',
      publishedDate: json['published_date'] ?? '',
      url: json['url'] ?? '',
      imageUrl: imageUrl,
      section: json['section'] ?? '',
      subsection: json['subsection'] ?? '',
      caption: caption,
      geoFacet: (json['geo_facet'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'abstract': abstract,
      'byline': byline,
      'published_date': publishedDate,
      'url': url,
      'imageUrl': imageUrl,
      'section': section,
      'subsection': subsection,
      'caption': caption,
      'geo_facet': geoFacet,
    };
  }

  String get authorName =>
      byline.toLowerCase().startsWith('by ')
          ? byline.substring(3)
          : (byline.isEmpty ? 'Unknown' : byline);

  String get readingTime =>
      '${(abstract.split(' ').length / 200).ceil()} min read';

  String get formattedDate {
    try {
      final date = DateTime.parse(publishedDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return publishedDate;
    }
  }

  bool get hasImage => imageUrl.isNotEmpty;
}