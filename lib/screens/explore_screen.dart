import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  final Map<String, List<String>> categoryFeeds = {
    'Top Stories':[
      'http://rss.cnn.com/rss/cnn_topstories.rss',
      'https://abcnews.go.com/abcnews/topstories',
      'https://www.newyorker.com/feed/everything',
      'https://feeds.feedburner.com/ndtvnews-top-stories',

    ],
    'Tech': [
      'https://abcnews.go.com/abcnews/technologyheadlines',
      'https://www.wired.com/feed/tag/ai/latest/rss',
      'https://www.forbes.com/innovation/feed',
      'https://www.wired.com/feed/tag/ai/latest/rss',
      'https://www.theweek.in/news/sci-tech.rss.xml',
      'https://www.sciencedaily.com/rss/top.xml',
      'https://feeds.feedburner.com/gadgets360-latest',
      'https://moxie.foxnews.com/google-publisher/tech.xml',
      'https://www.firstpost.com/commonfeeds/v1/mfp/rss/tech.xml',
      'https://feeds.bbci.co.uk/news/technology/rss.xml',
      'https://rss.nytimes.com/services/xml/rss/nyt/Technology.xml',
      'http://rss.cnn.com/rss/edition_technology.rss',
    ],
    'Business':[
      'https://feeds.feedburner.com/ndtvprofit-latest',
      'https://www.thehindu.com/business/Economy/feeder/default.rss',
      'https://moxie.foxbusiness.com/google-publisher/economy.xml',
      'https://feeds.content.dowjones.io/public/rss/mw_topstories',
      'https://rss.nytimes.com/services/xml/rss/nyt/Business.xml',
      'http://rss.cnn.com/rss/money_technology.rss',
      'https://feeds.content.dowjones.io/public/rss/mw_topstories'

    ],
    'Sports': [
      'https://www.mid-day.com/Resources/midday/rss/other-sports.xml',
      'https://globalnews.ca/sports/feed/',
      'https://www.theweek.in/news/sports.rss.xml',
      'https://www.mid-day.com/Resources/midday/rss/football.xml',
      'https://abcnews.go.com/abcnews/sportsheadlines',
      'https://feeds.feedburner.com/ndtvsports-latest',
      'https://www.espncricinfo.com/rss/content/story/feeds/6.xml',
      'https://www.mid-day.com/Resources/midday/rss/cricket.xml',
      'https://moxie.foxnews.com/google-publisher/sports.xml',
      'https://www.firstpost.com/commonfeeds/v1/mfp/rss/sports.xml',
      'https://feeds.bbci.co.uk/sport/rss.xml',
      'https://www.thehindu.com/sport/football/feeder/default.rss',
      'https://www.thehindu.com/sport/tennis/feeder/default.rss',
      'https://www.thehindu.com/sport/races/feeder/default.rss',
      'http://rss.cnn.com/rss/edition_sport.rss',
      'https://www.thehindu.com/sport/other-sports/feeder/default.rss',
    ],
    'Crypto': [
      'https://cointelegraph.com/rss',
      'https://www.coindesk.com/arc/outboundfeeds/rss/',
      'https://www.newsbtc.com/feed/',
      'https://cointelegraph.com/rss/tag/bitcoin',
      'https://cointelegraph.com/rss/tag/altcoin',
      'https://bitcoinmagazine.com/feed',
    ],
    'World': [
      'https://feeds.bbci.co.uk/news/world/rss.xml',
      'https://www.thehindu.com/news/international/feeder/default.rss',
      'https://www.sbs.com.au/news/topic/world/feed',
      'https://nypost.com/world-news/feed/',
      'https://feeds.feedburner.com/ndtvnews-world-news',
      'https://www.firstpost.com/commonfeeds/v1/mfp/rss/world.xml',
      'https://globalnews.ca/world/feed/',
      'https://www.thehindu.com/news/international/feeder/default.rss',
      'http://rss.cnn.com/rss/edition_world.rss',
      'https://www.mid-day.com/Resources/midday/rss/world-news.xml',
      'https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=100727362',
      'https://www.sbs.com.au/news/topic/world/feed',
      'http://rss.cnn.com/rss/money_topstories.rss',
      'https://rss.politico.com/economy.xml',
      'https://abcnews.go.com/abcnews/internationalheadlines',
      'https://www.theweek.in/news/world.rss.xml',
    ],
    'Politics': [
      'https://moxie.foxnews.com/google-publisher/politics.xml',
      'https://feeds.bbci.co.uk/news/politics/rss.xml',
      'https://rss.nytimes.com/services/xml/rss/nyt/politics.xml',
    ],
    'Entertainment': [
      'https://globalnews.ca/entertainment/feed/',
      'https://variety.com/feed/',
      'http://rss.cnn.com/rss/cnn_showbiz.rss',
      'https://www.mid-day.com/Resources/midday/rss/hollywood-news.xml',
      'https://www.theweek.in/news/entertainment.rss.xml',
      'https://abcnews.go.com/abcnews/entertainmentheadlines',
      'https://feeds.feedburner.com/ndtvmovies-latest',
      'https://www.thehindu.com/entertainment/movies/feeder/default.rss',
      'https://www.thehindu.com/entertainment/music/feeder/default.rss',
    ],
    'Science': [
      'https://www.wired.com/feed/category/science/latest/rss',
      'https://moxie.foxnews.com/google-publisher/science.xml',
      'https://www.wired.com/feed/category/science/latest/rss',
      'https://www.thehindu.com/sci-tech/science/feeder/default.rss',

    ],
  };

  final Map<String, IconData> categoryIcons = {
    'Top Stories': Icons.trending_up,
    'Tech': Icons.computer,
    'India': Icons.flag,
    'Business': Icons.business_center,
    'Sports': Icons.sports_soccer,
    'Markets': Icons.show_chart,
    'World': Icons.public,
    'Politics': Icons.how_to_vote,
    'Entertainment': Icons.movie,
    'Science': Icons.science,
  };

  final Map<String, Color> categoryColors = {
    'Top Stories': const Color(0xFFFF6B6B),
    'Tech': const Color(0xFF4ECDC4),
    'India': const Color(0xFFFF9F43),
    'Business': const Color(0xFF6BCF7F),
    'Sports': const Color(0xFF4D79FF),
    'Markets': const Color(0xFFE056FD),
    'World': const Color(0xFFFFA502),
    'Politics': const Color(0xFFFF3838),
    'Entertainment': const Color(0xFFFF6348),
    'Science': const Color(0xFF7bed9f),
  };

  late TabController _tabController;
  List<_NewsItem> _newsItems = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categoryFeeds.keys.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _selectedIndex = _tabController.index;
      });
      _fetchNewsForCategory(categoryFeeds.keys.toList()[_tabController.index]);
    });
    _fetchNewsForCategory(categoryFeeds.keys.first);
  }

  Future<void> _fetchNewsForCategory(String category) async {
    setState(() {
      _isLoading = true;
      _newsItems = [];
    });

    List<String> urls = List.from(categoryFeeds[category]!);
    urls.shuffle();

    List<_NewsItem> allItems = [];

    final responses = await Future.wait(
      urls.map((url) async {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final decodedBody = utf8.decode(response.bodyBytes);
            final document = XmlDocument.parse(decodedBody);
            final newsItems = document.findAllElements('item');

            return newsItems.map((item) {
              final title = item.getElement('title')?.text.trim() ?? 'No Title';
              final descriptionHtml = item.getElement('description')?.text ?? 'No Description';
              final description = descriptionHtml.replaceAll(RegExp(r'<[^>]*>'), '').trim();
              final link = item.getElement('link')?.text ?? '';

              String imageUrl = '';
              final mediaGroup = item.getElement('media:group');
              if (mediaGroup != null) {
                final mediaContent = mediaGroup.findAllElements('media:content').firstWhere(
                      (element) => element.getAttribute('url') != null,
                  orElse: () => XmlElement(XmlName('media:content')),
                );
                imageUrl = mediaContent.getAttribute('url') ?? '';
              }

              if (imageUrl.isEmpty) {
                imageUrl = item.getElement('media:thumbnail')?.getAttribute('url') ??
                    item.getElement('media:content')?.getAttribute('url') ??
                    '';
              }

              if (imageUrl.contains('ichef.bbci.co.uk')) {
                imageUrl = imageUrl.replaceAllMapped(
                  RegExp(r'/standard/(\d{2,4})/'),
                      (match) => '/standard/976/',
                );
              } else if (imageUrl.contains('cdn.cnn.com')) {
                imageUrl = imageUrl.replaceAllMapped(
                  RegExp(r'-(\d{2,4})x(\d{2,4})\.jpg'),
                      (match) => '-720x405.jpg',
                );
              }
              else if (imageUrl.contains('i2.cdn.turner.com')) {
                imageUrl = imageUrl.replaceFirst('i2.cdn.turner.com', 'cdn.cnn.com');
              }

              return _NewsItem(
                title: title,
                description: description,
                imageUrl: imageUrl,
                url: link,
              );
            }).toList();
          }
        } catch (e) {
          debugPrint('❌ Error fetching $url: $e');
        }

        return <_NewsItem>[];
      }),
    );

    allItems = responses.expand((items) => items).toList();

    setState(() {
      _newsItems = allItems;
      _isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _showNewsBottomSheet(_NewsItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D0D),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcons[categoryFeeds.keys.toList()[_selectedIndex]]!,
                              color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              categoryFeeds.keys.toList()[_selectedIndex],
                              style: TextStyle(
                                color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Image
                      if (item.imageUrl.isNotEmpty)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.2),
                                      categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.5),
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Read Full Article Button
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchURL(item.url);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!,
                            categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.open_in_new,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Read Full Article',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCard(_NewsItem item) {
    return Container(
      height: 280,
      margin: const EdgeInsets.only(right: 16),
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => _showNewsBottomSheet(item),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                item.imageUrl,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.3),
                        Colors.black87,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white30,
                    size: 60,
                  ),
                ),
              )
                  : Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.3),
                      Colors.black87,
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      categoryIcons[categoryFeeds.keys.toList()[_selectedIndex]]!,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      categoryFeeds.keys.toList()[_selectedIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(_NewsItem item) {
    return GestureDetector(
      onTap: () => _showNewsBottomSheet(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    categoryIcons[categoryFeeds.keys.toList()[_selectedIndex]]!,
                    color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!,
                    size: 30,
                  ),
                )
                    : Icon(
                  categoryIcons[categoryFeeds.keys.toList()[_selectedIndex]]!,
                  color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B6B),
                          const Color(0xFF4ECDC4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explore',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Discover latest news',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category Tabs
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categoryFeeds.keys.length,
                itemBuilder: (context, index) {
                  final category = categoryFeeds.keys.toList()[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      _tabController.animateTo(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                          colors: [
                            categoryColors[category]!,
                            categoryColors[category]!.withOpacity(0.7),
                          ],
                        )
                            : null,
                        color: isSelected ? null : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? categoryColors[category]!
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            categoryIcons[category]!,
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          categoryColors[categoryFeeds.keys.toList()[_selectedIndex]]!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading ${categoryFeeds.keys.toList()[_selectedIndex]} news...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : TabBarView(
                controller: _tabController,
                children: categoryFeeds.keys.map((category) {
                  return _newsItems.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.newspaper,
                          color: Colors.white.withOpacity(0.3),
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No news available',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                      : CustomScrollView(
                    slivers: [
                      // Featured Story
                      if (_newsItems.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            height: 300,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _newsItems.take(3).length,
                              itemBuilder: (context, index) {
                                return _buildFeaturedCard(_newsItems[index]);
                              },
                            ),
                          ),
                        ),

                      // Regular Stories
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            if (index < 3) return const SizedBox.shrink();
                            return _buildCompactCard(_newsItems[index]);
                          },
                          childCount: _newsItems.length,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsItem {
  final String title;
  final String description;
  final String imageUrl;
  final String url;

  _NewsItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
  });
}