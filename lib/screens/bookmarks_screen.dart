import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../theme/app_theme.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double sw = size.width;
    final double sh = size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: sh * 0.08,
        centerTitle: true,
        title: Text(
          'Saved Articles',
          style: TextStyle(
            fontSize: sw * 0.055,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: sw * 0.05),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: sw * 0.2,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: sh * 0.02),
                  Text(
                    'No saved articles yet',
                    style: TextStyle(
                      fontSize: sw * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: sh * 0.01),
                  Text(
                    'Tap the bookmark icon on any article to save it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: sw * 0.035,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: sh * 0.04),
                  ElevatedButton.icon(
                    style: AppTheme.primaryButtonStyle(context, sw, sh),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back to News'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.bookmarks.length,
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03, vertical: sh * 0.01),
                  separatorBuilder: (_, _) =>
                      SizedBox(height: sh * 0.015),
                  itemBuilder: (context, index) =>
                      ArticleCard(article: provider.bookmarks[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}