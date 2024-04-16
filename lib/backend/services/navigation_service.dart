import 'package:flutter/material.dart';
import 'package:mental_health/frontend/navigation_home_screen.dart';
import 'package:mental_health/frontend/pages/generate_code_page.dart';
import 'package:mental_health/frontend/pages/journal.dart';
import 'package:mental_health/frontend/pages/scan_code_page.dart';

import '../../frontend/pages/homepage.dart';
import '../../frontend/pages/login_page.dart';
import '../../frontend/pages/register_page.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/home': (context) => const HomePage(),
    '/navscreen': (context) => NavigationHomeScreen(),
    '/journal': (context) => JournalPage(),
    '/qr': (context) => ScanCodePage(),
    '/generate': (context) => GenerateCodePage(),

  };

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void pushNamed(String routename) {
    _navigatorKey.currentState?.pushNamed(routename);
  }

  void pop() {
    _navigatorKey.currentState?.pop();
  }

  void pushReplacementNamed(String route) {
    _navigatorKey.currentState?.pushNamed(route);
  }
}
