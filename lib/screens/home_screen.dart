import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/filter_sheet.dart';
import '../screens/bookmarks_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double sw = size.width;
    final double sh = size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: sh * 0.08,
        centerTitle: true,
        leading: SizedBox(width: sw * 0.07),
        title: Text(
          'Chronicle',
          style: TextStyle(
            fontSize: isTablet ? sw * 0.05 : sw * 0.06,
            fontWeight: FontWeight.w800,
            letterSpacing: sw * 0.002,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_rounded, size: isTablet ? sw * 0.04 : sw * 0.065),
            tooltip: 'Bookmarks',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: sw * 0.02),
            child: IconButton(
              icon: Icon(
                context.watch<NewsProvider>().getThemeIcon(context),
                size: isTablet ? sw * 0.04 : sw * 0.065,
              ),
              tooltip: 'Toggle theme',
              onPressed: () => context.read<NewsProvider>().toggleTheme(context),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(sh * 0.16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: sh * 0.06,
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(fontSize: sw * 0.04),
                          onChanged: (val) =>
                              context.read<NewsProvider>().updateSearch(val),
                          decoration: InputDecoration(
                            hintText: 'Search articles...',
                            prefixIcon: Icon(Icons.search, size: sw * 0.05),
                            suffixIcon: context.watch<NewsProvider>().searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<NewsProvider>().updateSearch('');
                                    },
                                  )
                                : null,
                            contentPadding: EdgeInsets.symmetric(vertical: sh * 0.01),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(sw * 0.02),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    Consumer<NewsProvider>(
                      builder: (context, provider, _) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Badge(
                          isLabelVisible: provider.activeFilterCount > 0,
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          textColor: isDark ? Colors.black : Colors.white,
                          label: Text('${provider.activeFilterCount}'),
                          child: IconButton(
                            icon: Icon(
                              Icons.tune_rounded,
                              size: sw * 0.065,
                              color: provider.hasActiveFilters
                                  ? (isDark ? Colors.white : Colors.black)
                                  : null,
                            ),
                            tooltip: 'Filter articles',
                            onPressed: _showFilterSheet,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: sh * 0.02),
              SizedBox(
                height: sh * 0.06,
                child: Consumer<NewsProvider>(
                  builder: (context, provider, _) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.sections.length,
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                      itemBuilder: (context, index) {
                        final section = provider.sections[index];
                        final isSelected =
                            provider.selectedSection == section['value'];
                        final Color activeColor =
                            isDark ? Colors.black : Colors.white;
                        final Color inactiveColor = theme.colorScheme.primary;

                        return Padding(
                          padding: EdgeInsets.only(right: sw * 0.02),
                          child: ChoiceChip(
                            avatar: Icon(
                              section['icon'],
                              size: isTablet ? sw * 0.03 : sw * 0.04,
                              color: isSelected ? activeColor : inactiveColor,
                            ),
                            label: Text(
                              section['label'],
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.025 : sw * 0.032,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected ? activeColor : inactiveColor,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: theme.colorScheme.primary,
                            backgroundColor: theme.chipTheme.backgroundColor,
                            showCheckmark: false,
                            pressElevation: sw * 0.01,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : theme.dividerColor,
                              width: sw * 0.002,
                            ),
                            onSelected: (selected) {
                              if (selected &&
                                  provider.selectedSection != section['value']) {
                                _searchController.clear();
                                provider.changeSection(section['value']);
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: sh * 0.01),
            ],
          ),
        ),
      ),

      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.articles.isEmpty) {
            return const ShimmerLoader();
          }
          if (provider.hasError && provider.articles.isEmpty) {
            return _ResponsiveError(
              sw: sw, sh: sh, message: provider.errorMessage);
          }
          if (provider.articles.isEmpty) {
            return _EmptySectionView(
              sw: sw,
              sh: sh,
              isTablet: isTablet,
              sectionName: provider.selectedSection,
            );
          }
          return Column(
            children: [
              if (provider.isLoading)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              if (provider.isOffline)
                Container(
                  width: double.infinity,
                  color: Colors.orange.withValues(alpha: 0.15),
                  padding: EdgeInsets.symmetric(
                      vertical: sh * 0.008, horizontal: sw * 0.04),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: sw * 0.04, color: Colors.orange),
                      SizedBox(width: sw * 0.02),
                      Text(
                        'Showing cached articles — you\'re offline',
                        style: TextStyle(
                            fontSize: sw * 0.03, color: Colors.orange[800]),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context
                      .read<NewsProvider>()
                      .fetchArticles(isRefresh: true),
                  color: Theme.of(context).colorScheme.primary,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo is ScrollUpdateNotification &&
                          scrollInfo.metrics.extentAfter < 200) {
                        context.read<NewsProvider>().loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: provider.articles.length,
                      padding: EdgeInsets.symmetric(
                          vertical: sh * 0.01, horizontal: sw * 0.03),
                      separatorBuilder: (_, _) =>
                          SizedBox(height: sh * 0.015),
                      itemBuilder: (context, index) =>
                          ArticleCard(article: provider.articles[index]),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptySectionView extends StatelessWidget {
  final double sw, sh;
  final bool isTablet;
  final String sectionName;

  const _EmptySectionView({
    required this.sw,
    required this.sh,
    required this.isTablet,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper_rounded,
              size: sw * 0.15,
              color: Colors.grey.withValues(alpha: 0.3)),
          SizedBox(height: sh * 0.02),
          Text(
            'No articles in ${sectionName.toUpperCase()}',
            style: TextStyle(
              fontSize: isTablet ? sw * 0.04 : sw * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Try a different category or refresh the feed.',
            style: TextStyle(
              fontSize: isTablet ? sw * 0.025 : sw * 0.035,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: sh * 0.03),
          ElevatedButton.icon(
            style: AppTheme.primaryButtonStyle(context, sw, sh),
            onPressed: () =>
                context.read<NewsProvider>().fetchArticles(isRefresh: true),
            icon: Icon(Icons.refresh, size: sw * 0.05),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveError extends StatelessWidget {
  final double sw, sh;
  final String message;

  const _ResponsiveError({
    required this.sw,
    required this.sh,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: sw * 0.12,
            color: isDark
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.black.withValues(alpha: 0.8),
          ),
          SizedBox(height: sh * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: sw * 0.045, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: sh * 0.03),
          ElevatedButton.icon(
            style: AppTheme.primaryButtonStyle(context, sw, sh),
            onPressed: () => context.read<NewsProvider>().retry(),
            icon: const Icon(Icons.refresh),
            label: Text('Try Again',
                style: TextStyle(fontSize: sw * 0.04)),
          ),
        ],
      ),
    );
  }
}