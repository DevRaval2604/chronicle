import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../screens/article_detail_screen.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final sw = size.width;
    final sh = size.height;
    final isTablet = sw > 600;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArticleDetailScreen(article: article),
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: isTablet ? sh * 0.18 : sh * 0.15,
        ),
        padding: EdgeInsets.all(sw * 0.02),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sw * 0.02),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: sw * 0.002,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(sw * 0.015),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                width: isTablet ? sw * 0.25 : sw * 0.3,
                height: isTablet ? sh * 0.16 : sh * 0.13,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: isTablet ? sw * 0.25 : sw * 0.3,
                  height: isTablet ? sh * 0.16 : sh * 0.13,
                  color: Colors.grey[200],
                ),
                errorWidget: (_, _, _) => Container(
                  width: isTablet ? sw * 0.25 : sw * 0.3,
                  height: isTablet ? sh * 0.16 : sh * 0.13,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: sw * 0.05),
                ),
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? sw * 0.03 : sw * 0.042,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  Text(
                    article.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: sh * 0.002),
                  Text(
                    article.formattedDate,
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.028,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}