import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/info_screen.dart';

void main() {
  runApp(TruthApp());
}

class TruthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SplashScreen(), //  Show splash first
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Provide the required 'nitterRssUrl' parameter here
  final FeedScreen _feedScreen = FeedScreen();
  final ExploreScreen _exploreScreen = ExploreScreen();
  final InfoScreen _infoScreen = InfoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use IndexedStack to preserve state of all screens
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _feedScreen,
          _exploreScreen,
          _infoScreen,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
        ],
      ),
    );
  }
}
