import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatingController;
  late AnimationController _tapController;

  int _tapCount = 0;
  bool _showEasterEgg = false;

  final List<String> _funFacts = [
    "AI thinks every headline needs more drama 🎭",
    "This app has read more news than your uncle on Facebook 📱",
    "Breaking: Local app makes news actually bearable 📰",
    "Fun fact: AI humor is 60% sarcasm, 40% confusion 🤖",
    "This app's comedy level: Dad jokes meet tech bro 💻",
    "Plot twist: The AI is funnier than most humans 😅",
  ];

  String _currentFunFact = "";
  int _currentFactIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _currentFunFact = _funFacts[0];
    _fadeController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatingController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Don\'t know why the fuck these links are not opening TBH!!"),
          backgroundColor: const Color(0xFFCAC4C4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _shareApp() {
    Share.share('📰 Check out this clean and smart news app: [https://github.com/prashantpatil0/Article-India/releases/download/v1.0.0/Article.apk]');
  }

  void _onLogoTap() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        _showEasterEgg = true;
        _tapCount = 0;
      }
    });

    _tapController.forward().then((_) => _tapController.reverse());

    // Cycle through fun facts
    setState(() {
      _currentFactIndex = (_currentFactIndex + 1) % _funFacts.length;
      _currentFunFact = _funFacts[_currentFactIndex];
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D0D0D),
            const Color(0xFF1A1A1A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Interactive Logo
          GestureDetector(
            onTap: _onLogoTap,
            child: AnimatedBuilder(
              animation: _tapController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_tapController.value * 0.1),
                  child: AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, sin(_floatingController.value * 2 * pi) * 3),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.article,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            '𝕬𝖗𝖙𝖎𝖈𝖑𝖊',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'News that speaks facts… and cracks jokes!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Fun Fact Display (Timepass Feature)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey(_currentFunFact),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6348).withOpacity(0.1),
                    const Color(0xFFE056FD).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentFunFact,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tap the logo for more fun facts! 👆',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF4ECDC4)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFF4ECDC4),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEasterEgg() {
    if (!_showEasterEgg) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6348), Color(0xFFE056FD)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6348).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            '🎉 Easter Egg Found! 🎉',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'ve discovered the secret! You are now an official Article app power user! 🚀',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _showEasterEgg = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Cool!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
            // Header matching other screens
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
                      Icons.info,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Info & More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'About the app',
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

            // Scrollable Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeController,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Interactive Header
                    _buildHeader(),

                    const SizedBox(height: 24),

                    // Easter Egg
                    _buildEasterEgg(),

                    // About Section
                    _buildSection(
                      'About the App',
                      Text(
                        'A news app that curates top headlines and lets AI make them funny.\n\nWe asked AI to lighten the news. It might\'ve gone too far. Again.\n\nDisclaimer: All jokes were generated by an AI that thinks memes are literature.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                    ),

                    // Developer Section
                    _buildSection(
                      'Developer',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prashant Patil',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "If you get offended by the funny translation of a news don\'t blame me.. blame AI!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildContactButton(
                                Icons.mail,
                                    () => _launchUrl('mailto:patilprashant9307@gmail.com'),
                                const Color(0xFFFF6348),
                              ),
                              _buildContactButton(
                                Icons.code,
                                    () => _launchUrl('https://github.com/prashantpatil0'),
                                const Color(0xFF4ECDC4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions Section
                    _buildSection(
                      'Actions',
                      Column(
                        children: [
                          _buildActionButton(
                            icon: Icons.star,
                            label: 'Rate App',
                            onTap: () => _launchUrl('https://github.com/prashantpatil0/Article-India'),
                            iconColor: const Color(0xFFFFD700),
                          ),
                          _buildActionButton(
                            icon: Icons.share,
                            label: 'Share App',
                            onTap: _shareApp,
                            iconColor: const Color(0xFF4ECDC4),
                          ),
                        ],
                      ),
                    ),

                    // Privacy Section
                    _buildSection(
                      'Privacy',
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6BCF7F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.security,
                              color: Color(0xFF6BCF7F),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This app does not collect personal data. We respect your privacy.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Version
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}