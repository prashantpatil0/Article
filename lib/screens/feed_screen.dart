import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/scheduler.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

bool _hintShown = false;

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  final List<String> feedUrls = [
    'https://abcnews.go.com/abcnews/topstories',
    'https://globalnews.ca/feed/',
    'https://www.sbs.com.au/news/topic/world/feed',
    'https://feeds.bbci.co.uk/news/world/rss.xml',
    'http://rss.cnn.com/rss/edition_world.rss',
    'https://abcnews.go.com/abcnews/internationalheadlines',
    'https://feeds.feedburner.com/ndtvnews-india-news',
    'https://www.oneindia.com/rss/feeds/news-international-fb.xml',
    'https://www.mid-day.com/Resources/midday/rss/india-news.xml',
    'https://www.theweek.in/news/india.rss.xml',
    'https://www.thehindu.com/business/Industry/feeder/default.rss',
    'https://www.thehindu.com/business/markets/feeder/default.rss',
    'https://www.firstpost.com/commonfeeds/v1/mfp/rss/politics.xml',
    'https://www.firstpost.com/commonfeeds/v1/mfp/rss/india.xml',
    'https://www.thehindu.com/news/international/feeder/default.rss',
    'https://feeds.feedburner.com/ndtvnews-world-news',
    'https://feeds.feedburner.com/ndtvnews-top-stories',
    'https://www.sbs.com.au/news/topic/world/feed',
    'https://nypost.com/world-news/feed/',
    'https://globalnews.ca/world/feed/',
    'https://www.mid-day.com/Resources/midday/rss/world-news.xml',
    'http://rss.cnn.com/rss/money_topstories.rss',
    'https://www.theweek.in/news/world.rss.xml',
    'https://www.firstpost.com/commonfeeds/v1/mfp/rss/world.xml',
  ];

  List<_NewsItem> newsList = [];
  bool isLoading = true;
  late AnimationController _animationController;

  final model = GenerativeModel(model: 'gemma-3-27b-it', apiKey: 'AIzaSyCovPJcjEqAjbkjfaxJtixfq9I6Qj0xqlI');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    feedUrls.shuffle();
    fetchNews();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchNews() async {
    List<_NewsItem> allItems = [];

    final fetchTasks = feedUrls.map((url) async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final decodedBody = utf8.decode(response.bodyBytes);
          final document = XmlDocument.parse(decodedBody);
          final newsItems = document.findAllElements('item');

          final unescape = HtmlUnescape();

          return newsItems.map((item) {
            final rawTitle = item.getElement('title')?.text.trim() ?? 'No Title';
            final rawDescriptionHtml = item.getElement('description')?.text ?? 'No Description';

            final cleanedDescription = rawDescriptionHtml.replaceAll(RegExp(r'<[^>]*>'), '').trim();
            final title = unescape.convert(rawTitle);
            final description = unescape.convert(cleanedDescription);

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
            }

            final articleUrl = item.getElement('link')?.text ?? '';

            return _NewsItem(
              title: title,
              description: description,
              imageUrl: imageUrl,
              articleUrl: articleUrl,
            );
          }).toList();
        }
      } catch (e) {
        debugPrint('Error fetching/parsing $url: $e');
      }

      return <_NewsItem>[];
    }).toList();

    final results = await Future.wait(fetchTasks);

    for (var result in results) {
      allItems.addAll(result);
    }

    setState(() {
      newsList = allItems;
      isLoading = false;
    });

    _animationController.forward();

    if (!_hintShown) {
      _hintShown = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showHintDialog();
      });
    }
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.swipe_vertical,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Navigate Stories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe vertically to browse through news stories',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _showFunnyNewsBottomSheet(BuildContext context, _NewsItem news) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Handle and Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6348), Color(0xFFE056FD)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sentiment_very_satisfied, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Comedy Mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _generateFunnyNews(news.title, news.description),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6348), Color(0xFFE056FD)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Brewing some comedy magic...',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Oops! Comedy generator is having a bad day',
                                  style: TextStyle(color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        final rawText = snapshot.data ?? 'No funny content found.';
                        final cleanText = rawText.replaceAll('*', '');
                        final split = cleanText.split('\n\n');
                        final funnyTitle = split.isNotEmpty ? split.first.trim() : '';
                        final funnyDescription = split.length > 1 ? split.sublist(1).join('\n\n') : '';

                        return ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6348).withOpacity(0.1),
                                    const Color(0xFFE056FD).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                funnyTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              funnyDescription,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _generateFunnyNews(String title, String description) async {
    final prompt = '''
You're a brilliant, dark-humored AI comedian with a razor-sharp wit and a talent for turning serious news into twisted entertainment.
Your task is to rewrite the following news story in a way that's hilariously clever, brutally sarcastic, and irresistibly engaging
— like something from a savage late-night comedy monologue or a viral dark meme. Think intelligent satire, not angry rant.
News to rewrite:
Headline: "$title"
Description: "$description"
Your output must include:
1. A **short, witty, and sarcastic headline** (make it bold).
2. A **funny, darkly ironic paragraph** summarizing and mocking the situation — make it sharp, clever, and weirdly insightful.
Guidelines:
- Don't change the facts — just the tone and delivery.
- Use smart, cynical humor with irony, satire, and exaggeration.
- Be playfully harsh and edgy, not mean-spirited or preachy.
- Criticize everyone involved lightly — no clear heroes or villains.
- Keep the paragraph short, punchy, and funny like a stand-up set or late-night script.
- Avoid sounding safe or formal — embrace weird, witty, bold takes.
- Make it entertaining to read — like the news got a sense of humor.
Only return the headline and the paragraph. No intros, summaries, or extra commentary.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No response.';
  }

  Widget _buildStoryCard(_NewsItem news, int index) {
    return Container(
      height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 100, // Fixed height
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          if (news.imageUrl.isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.35, // Reduced from 0.4
                    width: double.infinity,
                    child: Image.network(
                      news.imageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1A1A1A),
                              const Color(0xFF0D0D0D),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white30,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  height: MediaQuery.of(context).size.height * 0.35, // Reduced from 0.4
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Story indicator
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color(0xFFFF6B6B),
                          size: 8,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              height: MediaQuery.of(context).size.height * 0.35, // Reduced from 0.4
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF0D0D0D),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.article,
                  color: Colors.white30,
                  size: 60,
                ),
              ),
            ),

          // Content Section
          Expanded( // Use Expanded instead of fixed height
            child: Padding(
              padding: const EdgeInsets.all(20), // Reduced from 24
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 22, // Reduced from 24
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12), // Reduced from 16

                  // Description
                  Expanded( // Use Expanded instead of fixed height
                    child: SingleChildScrollView(
                      child: Text(
                        news.description,
                        style: TextStyle(
                          fontSize: 15, // Reduced from 16
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5, // Reduced from 1.6
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Reduced from 24

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showFunnyNewsBottomSheet(context, news),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14), // Reduced from 16
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6348), Color(0xFFE056FD)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_very_satisfied, color: Colors.white, size: 18), // Reduced from 20
                                SizedBox(width: 8),
                                Text(
                                  'Make it Funny',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15, // Reduced from 16
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _launchURL(news.articleUrl),
                        child: Container(
                          padding: const EdgeInsets.all(14), // Reduced from 16
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: const Icon(
                            Icons.open_in_new,
                            color: Colors.white,
                            size: 18, // Reduced from 20
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Added small bottom padding
                ],
              ),
            ),
          ),
        ],
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
            // Header matching ExploreScreen style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.article,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '𝕬𝖗𝖙𝖎𝖈𝖑𝖊',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Latest breaking news',
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

            // Main Content
            Expanded(
              child: isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading latest stories...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : FadeTransition(
                opacity: _animationController,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    return _buildStoryCard(newsList[index], index);
                  },
                ),
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
  final String articleUrl;

  _NewsItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.articleUrl,
  });
}