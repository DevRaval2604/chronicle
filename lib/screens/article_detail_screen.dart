import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  Future<void> _launchUrl(BuildContext context) async {
    try {
      final Uri url = Uri.parse(article.url);
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open article in browser'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open article. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double sw = size.width;
    final double sh = size.height;
    final bool isTablet = sw > 600;

    final provider = context.watch<NewsProvider>();
    final isBookmarked = provider.isBookmarked(article);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: sh * 0.08,
        centerTitle: true,
        title: Text(
          'Chronicle',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: isTablet ? sw * 0.045 : sw * 0.055,
            letterSpacing: sw * 0.002,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: sw * 0.05),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                key: ValueKey(isBookmarked),
                size: sw * 0.055,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Save article',
            onPressed: () =>
                context.read<NewsProvider>().toggleBookmark(article),
          ),
          SizedBox(width: sw * 0.02),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.hasImage)
              Hero(
                tag: 'article_image_${article.url}',
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  width: sw,
                  height: sh * 0.35,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: sw,
                    height: sh * 0.35,
                    color: Colors.grey[200],
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: sw,
                    height: sh * 0.2,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, size: sw * 0.1),
                  ),
                ),
              )
            else
              Container(
                width: sw,
                height: sh * 0.2,
                color: Colors.grey[300],
                child: Icon(Icons.article_outlined, size: sw * 0.1),
              ),
            if (article.caption.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04, vertical: sh * 0.01),
                child: Text(
                  article.caption,
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.15 : sw * 0.05,
                vertical: sh * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.05 : sw * 0.065,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: sh * 0.025),

                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: sw * 0.04, color: Colors.grey),
                      SizedBox(width: sw * 0.015),
                      Expanded(
                        child: Text(
                          article.authorName,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: isTablet ? sw * 0.025 : sw * 0.035,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.008),

                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: sw * 0.04, color: Colors.grey),
                      SizedBox(width: sw * 0.015),
                      Text(
                        '${article.formattedDate} · ${article.readingTime}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isTablet ? sw * 0.025 : sw * 0.032,
                        ),
                      ),
                    ],
                  ),

                  if (article.geoFacet.isNotEmpty) ...[
                    SizedBox(height: sh * 0.015),
                    Wrap(
                      spacing: sw * 0.02,
                      runSpacing: sh * 0.005,
                      children: article.geoFacet
                          .take(3)
                          .map(
                            (location) => Chip(
                              label: Text(
                                location,
                                style: TextStyle(fontSize: sw * 0.028),
                              ),
                              avatar: Icon(Icons.location_on_rounded,
                                  size: sw * 0.03),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                    child: Divider(thickness: sw * 0.003),
                  ),

                  Text(
                    article.abstract,
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.035 : sw * 0.045,
                      height: 1.7,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withValues(alpha: 0.85),
                    ),
                  ),

                  SizedBox(height: sh * 0.015),

                  Text(
                    'This is a summary. Tap below to read the full story on NYT.',
                    style: TextStyle(
                      fontSize: sw * 0.032,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: sh * 0.04),

                  SizedBox(
                    width: sw,
                    height: sh * 0.07,
                    child: ElevatedButton.icon(
                      style: AppTheme.primaryButtonStyle(context, sw, sh),
                      onPressed: () => _launchUrl(context),
                      icon: Icon(Icons.launch_rounded, size: sw * 0.05),
                      label: Text(
                        'Read Full Story',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.035 : sw * 0.042,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}