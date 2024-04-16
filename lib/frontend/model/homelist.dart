import 'package:flutter/widgets.dart';
import 'package:mental_health/frontend/pages/journal.dart';
import '../pages/chatbot.dart';
import '../pages/homepage.dart';

class HomeList {
  HomeList({
    this.navigateScreen,
    this.imagePath = '',
  });

  Widget? navigateScreen;
  String imagePath;

  static List<HomeList> homeList = [
    HomeList(
      imagePath: 'assets/images/1.jpg',
      navigateScreen: const ChatbotScreen(),
    ),
    HomeList(
      imagePath: 'assets/images/2.jpg',
      navigateScreen: JournalPage(),
    ),
    HomeList(
      imagePath: 'assets/introduction_animation/relax_image.png',
      navigateScreen: HomePage(),
    ),
  ];
}
